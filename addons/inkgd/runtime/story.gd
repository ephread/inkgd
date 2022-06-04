# warning-ignore-all:shadowed_variable
# warning-ignore-all:unused_class_variable
# warning-ignore-all:unused_signal
# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends InkObject

class_name InkStory

const INK_VERSION_CURRENT := 20
const INK_VERSION_MINIMUM_COMPATIBLE := 18

# ############################################################################ #
# Imports
# ############################################################################ #

var PushPopType = preload("res://addons/inkgd/runtime/enums/push_pop.gd").PushPopType
var ErrorType = preload("res://addons/inkgd/runtime/enums/error.gd").ErrorType

var InkStopWatch := preload("res://addons/inkgd/runtime/extra/stopwatch.gd") as GDScript
var InkProfiler := preload("res://addons/inkgd/runtime/profiler.gd") as GDScript

var InkSimpleJSON := preload("res://addons/inkgd/runtime/simple_json.gd") as GDScript
var InkStringSet := preload("res://addons/inkgd/runtime/extra/string_set.gd") as GDScript
var InkListItem := preload("res://addons/inkgd/runtime/lists/structs/ink_list_item.gd") as GDScript
var InkListDefinitionsOrigin := preload("res://addons/inkgd/runtime/lists/list_definitions_origin.gd") as GDScript

var InkPointer := preload("res://addons/inkgd/runtime/structs/pointer.gd") as GDScript
var InkControlCommand := preload("res://addons/inkgd/runtime/content/control_command.gd") as GDScript

var InkVoid := preload("res://addons/inkgd/runtime/content/void.gd") as GDScript
var StoryErrorMetadata := preload("res://addons/inkgd/runtime/extra/story_error_metadata.gd") as GDScript

# ############################################################################ #

var InkValue := load("res://addons/inkgd/runtime/values/value.gd") as GDScript
var InkIntValue := load("res://addons/inkgd/runtime/values/int_value.gd") as GDScript
var InkStringValue := load("res://addons/inkgd/runtime/values/string_value.gd") as GDScript
var InkVariablePointerValue := load("res://addons/inkgd/runtime/values/variable_pointer_value.gd") as GDScript
var InkListValue := load("res://addons/inkgd/runtime/values/list_value.gd") as GDScript

var InkList := load("res://addons/inkgd/runtime/lists/ink_list.gd") as GDScript
var InkChoice := load("res://addons/inkgd/runtime/content/choices/choice.gd") as GDScript

var InkStoryState := load("res://addons/inkgd/runtime/story_state.gd") as GDScript

# ############################################################################ #

var current_choices: Array setget , get_current_choices # Array<Choice>
func get_current_choices() -> Array:
	var choices: Array = [] # Array<Choice>

	for c in self._state.current_choices:
		if !c.is_invisible_default:
			c.index = choices.size()
			choices.append(c)

	return choices

# String?
var current_text setget , get_current_text
func get_current_text():
	if async_we_cant("call currentText since it's a work in progress"):
		return null

	return self.state.current_text

# Array?
var current_tags setget , get_current_tags # Array<String>
func get_current_tags():
	if async_we_cant("call currentTags since it's a work in progress"):
		return null

	return self.state.current_tags

var current_errors setget , get_current_errors # Array<String>
func get_current_errors(): return self.state.current_errors

var current_warnings setget , get_current_warnings # Array<String>
func get_current_warnings(): return self.state.current_warnings

var current_flow_name setget , get_current_flow_name # String
func get_current_flow_name(): return self.state.current_flow_name

var has_error setget , get_has_error # bool
func get_has_error(): return self.state.has_error

var has_warning setget , get_has_warning # bool
func get_has_warning(): return self.state.has_warning

var variables_state setget , get_variables_state # VariablesState
func get_variables_state(): return self.state.variables_state

var list_definitions setget , get_list_definitions # ListDefinitionsOrigin
func get_list_definitions():
	return self._list_definitions

var state: InkStoryState setget , get_state # StoryState
func get_state():
	return self._state

signal on_error(message, type)

signal on_did_continue()

signal on_make_choice(choice)

signal on_evaluate_function(function_name, arguments)

signal on_complete_evaluate_function(function_name, arguments, text_output, result)

signal on_choose_path_string(path, arguments)


func start_profiling() -> InkProfiler:
	if async_we_cant ("Start Profiling"):
		return null

	_profiler = InkProfiler.new()
	return _profiler


func end_profiling() -> void:
	_profiler = null


# (InkContainer, Array<ListDefinition>) -> void
func _init_with(content_container: InkContainer, lists = null):
	_initialize_runtime()
	self._main_content_container = content_container

	if lists != null:
		self._list_definitions = InkListDefinitionsOrigin.new(lists)

	self._externals = {} # Dictionary<String, ExternalFunctionDef>


func _init(json_string: String):
	_init_with(null)

	var root_object = InkSimpleJSON.text_to_dictionary(json_string)

	var version_obj = root_object["inkVersion"]
	if version_obj == null:
		Utils.throw_exception(
				"ink version number not found. " +
				"Are you sure it's a valid .ink.json file?"
		)
		return

	var format_from_file = int(version_obj)
	if format_from_file > INK_VERSION_CURRENT:
		Utils.throw_exception(
				"Version of ink used to build story was newer " +
				"than the current version of the engine"
		)
		return
	elif format_from_file < INK_VERSION_MINIMUM_COMPATIBLE:
		Utils.throw_exception(
				"Version of ink used to build story is too old " +
				"to be loaded by this version of the engine"
		)
		return
	elif format_from_file != INK_VERSION_CURRENT:
		print(
				"[Ink] [WARNING] Version of ink used to build story doesn't match " +
				"current version of engine. Non-critical, but recommend synchronising."
		)

	var root_token = root_object["root"]
	if root_token == null:
		Utils.throw_exception(
				"Root node for ink not found. Are you sure it's a valid .ink.json file?"
		)
		return

	if root_object.has("listDefs"):
		self._list_definitions = self.Json.jtoken_to_list_definitions(root_object["listDefs"])

	self._main_content_container = Utils.as_or_null(
			self.Json.jtoken_to_runtime_object(root_token),
			"InkContainer"
	)

	self.reset_state()


# () -> String
func to_json() -> String:
	var writer: InkSimpleJSON.Writer = InkSimpleJSON.Writer.new()
	to_json_with_writer(writer)
	return writer._to_string()


func write_root_property(writer: InkSimpleJSON.Writer) -> void:
	self.Json.write_runtime_container(writer, self._main_content_container)


func to_json_with_writer(writer: InkSimpleJSON.Writer) -> void:
	writer.write_object_start()

	writer.write_property("inkVersion", INK_VERSION_CURRENT)

	writer.write_property("root", funcref(self, "write_root_property"))

	if self._list_definitions != null:
		writer.write_property_start("listDefs")
		writer.write_object_start()

		for def in self._list_definitions.lists:
			writer.write_property_start(def.name)
			writer.write_object_start()

			for item_to_val_key in def.items:
				var item = InkListItem.from_serialized_key(item_to_val_key)
				var val = def.items[item_to_val_key]
				writer.write_property(item.item_name, val)

			writer.write_object_end()
			writer.write_property_end()

		writer.write_object_end()
		writer.write_property_end()

	writer.write_object_end()


# () -> void
func reset_state() -> void:
	if async_we_cant ("ResetState"):
		return

	self._state = InkStoryState.new(self)
	self._state.variables_state.connect("variable_changed", self, "variable_state_did_change_event")

	self.reset_globals()


# () -> void
func reset_errors() -> void:
	self._state.reset_errors()


# () -> void
func reset_callstack() -> void:
	if async_we_cant("ResetCallstack"):
		return

	self._state.force_end()


# () -> void
func reset_globals() -> void:
	if (self._main_content_container.named_content.has("global decl")):
		var original_pointer = self.state.current_pointer

		self.choose_path(InkPath().new_with_components_string("global decl"), false)

		self.continue_internal()

		self.state.current_pointer = original_pointer

	self.state.variables_state.snapshot_default_globals()


func switch_flow(flow_name: String) -> void:
	if async_we_cant("SwitchFlow"):
		return

	if self._async_saving:
		Utils.throw_exception("Story is already in background saving mode, can't switch flow to " + flow_name)

	self.state.switch_flow_internal(flow_name)


func remove_flow(flow_name: String) -> void:
	self.state.remove_flow_internal(flow_name)


func switch_to_default_flow() -> void:
	self.state.switch_to_default_flow_internal()


func continue() -> String:
	self.continue_async(0)
	return self.current_text


var can_continue: bool setget , get_continue
func get_continue() -> bool:
	return self.state.can_continue


var async_continue_complete: bool setget , get_async_continue_complete
func get_async_continue_complete() -> bool:
	return !self._async_continue_active


func continue_async(millisecs_limit_async: float):
	if !self._has_validated_externals:
		self.validate_external_bindings()

	continue_internal(millisecs_limit_async)


func continue_internal(millisecs_limit_async: float = 0) -> void:
	if _profiler != null:
		_profiler.pre_continue()

	var is_async_time_limited = millisecs_limit_async > 0

	self._recursive_continue_count += 1

	if !self._async_continue_active:
		self._async_continue_active = is_async_time_limited

		if !self.can_continue:
			Utils.throw_exception("Can't continue - should check canContinue before calling Continue")
			return

		self._state.did_safe_exit = false
		self._state.reset_output()

		if self._recursive_continue_count == 1:
			self._state.variables_state.batch_observing_variable_changes = true

	var duration_stopwatch = InkStopWatch.new()
	duration_stopwatch.start()

	var output_stream_ends_in_newline = false
	self._saw_lookahead_unsafe_function_after_newline = false

	# In the original code, exceptions raised during 'continue_single_step()'
	# are catched and added to the error array. Since exceptions don't exist
	# in GDScript, they are recorded instead. See 'ink_runtime.gd' for more
	# information.
	self._enable_story_exception_recording(true)
	var first_time = true
	while (first_time || self.can_continue):
		first_time = false

		output_stream_ends_in_newline = self.continue_single_step()
		var recorded_exceptions = _get_and_clear_recorded_story_exceptions()
		if recorded_exceptions.size() > 0:
			for error in recorded_exceptions:
				add_story_error(error)
			break

		if output_stream_ends_in_newline:
			break

		if _async_continue_active && duration_stopwatch.elapsed_milliseconds > millisecs_limit_async:
			break

	self._enable_story_exception_recording(false)
	duration_stopwatch.stop()

	if output_stream_ends_in_newline || !self.can_continue:

		if self._state_snapshot_at_last_newline != null:
			self.restore_state_snapshot()

		if !self.can_continue:
			if self.state.callstack.can_pop_thread:
				add_error("Thread available to pop, threads should always be flat by the end of evaluation?")

			if self.state.generated_choices.size() == 0 && !self.state.did_safe_exit && self._temporary_evaluation_container == null:
				if self.state.callstack.can_pop_type(PushPopType.TUNNEL):
					add_error("unexpectedly reached end of content. Do you need a '->->' to return from a tunnel?")
				elif self.state.callstack.can_pop_type(PushPopType.FUNCTION):
					add_error("unexpectedly reached end of content. Do you need a '~ return'?")
				elif !self.state.callstack.can_pop:
					add_error("ran out of content. Do you need a '-> DONE' or '-> END'?")
				else:
					add_error("unexpectedly reached end of content for unknown reason. Please debug compiler!")

		self.state.did_safe_exit = false
		self._saw_lookahead_unsafe_function_after_newline = false

		if _recursive_continue_count == 1:
			_state.variables_state.batch_observing_variable_changes = false

		self._async_continue_active = false
		emit_signal("on_did_continue")

	self._recursive_continue_count -= 1

	if _profiler != null:
		_profiler.post_continue()

	if self.state.has_error || self.state.has_warning:
		if !self.get_signal_connection_list("on_error").empty():
			if self.state.has_error:
				for err in self.state.current_errors:
					emit_signal("on_error", err, ErrorType.ERROR)

			if self.state.has_warning:
				for err in self.state.current_warnings:
					emit_signal("on_error", err, ErrorType.WARNING)

			self.reset_errors()
		else:
			var exception = "Ink had "

			if self.state.has_error:
				exception += str(self.state.current_errors.size())
				exception += " error" if self.state.current_errors.size() == 1 else " errors"
				if self.state.has_warning:
					exception += " and "

			if self.state.has_warning:
				exception += str(self.state.current_warnings.size())
				exception += " warning" if self.state.current_warnings.size() == 1 else " warnings"

			exception += ". It is strongly suggested that you assign an error handler to story.onError. The first issue was: "
			exception += self.state.current_errors[0] if self.state.has_error else self.state.current_warnings[0]

			# If you get this exception, please connect an error handler to the appropriate signal: "on_error".
			self._throw_story_exception(exception)


func continue_single_step() -> bool:
	if _profiler != null:
		_profiler.pre_step()

	self.step()

	if _profiler != null:
		_profiler.post_step()


	if !self.can_continue && !self.state.callstack.element_is_evaluate_from_game:
		self.try_follow_default_invisible_choice()


	if _profiler != null:
		_profiler.pre_snapshot()

	if !self.state.in_string_evaluation:
		if self._state_snapshot_at_last_newline != null:

			var change = calculate_newline_output_state_change(
				self._state_snapshot_at_last_newline.current_text, self.state.current_text,
				self._state_snapshot_at_last_newline.current_tags.size(), self.state.current_tags.size()
			)

			if change == OutputStateChange.EXTENDED_BEYOND_NEWLINE || self._saw_lookahead_unsafe_function_after_newline:
				self.restore_state_snapshot()

				return true
			elif change == OutputStateChange.NEWLINE_REMOVED:
				self.discard_snapshot()

		if self.state.output_stream_ends_in_newline:
			if self.can_continue:
				if self._state_snapshot_at_last_newline == null:
					self.state_snapshot()
			else:
				self.discard_snapshot()

	if _profiler != null:
		_profiler.post_snapshot()

	return false


enum OutputStateChange {
	NO_CHANGE,
	EXTENDED_BEYOND_NEWLINE,
	NEWLINE_REMOVED
}


# (String, String, int, int) -> OutputStateChange
func calculate_newline_output_state_change(
	prev_text: String,
	curr_text: String,
	prev_tag_count: int,
	curr_tag_count: int
) -> int:
	var newline_still_exists = curr_text.length() >= prev_text.length() && curr_text[prev_text.length() - 1] == "\n"
	if (prev_tag_count == curr_tag_count && prev_text.length() == curr_text.length() && newline_still_exists):
		return OutputStateChange.NO_CHANGE

	if !newline_still_exists:
		return OutputStateChange.NEWLINE_REMOVED

	if curr_tag_count > prev_tag_count:
		return OutputStateChange.EXTENDED_BEYOND_NEWLINE

	var i = prev_text.length()
	while i < curr_text.length():
		var c = curr_text[i]

		if c != " " && c != "\t":
			return OutputStateChange.EXTENDED_BEYOND_NEWLINE

		i += 1

	return OutputStateChange.NO_CHANGE


func continue_maximally() -> String:
	if async_we_cant("ContinueMaximally"):
		return ""

	var _str = ""

	while (self.can_continue):
		_str += self.continue()

	return _str


func content_at_path(path: InkPath) -> InkSearchResult:
	return self.main_content_container.content_at_path(path)


func knot_container_with_name(name: String) -> InkContainer:
	if self.main_content_container.named_content.has(name):
		return Utils.as_or_null(self.main_content_container.named_content[name], "InkContainer")

	return null


func pointer_at_path(path: InkPath) -> InkPointer:
	if (path.length == 0):
		return InkPointer.null()

	var p = InkPointer.new()

	var path_length_to_use = path.length

	var result = null # SearchResult
	if (path.last_component.is_index):
		path_length_to_use = path.length - 1
		result = self.main_content_container.content_at_path(path, 0, path_length_to_use)
		p = InkPointer.new(result.container, path.last_component.index)
	else:
		result = self.main_content_container.content_at_path(path)
		p = InkPointer.new(result.container, -1)

	if result.obj == null || result.obj == self.main_content_container && path_length_to_use > 0:
		error(
			"Failed to find content at path '%s', " % path._to_string() +
			"and no approximation of it was possible."
		)
	elif result.approximate:
		warning(
			"Failed to find content at path '%s', " %  path +
			"so it was approximated to: '%s'." % result.obj.path._to_string()
		)

	return p


func state_snapshot() -> void:
	self._state_snapshot_at_last_newline = self._state
	self._state = self._state.copy_and_start_patching()


func restore_state_snapshot() -> void:
	self._state_snapshot_at_last_newline.restore_after_patch()

	self._state = self._state_snapshot_at_last_newline
	self._state_snapshot_at_last_newline = null

	if !self._async_saving:
		self._state.apply_any_patch()


func discard_snapshot() -> void:
	if !self._async_saving:
		self._state.apply_any_patch()

	self._state_snapshot_at_last_newline = null


func copy_state_for_background_thread_save() -> InkStoryState:
	if async_we_cant("start saving on a background thread"):
		return null

	if self._async_saving:
		Utils.throw_exception(
				"Story is already in background saving mode, " +
				"can't call CopyStateForBackgroundThreadSave again!"
		)
		return null

	var state_to_save = self._state
	self._state = self._state.copy_and_start_patching()
	self._async_saving = true

	return state_to_save


func background_save_complete() -> void:
	if self._state_snapshot_at_last_newline == null:
		_state.apply_any_patch()

	self._async_saving = false


func step() -> void:
	var should_add_to_stream = true

	var pointer = self.state.current_pointer
	if pointer.is_null:
		return

	var container_to_enter = Utils.as_or_null(pointer.resolve(), "InkContainer")
	while (container_to_enter):
		self.visit_container(container_to_enter, true)

		if container_to_enter.content.size() == 0:
			break

		pointer = InkPointer.start_of(container_to_enter)
		container_to_enter = Utils.as_or_null(pointer.resolve(), "InkContainer")

	self.state.current_pointer = pointer

	if _profiler != null:
		_profiler.step(state.callstack)

	var current_content_obj = pointer.resolve()
	var is_logic_or_flow_control = perform_logic_and_flow_control(current_content_obj)

	if self.state.current_pointer.is_null:
		return

	if is_logic_or_flow_control:
		should_add_to_stream = false

	var choice_point = Utils.as_or_null(current_content_obj, "ChoicePoint")
	if choice_point:
		var choice = process_choice(choice_point)
		if choice:
			self.state.generated_choices.append(choice)

		current_content_obj = null
		should_add_to_stream = false

	if Utils.is_ink_class(current_content_obj, "InkContainer"):
		should_add_to_stream = false

	if should_add_to_stream:
		var var_pointer = Utils.as_or_null(current_content_obj, "VariablePointerValue")
		if var_pointer && var_pointer.context_index == -1:
			var context_idx = self.state.callstack.context_for_variable_named(var_pointer.variable_name)
			current_content_obj = InkVariablePointerValue.new_with_context(var_pointer.variable_name, context_idx)

		if self.state.in_expression_evaluation:
			self.state.push_evaluation_stack(current_content_obj)
		else:
			self.state.push_to_output_stream(current_content_obj)

	self.next_content()

	var control_cmd = Utils.as_or_null(current_content_obj, "ControlCommand")
	if control_cmd && control_cmd.command_type == InkControlCommand.CommandType.START_THREAD:
		self.state.callstack.push_thread()


func visit_container(container: InkContainer, at_start: bool) -> void:
	if !container.counting_at_start_only || at_start:
		if container.visits_should_be_counted:
			self.state.increment_visit_count_for_container(container)

		if container.turn_index_should_be_counted:
			self.state.record_turn_index_visit_to_container(container)


var _prev_containers = [] # Array<Container>
func visit_changed_containers_due_to_divert() -> void:
	var previous_pointer = self.state.previous_pointer
	var pointer = self.state.current_pointer

	if pointer.is_null || pointer.index == -1:
		return

	self._prev_containers.clear()
	if !previous_pointer.is_null:
		var prev_ancestor = Utils.as_or_null(previous_pointer.resolve(), "InkContainer")
		prev_ancestor = prev_ancestor if prev_ancestor else Utils.as_or_null(previous_pointer.container, "InkContainer")
		while prev_ancestor:
			self._prev_containers.append(prev_ancestor)
			prev_ancestor = Utils.as_or_null(prev_ancestor.parent, "InkContainer")

	var current_child_of_container = pointer.resolve()

	if current_child_of_container == null: return

	var current_container_ancestor = Utils.as_or_null(current_child_of_container.parent, "InkContainer")

	var all_children_entered_at_start = true
	while current_container_ancestor && (self._prev_containers.find(current_container_ancestor) < 0 || current_container_ancestor.counting_at_start_only):

		var entering_at_start = (current_container_ancestor.content.size() > 0 &&
								current_child_of_container == current_container_ancestor.content[0] &&
								all_children_entered_at_start)

		if !entering_at_start:
			all_children_entered_at_start = false

		self.visit_container(current_container_ancestor, entering_at_start)

		current_child_of_container = current_container_ancestor
		current_container_ancestor = Utils.as_or_null(current_container_ancestor.parent, "InkContainer")


func process_choice(choice_point: InkChoicePoint) -> InkChoice:
	var show_choice = true

	if choice_point.has_condition:
		var condition_value = self.state.pop_evaluation_stack()
		if !self.is_truthy(condition_value):
			show_choice = false

	var start_text = ""
	var choice_only_text = ""

	if choice_point.has_choice_only_content:
		var choice_only_str_val = Utils.as_or_null(self.state.pop_evaluation_stack(), "StringValue")
		choice_only_text = choice_only_str_val.value

	if choice_point.has_start_content:
		var start_str_val = Utils.as_or_null(self.state.pop_evaluation_stack(), "StringValue")
		start_text = start_str_val.value

	if choice_point.once_only:
		var visit_count = self.state.visit_count_for_container(choice_point.choice_target)
		if visit_count > 0:
			show_choice = false

	if !show_choice:
		return null

	var choice = InkChoice.new()
	choice.target_path = choice_point.path_on_choice
	choice.source_path = choice_point.path._to_string()
	choice.is_invisible_default = choice_point.is_invisible_default
	choice.thread_at_generation = self.state.callstack.fork_thread()

	choice.text = Utils.trim(start_text + choice_only_text, [" ", "\t"])

	return choice


func is_truthy(obj: InkObject) -> bool:
	var truthy = false
	if Utils.is_ink_class(obj, "Value"):
		var val = obj

		if Utils.is_ink_class(obj, "DivertTargetValue"):
			var div_target = val
			error(str("Shouldn't use a divert target (to ", div_target.target_path._to_string(),
					  ") as a conditional value. Did you intend a function call 'likeThis()'",
					  " or a read count check 'likeThis'? (no arrows)"))
			return false

		return val.is_truthy

	return truthy


func perform_logic_and_flow_control(content_obj: InkObject) -> bool:
	if (content_obj == null):
		return false

	if Utils.is_ink_class(content_obj, "Divert"):
		var current_divert = content_obj

		if current_divert.is_conditional:
			var condition_value = self.state.pop_evaluation_stack()

			if !self.is_truthy(condition_value):
				return true

		if current_divert.has_variable_target:
			var var_name = current_divert.variable_divert_name
			var var_contents = self.state.variables_state.get_variable_with_name(var_name)

			if var_contents == null:
				error(str("Tried to divert using a target from a variable that could not be found (",
						  var_name, ")"))
				return false
			elif !Utils.is_ink_class(var_contents, "DivertTargetValue"):
				var int_content = Utils.as_or_null(var_contents, "IntValue")

				var error_message = str("Tried to divert to a target from a variable,",
										"but the variable (", var_name,
										") didn't contain a divert target, it ")
				if int_content && int_content.value == 0:
					error_message += "was empty/null (the value 0)."
				else:
					error_message += "contained '" + var_contents + "'."

				error(error_message)
				return false

			var target = var_contents
			self.state.diverted_pointer = self.pointer_at_path(target.target_path)

		elif current_divert.is_external:
			call_external_function(current_divert.target_path_string, current_divert.external_args)
			return true
		else:
			self.state.diverted_pointer = current_divert.target_pointer

		if current_divert.pushes_to_stack:
			self.state.callstack.push(
				current_divert.stack_push_type,
				0,
				self.state.output_stream.size()
			)

		if self.state.diverted_pointer.is_null && !current_divert.is_external:
			if current_divert && current_divert.debug_metadata != null && current_divert.debug_metadata.source_name != null:
				error("Divert target doesn't exist: " + current_divert.debug_metadata.source_name)
				return false
			else:
				error("Divert resolution failed: " + current_divert._to_string())
				return false

		return true
	elif Utils.is_ink_class(content_obj, "ControlCommand"):
		var eval_command = content_obj

		match eval_command.command_type:

			InkControlCommand.CommandType.EVAL_START:
				self.__assert__(
						self.state.in_expression_evaluation == false,
						"Already in expression evaluation?"
				)
				self.state.in_expression_evaluation = true

			InkControlCommand.CommandType.EVAL_END:
				self.__assert__(
						self.state.in_expression_evaluation == true,
						"Not in expression evaluation mode"
				)
				self.state.in_expression_evaluation = false

			InkControlCommand.CommandType.EVAL_OUTPUT:
				if self.state.evaluation_stack.size() > 0:
					var output = self.state.pop_evaluation_stack()

					if !Utils.as_or_null(output, "Void"):
						var text = InkStringValue.new_with(output._to_string())
						self.state.push_to_output_stream(text)

			InkControlCommand.CommandType.NO_OP:
				pass

			InkControlCommand.CommandType.DUPLICATE:
				self.state.push_evaluation_stack(self.state.peek_evaluation_stack())

			InkControlCommand.CommandType.POP_EVALUATED_VALUE:
				self.state.pop_evaluation_stack()

			InkControlCommand.CommandType.POP_FUNCTION, InkControlCommand.CommandType.POP_TUNNEL:
				var is_pop_function = (
						eval_command.command_type == InkControlCommand.CommandType.POP_FUNCTION
				)
				var pop_type = PushPopType.FUNCTION if is_pop_function else PushPopType.TUNNEL

				var override_tunnel_return_target = null # DivertTargetValue
				if pop_type == PushPopType.TUNNEL:
					var popped = self.state.pop_evaluation_stack()
					override_tunnel_return_target = Utils.as_or_null(popped, "DivertTargetValue")
					if override_tunnel_return_target == null:
						self.__assert__(
								Utils.is_ink_class(popped, "Void"),
								"Expected void if ->-> doesn't override target"
						)

				if self.state.try_exit_function_evaluation_from_game():
					pass
				elif self.state.callstack.current_element.type != pop_type || !self.state.callstack.can_pop:
					var names = {} # Dictionary<PushPopType, String>
					names[PushPopType.FUNCTION] = "function return statement (~ return)"
					names[PushPopType.TUNNEL] = "tunnel onwards statement (->->)"

					var expected = names[self.state.callstack.current_element.type]
					if !self.state.callstack.can_pop:
						expected = "end of flow (-> END or choice)"

					var error_msg = "Found %s, when expected %s" % [names[pop_type], expected]

					error(error_msg)
				else:
					self.state.pop_callstack()

					if override_tunnel_return_target:
						self.state.diverted_pointer = self.pointer_at_path(override_tunnel_return_target.target_path)

			InkControlCommand.CommandType.BEGIN_STRING:
				self.state.push_to_output_stream(eval_command)

				self.__assert__(
						self.state.in_expression_evaluation == true,
						"Expected to be in an expression when evaluating a string"
				)
				self.state.in_expression_evaluation = false

			InkControlCommand.CommandType.END_STRING:
				var content_stack_for_string = [] # Stack<InkObject>

				var output_count_consumed = 0
				var i = self.state.output_stream.size() - 1
				while (i >= 0):
					var obj = self.state.output_stream[i]

					output_count_consumed += 1

					var command = Utils.as_or_null(obj, "ControlCommand")
					if (command != null &&
						command.command_type == InkControlCommand.CommandType.BEGIN_STRING):
						break

					if Utils.is_ink_class(obj, "StringValue"):
						content_stack_for_string.push_front(obj)

					i -= 1

				self.state.pop_from_output_stream(output_count_consumed)

				var _str = ""
				for c in content_stack_for_string:
					_str += c._to_string()

				self.state.in_expression_evaluation = true
				self.state.push_evaluation_stack(InkStringValue.new_with(_str))

			InkControlCommand.CommandType.CHOICE_COUNT:
				var choice_count = self.state.generated_choices.size()
				self.state.push_evaluation_stack(InkIntValue.new_with(choice_count))

			InkControlCommand.CommandType.TURNS:
				self.state.push_evaluation_stack(InkIntValue.new_with(self.state.current_turn_index + 1))

			InkControlCommand.CommandType.TURNS_SINCE, InkControlCommand.CommandType.READ_COUNT:
				var target = self.state.pop_evaluation_stack()
				if !Utils.is_ink_class(target, "DivertTargetValue"):
					var extra_note = ""
					if Utils.is_ink_class(target, "IntValue"):
						extra_note = ". Did you accidentally pass a read count ('knot_name') instead of a target ('-> knot_name')?"
					error(str("TURNS_SINCE expected a divert target (knot, stitch, label name), but saw ",
							  target, extra_note))
					return false

				var divert_target = Utils.as_or_null(target, "DivertTargetValue")
				var container = Utils.as_or_null(self.content_at_path(divert_target.target_path).correct_obj, "InkContainer")

				var either_count = 0
				if container != null:
					if eval_command.command_type == InkControlCommand.CommandType.TURNS_SINCE:
						either_count = self.state.turns_since_for_container(container)
					else:
						either_count = self.state.visit_count_for_container(container)
				else:
					if eval_command.command_type == InkControlCommand.CommandType.TURNS_SINCE:
						either_count = -1
					else:
						either_count = 0

					warning(str("Failed to find container for ", eval_command._to_string(),
								" lookup at ", divert_target.target_path._to_string()))

				self.state.push_evaluation_stack(InkIntValue.new_with(either_count))

			InkControlCommand.CommandType.RANDOM:
				var max_int = Utils.as_or_null(self.state.pop_evaluation_stack(), "IntValue")
				var min_int = Utils.as_or_null(self.state.pop_evaluation_stack(), "IntValue")

				if min_int == null:
					error("Invalid value for minimum parameter of RANDOM(min, max)")
					return false

				if max_int == null:
					error("Invalid value for maximum parameter of RANDOM(min, max)")
					return false

				var random_range
				if max_int.value == (1 << 63) - 1 && min_int.value == 0:
					random_range = max_int.value
					error(str("RANDOM was called with a range that exceeds the size that ink numbers can use."))
					return false
				else:
					random_range = max_int.value - min_int.value + 1
				if random_range <= 0:
					error(str("RANDOM was called with minimum as ", min_int.value,
							  " and maximum as ", max_int.value, ". The maximum must be larger"))
					return false

				var result_seed = self.state.story_seed + self.state.previous_random
				seed(result_seed)

				var next_random = randi()
				var chosen_value = (next_random % random_range) + min_int.value
				self.state.push_evaluation_stack(InkIntValue.new_with(chosen_value))

				self.state.previous_random = next_random

			InkControlCommand.CommandType.SEED_RANDOM:
				var _seed = Utils.as_or_null(self.state.pop_evaluation_stack(), "IntValue")
				if _seed == null:
					error("Invalid value passed to SEED_RANDOM")
					return false

				self.state.story_seed = _seed.value
				self.state.previous_random = 0

				self.state.push_evaluation_stack(InkVoid.new())

			InkControlCommand.CommandType.VISIT_INDEX:
				var count = self.state.visit_count_for_container(self.state.current_pointer.container) - 1
				self.state.push_evaluation_stack(InkIntValue.new_with(count))

			InkControlCommand.CommandType.SEQUENCE_SHUFFLE_INDEX:
				var shuffle_index = self.next_sequence_shuffle_index()
				self.state.push_evaluation_stack(InkIntValue.new_with(shuffle_index))

			InkControlCommand.CommandType.START_THREAD:
				pass

			InkControlCommand.CommandType.DONE:
				if self.state.callstack.can_pop_thread:
					self.state.callstack.pop_thread()
				else:
					self.state.did_safe_exit = true
					self.state.current_pointer = InkPointer.null()

			InkControlCommand.CommandType.END:
				self.state.force_end()

			InkControlCommand.CommandType.LIST_FROM_INT:
				var int_val = Utils.as_or_null(self.state.pop_evaluation_stack(), "IntValue")
				var list_name_val = Utils.as_or_null(self.state.pop_evaluation_stack(), "StringValue")

				if int_val == null:
					self._throw_story_exception(
							"Passed non-integer when creating a list element from a numerical value."
					)
					return false

				var generated_list_value = null # ListValue

				var found_list_def: InkTryGetResult = self.list_definitions.try_list_get_definition(list_name_val.value)
				if found_list_def.exists:
					var found_item: InkTryGetResult = found_list_def.result.try_get_item_with_value(int_val.value)
					if found_item.exists:
						generated_list_value = InkListValue.new_with_single_item(
								found_item.result,
								int_val.value
						)
				else:
					self._throw_story_exception("Failed to find LIST called %s" % list_name_val.value)
					return false

				if generated_list_value == null:
					generated_list_value = InkListValue.new()

				self.state.push_evaluation_stack(generated_list_value)

			InkControlCommand.CommandType.LIST_RANGE:
				var max_value = Utils.as_or_null(self.state.pop_evaluation_stack(), "Value")
				var min_value = Utils.as_or_null(self.state.pop_evaluation_stack(), "Value")

				var target_list = Utils.as_or_null(self.state.pop_evaluation_stack(), "ListValue")

				if target_list == null || min_value == null || max_value == null:
					self._throw_story_exception("Expected list, minimum and maximum for LIST_RANGE")
					return false

				var result = target_list.value.list_with_sub_range(min_value.value_object, max_value.value_object)

				self.state.push_evaluation_stack(InkListValue.new_with(result))

			InkControlCommand.CommandType.LIST_RANDOM:

				var list_val = Utils.as_or_null(self.state.pop_evaluation_stack(), "ListValue")
				if list_val == null:
					self._throw_story_exception("Expected list for LIST_RANDOM")
					return false

				var list = list_val.value

				var new_list = null # InkList

				if list.size() == 0:
					new_list = InkList.new()
				else:
					var result_seed = self.state.story_seed + self.state.previous_random
					seed(result_seed)

					var next_random = randi()
					var list_item_index = next_random % list.size()

					# Iterator-based code in replaced with this code:
					if list_item_index < 0: list_item_index = 0
					if list_item_index >= list.size(): list_item_index = list.size() - 1

					var raw_random_item = list.raw_keys()[list_item_index]
					var random_item = InkListItem.from_serialized_key(raw_random_item)
					var random_item_value = list.get_raw(raw_random_item)

					new_list = InkList.new_with_origin(random_item.origin_name, self)
					new_list.set_raw(raw_random_item, random_item_value)

					self.state.previous_random = next_random

				self.state.push_evaluation_stack(InkListValue.new_with(new_list))

			_:
				error("unhandled ControlCommand: " + eval_command._to_string())
				return false

		return true

	elif Utils.as_or_null(content_obj, "VariableAssignment"):
		var var_ass = content_obj
		var assigned_val = self.state.pop_evaluation_stack()

		self.state.variables_state.assign(var_ass, assigned_val)

		return true

	elif Utils.as_or_null(content_obj, "VariableReference"):
		var var_ref = content_obj
		var found_value = null # InkValue

		if var_ref.path_for_count != null:
			var container = var_ref.container_for_count
			var count = self.state.visit_count_for_container(container)
			found_value = InkIntValue.new_with(count)
		else:
			found_value = self.state.variables_state.get_variable_with_name(var_ref.name)

			if found_value == null:
				warning(str("Variable not found: '", var_ref.name,
							"', using default value of 0 (false). this can ",
							"happen with temporary variables if the declaration ",
							"hasn't yet been hit. Globals are always given a default ",
							"value on load if a value doesn't exist in the save state."))
				found_value = InkIntValue.new_with(0)

		self.state.push_evaluation_stack(found_value)
		return true

	elif Utils.as_or_null(content_obj, "NativeFunctionCall"):
		var function = content_obj
		var func_params = self.state.pop_evaluation_stack(function.number_of_parameters)
		var result = function.call_with_parameters(func_params, _make_story_error_metadata())
		self.state.push_evaluation_stack(result)
		return true

	return false

# (String, bool, Array) -> void
func choose_path_string(path, reset_callstack = true, arguments = null):
	if async_we_cant("call ChoosePathString right now"):
		return

	emit_signal("on_choose_path_string", path, arguments)

	if reset_callstack:
		self.reset_callstack()
	else:
		if self.state.callstack.current_element.type == PushPopType.FUNCTION:
			var func_detail = ""
			var container = self.state.callstack.current_element.current_pointer.container
			if container != null:
				func_detail = "(" + container.path._to_string() + ") "

			Utils.throw_exception(
					"Story was running a function %s" % func_detail,
					"when you called ChoosePathString(%s) " % path,
					"- this is almost certainly not not what you want! Full stack trace: \n" +
					self.state.callstack.callstack_trace
			)

			return

	self.state.pass_arguments_to_evaluation_stack(arguments)
	self.choose_path(InkPath().new_with_components_string(path))


func async_we_cant(activity_str):
	if self._async_continue_active:
		Utils.throw_exception(
				"Can't %s. Story is in the middle of a ContinueAsync(). " % activity_str +
				"Make more ContinueAsync() calls or a single Continue() call beforehand."
		)

	return _async_continue_active


# (InkPath, bool)
func choose_path(p, incrementing_turn_index = true):
	self.state.set_chosen_path(p, incrementing_turn_index)

	self.visit_changed_containers_due_to_divert()


# (int) -> void
func choose_choice_index(choice_idx):
	var choices = self.current_choices
	self.__assert__(
			choice_idx >= 0 && choice_idx < choices.size(),
			"choice out of range"
	)

	var choice_to_choose = choices[choice_idx]
	emit_signal("on_make_choice", choice_to_choose)

	self.state.callstack.current_thread = choice_to_choose.thread_at_generation

	choose_path(choice_to_choose.target_path)


# (String) -> bool
func has_function(function_name: String) -> bool:
	return knot_container_with_name(function_name) != null


# (String, Array<Variant>, bool) -> Variant
func evaluate_function(
	function_name: String,
	arguments = null,
	return_text_output: bool = false
):
	# Like inkjs, evaluate_function behaves differently than the C# version.
	# In C#, you can pass a (second) parameter `out textOutput` to get the
	# text outputted by the function. Instead, we maintain the regular signature,
	# plus an optional third parameter return_text_output. If set to true, we will
	# return both the text_output and the returned value, as a Dictionary.

	emit_signal("on_evaluate_function", function_name, arguments)
	if async_we_cant("evaluate a function"):
		return

	if function_name == null:
		Utils.throw_exception("Function is null")
		return null
	elif function_name == "" || Utils.trim(function_name) == "":
		Utils.throw_exception("Function is empty or white space.")
		return null

	var func_container = knot_container_with_name(function_name)
	if func_container == null:
		Utils.throw_exception("Function doesn't exist: '%s'" % function_name)
		return null

	var output_stream_before = self.state.output_stream.duplicate() # Array<InkObject>
	_state.reset_output()

	self.state.start_function_evaluation_from_game(func_container, arguments)

	var string_output = ""
	while self.can_continue:
		string_output += self.continue()

	var text_output = string_output

	_state.reset_output(output_stream_before)

	var result = self.state.complete_function_evaluation_from_game()

	emit_signal("on_complete_evaluate_function", function_name, arguments, text_output, result)
	if return_text_output:
		return { "result": result, "output": text_output }
	else:
		return result


# (InkContainer) -> InkObject
func evaluate_expression(expr_container: InkContainer) -> InkObject:
	var start_callstack_height = self.state.callstack.elements.size()

	self.state.callstack.push(PushPopType.TUNNEL)

	_temporary_evaluation_container = expr_container

	self.state.go_to_start()

	var eval_stack_height = self.state.evaluation_stack.size()

	self.continue()

	_temporary_evaluation_container = null

	if self.state.callstack.elements.size() > start_callstack_height:
		self.state.pop_callstack()

	var end_stack_height = self.state.evaluation_stack.size()
	if end_stack_height > eval_stack_height:
		return self.state.pop_evaluation_stack()
	else:
		return null

var allow_external_function_fallbacks = false # bool


# (String, int) -> void
func call_external_function(func_name: String, number_of_arguments: int) -> void:
	var _func_def = null # ExternalFunctionDef
	var fallback_function_container = null # InkContainer

	if self._externals.has(func_name):
		_func_def = self._externals.get(func_name)
		if _func_def != null && !_func_def.lookahead_safe && self._state_snapshot_at_last_newline != null:
			self._saw_lookahead_unsafe_function_after_newline = true
			return

	if _func_def == null:
		if allow_external_function_fallbacks:
			fallback_function_container = self.knot_container_with_name(func_name)
			self.__assert__(
				fallback_function_container != null,
				"Trying to call EXTERNAL function '%s' " % func_name +
				"which has not been bound, and fallback ink function" +
				"could not be found."
			)

			self.state.callstack.push(
				PushPopType.FUNCTION,
				0,
				self.state.output_stream.size()
			)

			self.state.diverted_pointer = InkPointer.start_of(fallback_function_container)
			return
		else:
			self.__assert__(
				false,
				"Trying to call EXTERNAL function '%s' " % func_name +
				"which has not been bound (and ink fallbacks disabled)."
			)
			return

	var arguments = [] # Array<Variant>
	var i = 0
	while i < number_of_arguments:
		var popped_obj = Utils.as_or_null(self.state.pop_evaluation_stack(), "Value")
		var value_obj = popped_obj.value_object
		arguments.append(value_obj)

		i += 1

	arguments.invert()

	var func_result = _func_def.execute(arguments)

	var return_obj = null
	if func_result != null:
		return_obj = InkValue.create(func_result)
		self.__assert__(
			return_obj != null,
			"Could not create ink value from returned object of type %s" % \
			Utils.typename_of(typeof(func_result))
		)
	else:
		return_obj = InkVoid.new()

	self.state.push_evaluation_stack(return_obj)


# (String, Variant, ExternalFunctionDef, bool) -> void
func bind_external_function_general(
	func_name: String,
	object,
	method: String,
	lookahead_safe: bool = true
) -> void:
	if async_we_cant("bind an external function"):
		return

	self.__assert__(
			!_externals.has(func_name),
			"Function '%s' has already been bound." % func_name
	)

	_externals[func_name] = ExternalFunctionDef.new(object, method, lookahead_safe)


# try_coerce not needed.


# (String, Variant, String, bool) -> void
func bind_external_function(
	func_name: String,
	object,
	method_name: String,
	lookahead_safe: bool = false
) -> void:
	self.__assert__(
			object != null || method_name != null,
			"Can't bind a null function"
	)

	bind_external_function_general(func_name, object, method_name, lookahead_safe)


func unbind_external_function(func_name: String) -> void:
	if async_we_cant("unbind an external a function"):
		return

	self.__assert__(
			_externals.has(func_name),
			"Function '%s' has not been bound." % func_name
	)
	_externals.erase(func_name)


func validate_external_bindings() -> void:
	var missing_externals: InkStringSet = InkStringSet.new()

	validate_external_bindings_with(_main_content_container, missing_externals)
	_has_validated_externals = true

	if missing_externals.size() == 0:
		_has_validated_externals = true
	else:
		var message: String = "ERROR: Missing function binding for external %s: '%s' %s" % [
			"s" if missing_externals.size() > 1 else "",
			Utils.join("', '", missing_externals.to_array()),
			", and no fallback ink function found." if allow_external_function_fallbacks else " (ink fallbacks disabled)"
		]

		error(message)


func validate_external_bindings_with(o: InkContainer, missing_externals: InkStringSet) -> void:
	var container = Utils.as_or_null(o, "InkContainer")
	if container:
		for inner_content in o.content:
			var inner_container = Utils.as_or_null(inner_content, "InkContainer")
			if inner_container == null || !inner_container.has_valid_name:
				validate_external_bindings_with(inner_content, missing_externals)

		for inner_key in o.named_content:
			validate_external_bindings_with(
				Utils.as_or_null(o.named_content[inner_key], "InkObject"),
				missing_externals
			)
		return

	var divert = Utils.as_or_null(o, "Divert")
	if divert && divert.is_external:
		var name = divert.target_path_string

		if !_externals.has(name):
			if allow_external_function_fallbacks:
				var fallback_found = self.main_content_container.named_content.has(name)
				if !fallback_found:
					missing_externals.append(name)
			else:
				missing_externals.append(name)


# (String, Object, String) -> void
func observe_variable(variable_name: String, object, method_name: String) -> void:
	if async_we_cant("observe a new variable"):
		return

	if _variable_observers == null:
		_variable_observers = {}

	if !self.state.variables_state.global_variable_exists_with_name(variable_name):
		Utils.throw_exception(
				"Cannot observe variable '%s'" % variable_name +
				"because it wasn't declared in the ink story."
		)
		return

	if _variable_observers.has(variable_name):
		_variable_observers[variable_name].connect("variable_changed", object, method_name)
	else:
		var new_observer = VariableObserver.new(variable_name)
		new_observer.connect("variable_changed", object, method_name)

		_variable_observers[variable_name] = new_observer


# (Array<String>, Object, String) -> void
func observe_variables(variable_names: Array, object, method_name: String) -> void:
	for var_name in variable_names:
		observe_variable(var_name, object, method_name)


# (Object, String, String) -> void
# TODO: Rewrite this poor documentation and improve method beyond what
#       upstream offers.
#
# Potential cases:
#     - specific_variable_name is null, but object and method_name are both present
#       -> all signals, pointing to object & method_name and regardless of the
#          variable they listen to, are disconnected.
#
#     - specific_variable_name is present, but both object and method_name are null
#       -> all signals listening to changes of specific_variable_name are disconnected.
#
#     - object and method_name have mismatched presence
#       -> this is an unsuported case at the moment.
func remove_variable_observer(object = null, method_name = null, specific_variable_name = null):
	if async_we_cant("remove a variable observer"):
		return

	if _variable_observers == null:
		return

	if specific_variable_name != null:
		if _variable_observers.has(specific_variable_name):
			var observer = _variable_observers[specific_variable_name]
			if object != null && method_name != null:
				observer.disconnect("variable_changed", object, method_name)

				if observer.get_signal_connection_list("variable_changed").empty():
					_variable_observers.erase(specific_variable_name)
			else:
				var connections = observer.get_signal_connection_list("variable_changed");
				for connection in connections:
					observer.disconnect(connection.signal, connection.target, connection.method)

				_variable_observers.erase(specific_variable_name)

	elif object != null && method_name != null:
		var keys_to_remove = []
		for observer_key in _variable_observers:
			var observer = _variable_observers[observer_key]
			if observer.is_connected("variable_changed", object, method_name):
				observer.disconnect("variable_changed", object, method_name)

			if observer.get_signal_connection_list("variable_changed").empty():
				keys_to_remove.append(observer_key)

		for key in keys_to_remove:
			_variable_observers.erase(key)


func variable_state_did_change_event(variable_name: String, new_value_obj: InkObject) -> void:
	if _variable_observers == null:
		return

	if _variable_observers.has(variable_name):
		var observer = _variable_observers[variable_name]

		if !Utils.is_ink_class(new_value_obj, "Value"):
			Utils.throw_exception("Tried to get the value of a variable that isn't a standard type")
			return

		var val = new_value_obj

		observer.emit_signal("variable_changed", variable_name, val.value_object)


var global_tags setget , get_global_tags # Array<String>
func get_global_tags():
	return self.tags_at_start_of_flow_container_with_path_string("")

# (String) -> Array<String>?
func tags_for_content_at_path(path: String):
	return self.tags_at_start_of_flow_container_with_path_string(path)

# (String) -> Array<String>?
func tags_at_start_of_flow_container_with_path_string(path_string: String):
	var path = InkPath().new_with_components_string(path_string)

	var flow_container = content_at_path(path).container
	while (true):
		var first_content = flow_container.content[0]
		if Utils.is_ink_class(first_content, "InkContainer"):
			flow_container = first_content
		else: break

	var tags = null # Array<String>
	for c in flow_container.content:
		var tag = Utils.as_or_null(c , "Tag")
		if tag:
			if tags == null: tags = [] # Array<String> ()
			tags.append(tag.text)
		else: break

	return tags


func build_string_of_container() -> String:
	# TODO: Implement
	return ""


func build_string_of_container_with(container: InkContainer) -> String:
	# TODO: Implement
	return ""


func next_content() -> void:

	self.state.previous_pointer = self.state.current_pointer

	if !self.state.diverted_pointer.is_null:

		self.state.current_pointer = self.state.diverted_pointer
		self.state.diverted_pointer = InkPointer.null()

		self.visit_changed_containers_due_to_divert()

		if !self.state.current_pointer.is_null:
			return

	var successful_pointer_increment = self.increment_content_pointer()

	if !successful_pointer_increment:
		var did_pop = false

		if self.state.callstack.can_pop_type(PushPopType.FUNCTION):

			self.state.pop_callstack(PushPopType.FUNCTION)

			if self.state.in_expression_evaluation:
				self.state.push_evaluation_stack(InkVoid.new())

			did_pop = true
		elif self.state.callstack.can_pop_thread:
			self.state.callstack.pop_thread()

			did_pop = true
		else:
			self.state.try_exit_function_evaluation_from_game()

		if did_pop && !self.state.current_pointer.is_null:
			self.next_content()


func increment_content_pointer() -> bool:
	var successful_increment = true

	var pointer = self.state.callstack.current_element.current_pointer
	pointer = InkPointer.new(pointer.container, pointer.index + 1)

	while pointer.index >= pointer.container.content.size():

		successful_increment = false

		var next_ancestor = Utils.as_or_null(pointer.container.parent, "InkContainer")
		if !next_ancestor:
			break

		var index_in_ancestor = next_ancestor.content.find(pointer.container)
		if index_in_ancestor == -1:
			break

		pointer = InkPointer.new(next_ancestor, index_in_ancestor + 1)

		successful_increment = true

	if !successful_increment: pointer = InkPointer.null()

	var current_element = self.state.callstack.current_element
	current_element.current_pointer = pointer

	return successful_increment


func try_follow_default_invisible_choice() -> bool:
	var all_choices = _state.current_choices

	var invisible_choices = []
	for c in all_choices:
		if c.is_invisible_default:
			invisible_choices.append(c)

	if invisible_choices.size() == 0 || all_choices.size() > invisible_choices.size():
		return false

	var choice = invisible_choices[0]

	var callstack = self.state.callstack
	callstack.current_thread = choice.thread_at_generation

	if self._state_snapshot_at_last_newline != null:
		self.state.callstack.current_thread = self.state.callstack.fork_thread()

	choose_path(choice.target_path, false)

	return true


func next_sequence_shuffle_index() -> int:
	var num_elements_int_val = Utils.as_or_null(self.state.pop_evaluation_stack(), "IntValue")
	if num_elements_int_val == null:
		error("expected number of elements in sequence for shuffle index")
		return 0

	var seq_container = self.state.current_pointer.container

	var num_elements = num_elements_int_val.value

	var seq_count_val = Utils.as_or_null(self.state.pop_evaluation_stack(), "IntValue")
	var seq_count = seq_count_val.value
	var loop_index = seq_count / num_elements
	var iteration_index = seq_count % num_elements

	var seq_path_str = seq_container.path._to_string()
	var sequence_hash = 0
	for c in seq_path_str:
		sequence_hash += int(c)

	var random_seed = sequence_hash + loop_index + self.state.story_seed
	seed(random_seed)

	var unpicked_indices = [] # Array<int>
	var i = 0
	while (i < num_elements):
		unpicked_indices.append(i)
		i += 1

	i = 0
	while (i <= iteration_index):
		var chosen = randi() % unpicked_indices.size()
		var chosen_index = unpicked_indices[chosen]
		unpicked_indices.remove(chosen)

		if i == iteration_index:
			return chosen_index

		i += 1

	Utils.throw_exception("Should never reach here")
	return -1


# (String, bool) -> void
func error(message: String, use_end_line_number: bool = false) -> void:
	Utils.throw_story_exception(message, use_end_line_number, _make_story_error_metadata())


# (String) -> void
func warning(message: String) -> void:
	add_error(message, true)


# (String, bool, bool) -> void
func add_error(message: String, is_warning: bool = false, use_end_line_number: bool = false) -> void:
	# This method differs from upstream, because GDScript doesn't support exceptions.
	# Error formatting is handled by add_error_with_metadata, because there's a new
	# method `add_story_error` used by `continue_internal` to report errors
	# that occured during the step.
	_add_error_with_metadata(
		message,
		is_warning,
		use_end_line_number,
		self.current_debug_metadata,
		self.state.current_pointer
	)


# (StoryError) -> void
#
# This method doesn't exist in upstream. It's used by `continue_internal` to
# report error that occured during the step.
func add_story_error(story_error: StoryError) -> void:
	_add_error_with_metadata(
			story_error.message,
			false,
			story_error.use_end_line_number,
			story_error.metadata.debug_metadata,
			story_error.metadata.pointer
	)


# (bool, String?, Array<Variant>?) -> void
func __assert__(condition: bool, message = null, format_params = null) -> void:
	if condition == false:
		if message == null:
			message = "Story assert"

		if format_params != null && format_params.size() > 0:
			message = message % format_params

		if self.current_debug_metadata != null:
			Utils.throw_exception("%s %s" % [message, str(self.current_debug_metadata)])
		else:
			Utils.throw_exception(message)


var current_debug_metadata: InkDebugMetadata setget , get_current_debug_metadata
func get_current_debug_metadata() -> InkDebugMetadata:
	var dm # DebugMetadata

	var pointer = self.state.current_pointer
	if !pointer.is_null:
		dm = pointer.resolve().debug_metadata
		if dm != null:
			return dm

	var i = self.state.callstack.elements.size() - 1
	while (i >= 0):
		pointer = self.state.callstack.elements[i].current_pointer
		if !pointer.is_null && pointer.resolve() != null:
			dm = pointer.resolve().debug_metadata
			if dm != null:
				return dm

		i -= 1

	i = self.state.output_stream.size() - 1
	while(i >= 0):
		var output_obj = self.state.output_stream[i]
		dm = output_obj.debug_metadata
		if dm != null:
			return dm

		i -= 1

	return null


var current_line_number: int setget , get_current_line_number
func get_current_line_number() -> int:
	var dm = self.current_debug_metadata
	if dm != null:
		return dm.start_line_number

	return 0


# InkContainer?
var main_content_container setget , get_main_content_container
func get_main_content_container():
	if _temporary_evaluation_container:
		return _temporary_evaluation_container
	else:
		return _main_content_container


# InkContainer?
var _main_content_container = null
# ListDefinitionsOrigin?
var _list_definitions = null

# Dictionary<String, ExternalFunctionDef>?
var _externals = null
# Dictionary<String, VariableObserver>?
var _variable_observers = null

var _has_validated_externals: bool = false

# InkContainer?
var _temporary_evaluation_container = null

# StoryState?
var _state = null

var _async_continue_active: bool = false
# StoryState?
var _state_snapshot_at_last_newline = null
var _saw_lookahead_unsafe_function_after_newline: bool = false # bool

var _recursive_continue_count: int = 0

var _async_saving: bool = false

# Profiler?
var _profiler = null

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type: String) -> bool:
	return type == "Story" || .is_class(type)


func get_class() -> String:
	return "Story"


func connect_exception(target: Object, method: String, binds = [], flags = 0) -> int:
	var runtime = _get_runtime()
	if runtime == null:
		return ERR_UNAVAILABLE

	if runtime.is_connected("exception_raised", target, method):
		return OK

	return runtime.connect("exception_raised", target, method, binds, flags)


func _enable_story_exception_recording(enable: bool) -> void:
	var runtime = _get_runtime()
	if runtime != null:
		runtime.record_story_exceptions = enable


func _get_and_clear_recorded_story_exceptions() -> Array:
	var runtime = _get_runtime()
	if runtime == null:
		return []

	var exceptions = runtime.current_story_exceptions
	runtime.current_story_exceptions = []

	return exceptions


func _add_error_with_metadata(
	message: String,
	is_warning: bool = false,
	use_end_line_number: bool = false,
	dm = null,
	current_pointer = InkPointer.null()
) -> void:
	var error_type_str = "WARNING" if is_warning else "ERROR"

	if dm != null:
		var line_num = dm.end_line_number if use_end_line_number else dm.start_line_number
		message = "RUNTIME %s: '%s' line %s: %s" % [error_type_str, dm.file_name, line_num, message]
	elif !current_pointer.is_null:
		message = "RUNTIME %s: (%s): %s" % [error_type_str, current_pointer.path._to_string(), message]
	else:
		message = "RUNTIME " + error_type_str + ": " + message

	self.state.add_error(message, is_warning)

	if !is_warning:
		self.state.force_end()


func _throw_story_exception(message: String):
	Utils.throw_story_exception(message, false, _make_story_error_metadata())


# This method is used to ensure that the debug metadata and pointer used
# to report errors are the ones at the moment the error occured (and not
# the current one). Since GDScript doesn't have exceptions, errors may be
# stored until they can be processed at the end of `continue_internal`.
func _make_story_error_metadata():
	return StoryErrorMetadata.new(self.current_debug_metadata, self.state.current_pointer)


# ############################################################################ #

var Json setget , get_Json
func get_Json():
	return _Json.get_ref()
var _Json = WeakRef.new()

var _error_raised_during_step = []

func _initialize_runtime():
	var ink_runtime = _get_runtime()

	Utils.__assert__(
		ink_runtime != null,
		str("Could not retrieve 'InkRuntime' singleton from the scene tree.")
	)

	_Json = weakref(ink_runtime.json)

func _get_runtime():
	return Engine.get_main_loop().root.get_node("__InkRuntime")


# ############################################################################ #

class VariableObserver extends Reference:
	var variable_name: String

	signal variable_changed(variable_name, new_value)

	func _init(variable_name: String):
		self.variable_name = variable_name


class ExternalFunctionDef extends InkBase:
	var object: Object
	var method: String
	var lookahead_safe: bool

	func _init(object: Object, method: String, lookahead_safe: bool):
		# If object is not a reference, you're responsible to ensure it's
		# still allocated.
		self.object = weakref(object)
		self.method = method
		self.lookahead_safe = lookahead_safe

	# (Array<Variant>) -> Variant
	func execute(params: Array):
		var object_ref = object.get_ref()
		if object_ref != null:
			return object_ref.callv(method, params)
		else:
			Utils.throw_exception(
					"Object binded to %s has been deallocated, cannot execute." % method
			)
			return null
