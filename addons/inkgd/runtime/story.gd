# warning-ignore-all:shadowed_variable
# warning-ignore-all:unused_class_variable
# ############################################################################ #
# Copyright © 2015-present inkle Ltd.
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://addons/inkgd/runtime/ink_object.gd"

const INK_VERSION_CURRENT = 20
const INK_VERSION_MINIMUM_COMPATIBLE = 18

# ############################################################################ #
# Imports
# ############################################################################ #

var PushPopType = preload("res://addons/inkgd/runtime/push_pop.gd").PushPopType
var ErrorType = preload("res://addons/inkgd/runtime/error.gd").ErrorType

var ListDefinitionsOrigin = load("res://addons/inkgd/runtime/list_definitions_origin.gd")
var StoryState = load("res://addons/inkgd/runtime/story_state.gd")

var Pointer = load("res://addons/inkgd/runtime/pointer.gd")
var ControlCommand = load("res://addons/inkgd/runtime/control_command.gd")
var Ink = load("res://addons/inkgd/runtime/value.gd")
var Stopwatch = load("res://addons/inkgd/runtime/extra/stopwatch.gd")
var InkList = load("res://addons/inkgd/runtime/ink_list.gd")
var InkListItem = load("res://addons/inkgd/runtime/ink_list_item.gd")
var StringSet = load("res://addons/inkgd/runtime/extra/string_set.gd")

var Choice = load("res://addons/inkgd/runtime/choice.gd")
var Void = load("res://addons/inkgd/runtime/void.gd")

var Profiler = load("res://addons/inkgd/runtime/profiler.gd")

var SimpleJson = load("res://addons/inkgd/runtime/simple_json.gd")

# ############################################################################ #

var current_choices setget , get_current_choices # Array<Choice>
func get_current_choices():
	var choices = [] # Array<Choice>

	for c in self._state.current_choices:
		if !c.is_invisible_default:
			c.index = choices.size()
			choices.append(c)

	return choices

var current_text setget , get_current_text # String
func get_current_text():
	if async_we_cant("call currentText since it's a work in progress"):
		return null

	return self.state.current_text

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

var state setget , get_state # StoryState
func get_state():
	return self._state

signal on_error(message, type)

signal on_did_continue()

signal on_make_choice(choice)

signal on_evaluate_function(function_name, arguments)

signal on_complete_evaluate_function(function_name, arguments, text_output, result)

signal on_choose_path_string(path, arguments)

# () -> Profiler
func start_profiling():
	if async_we_cant ("Start Profiling"):
		return

	_profiler = Profiler.new()
	return _profiler

# () -> void
func end_profiling():
	_profiler = null

# (InkContainer, Array<ListDefinition>) -> void
func _init_with(content_container, lists = null):
	_initialize_runtime()
	self._main_content_container = content_container

	if lists != null:
		self._list_definitions = ListDefinitionsOrigin.new(lists)

	self._externals = {} # Dictionary<String, ExternalFunctionDef>

# (String) -> Story
func _init(json_string):
	_init_with(null)

	var root_object = SimpleJson.text_to_dictionary(json_string)

	var version_obj = root_object["inkVersion"]
	if version_obj == null:
		Utils.throw_exception(str("ink version number not found. ",
								  "Are you sure it's a valid .ink.json file?"))
		return

	var format_from_file = int(version_obj)
	if format_from_file > INK_VERSION_CURRENT:
		Utils.throw_exception(str("Version of ink used to build story was newer ",
								  "than the current version of the engine"))
		return
	elif format_from_file < INK_VERSION_MINIMUM_COMPATIBLE:
		Utils.throw_exception(str("Version of ink used to build story is too old ",
								  "to be loaded by this version of the engine"))
		return
	elif format_from_file != INK_VERSION_CURRENT:
		print(str("WARNING: Version of ink used to build story doesn't match ",
				  "current version of engine. Non-critical, but recommend synchronising."))

	var root_token = root_object["root"]
	if root_token == null:
		Utils.throw_exception(str("Root node for ink not found. Are you sure it's a valid ",
								  ".ink.json file?"))
		return

	if root_object.has("listDefs"):
		self._list_definitions = self.Json.jtoken_to_list_definitions(root_object["listDefs"])

	self._main_content_container = Utils.as_or_null(self.Json.jtoken_to_runtime_object(root_token),
													"InkContainer")

	self.reset_state()

# () -> String
func to_json():
	var writer = SimpleJson.Writer.new()
	to_json_with_writer(writer)
	return writer.to_string()

func write_root_property(writer):
	self.Json.write_runtime_container(writer, self._main_content_container)

# (self.Json.Writer) -> String
func to_json_with_writer(writer):
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
func reset_state():
	if async_we_cant ("ResetState"):
		return

	self._state = StoryState.new(self)
	self._state.variables_state.connect("variable_changed", self, "variable_state_did_change_event")

	self.reset_globals()

# () -> void
func reset_errors():
	self._state.reset_errors()

# () -> void
func reset_callstack():
	if async_we_cant("ResetCallstack"):
		return

	self._state.force_end()

# () -> void
func reset_globals():
	if (self._main_content_container.named_content.has("global decl")):
		var original_pointer = self.state.current_pointer.duplicate()

		self.choose_path(InkPath().new_with_components_string("global decl"), false)

		self.continue_internal()

		self.state.current_pointer = original_pointer

	self.state.variables_state.snapshot_default_globals()

func switch_flow(flow_name):
	if async_we_cant("SwitchFlow"):
		return

	if self._async_saving:
		Utils.throw_exception("Story is already in background saving mode, can't switch flow to " + flow_name)

	self.state.switch_flow_internal(flow_name)

func remove_flow(flow_name):
	self.state.remove_flow_internal(flow_name)

func switch_to_default_flow():
	self.state.switch_to_default_flow_internal()

# () -> String
func continue():
	self.continue_async(0)
	return self.current_text

var can_continue setget , get_continue # bool
func get_continue():
	return self.state.can_continue

var async_continue_complete setget , get_async_continue_complete # bool
func get_async_continue_complete():
	return !self._async_continue_active

# (float) -> void
func continue_async(millisecs_limit_async):
	if !self._has_validated_externals:
		self.validate_external_bindings()

	continue_internal(millisecs_limit_async)

# (float) -> void
func continue_internal(millisecs_limit_async = 0):
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

	var duration_stopwatch = Stopwatch.new()
	duration_stopwatch.start()

	var output_stream_ends_in_newline = false
	self._saw_lookahead_unsafe_function_after_newline = false
	var first_time = true
	while (first_time || self.can_continue):
		first_time = false

		output_stream_ends_in_newline = self.continue_single_step()
		if _error_raised_during_step.size() > 0:
			for error in _error_raised_during_step:
				add_error(error.message, false, error.use_end_line_number)
			_error_raised_during_step.clear()

			# Restore ability to continue.
			push_warning("The story has recovered from an exception and may be in an inconsistent state. Proceed with care.")
			var InkRuntime = _get_runtime()
			if InkRuntime != null:
				InkRuntime.should_interrupt = false
			break

		if output_stream_ends_in_newline:
			break

		if _async_continue_active && duration_stopwatch.elapsed_milliseconds > millisecs_limit_async:
			break

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
			Utils.throw_story_exception(exception)

# ()
func continue_single_step():
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
func calculate_newline_output_state_change(prev_text, curr_text, prev_tag_count, curr_tag_count):
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

# () -> String
func continue_maximally():
	if async_we_cant("ContinueMaximally"):
		return null

	var _str = ""

	while (self.can_continue):
		_str += self.continue()

	return _str

# (InkPath) -> SearchResult
func content_at_path(path):
	return self.main_content_container.content_at_path(path)

# (String) -> InkContainer
func knot_container_with_name(name):
	if self.main_content_container.named_content.has(name):
		return Utils.as_or_null(self.main_content_container.named_content[name], "InkContainer")

	return null

# (InkPath) -> Result<Pointer>
func pointer_at_path(path):
	if (path.length == 0):
		return Pointer.null()

	var p = Pointer.new()

	var path_length_to_use = path.length

	var result = null # SearchResult
	if (path.last_component.is_index):
		path_length_to_use = path.length - 1
		result = self.main_content_container.content_at_path(path, 0, path_length_to_use)
		p.container = result.container
		p.index = path.last_component.index
	else:
		result = self.main_content_container.content_at_path(path)
		p.container = result.container
		p.index = -1

	if result.obj == null || result.obj == self.main_content_container && path_length_to_use > 0:
		error(str("Failed to find content at path '", path.to_string(),
				  "', and no approximation of it was possible."))
	elif result.approximate:
		warning(str("Failed to find content at path '", path,
					"', so it was approximated to: '", result.obj.path.to_string(), "'."))

	return p

# () -> StoryState
func state_snapshot():
	self._state_snapshot_at_last_newline = self._state
	self._state = self._state.copy_and_start_patching()

# (StoryState) -> void
func restore_state_snapshot():
	self._state_snapshot_at_last_newline.restore_after_patch()

	self._state = self._state_snapshot_at_last_newline
	self._state_snapshot_at_last_newline = null

	if !self._async_saving:
		self._state.apply_any_patch()

# () -> void
func discard_snapshot():
	if !self._async_saving:
		self._state.apply_any_patch()

	self._state_snapshot_at_last_newline = null

# () -> void
func copy_state_for_background_thread_save():
	if async_we_cant("start saving on a background thread"):
		return

	if self._async_saving:
		Utils.throw_exception("Story is already in background saving mode, can't call CopyStateForBackgroundThreadSave again!")
		return

	var state_to_save = self._state
	self._state = self._state.copy_and_start_patching()
	self._async_saving = true

	return state_to_save

# () -> void
func background_save_complete():
	if self._state_snapshot_at_last_newline == null:
		_state.apply_any_patch()

	self._async_saving = false

# () -> void
func step():
	var InkRuntime = _get_runtime()
	if InkRuntime != null && InkRuntime.should_interrupt:
		self.state.force_end()

	var should_add_to_stream = true

	var pointer = self.state.current_pointer.duplicate()
	if pointer.is_null:
		return

	var container_to_enter = Utils.as_or_null(pointer.resolve(), "InkContainer")
	while (container_to_enter):
		self.visit_container(container_to_enter, true)

		if container_to_enter.content.size() == 0:
			break

		pointer = Pointer.start_of(container_to_enter)
		container_to_enter = Utils.as_or_null(pointer.resolve(), "InkContainer")

	self.state.current_pointer = pointer.duplicate()

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
			current_content_obj = Ink.VariablePointerValue.new_with_context(var_pointer.variable_name, context_idx)

		if self.state.in_expression_evaluation:
			self.state.push_evaluation_stack(current_content_obj)
		else:
			self.state.push_to_output_stream(current_content_obj)

	self.next_content()

	var control_cmd = Utils.as_or_null(current_content_obj, "ControlCommand")
	if control_cmd && control_cmd.command_type == ControlCommand.CommandType.START_THREAD:
		self.state.callstack.push_thread()

# (InkContainer, bool) -> void
func visit_container(container, at_start):
	if !container.counting_at_start_only || at_start:
		if container.visits_should_be_counted:
			self.state.increment_visit_count_for_container(container)

		if container.turn_index_should_be_counted:
			self.state.record_turn_index_visit_to_container(container)

var _prev_containers = [] # Array<Container>
func visit_changed_containers_due_to_divert():
	var previous_pointer = self.state.previous_pointer.duplicate()
	var pointer = self.state.current_pointer.duplicate()

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

# (ChoicePoint) -> Choice
func process_choice(choice_point):
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

	var choice = Choice.new()
	choice.target_path = choice_point.path_on_choice
	choice.source_path = choice_point.path.to_string()
	choice.is_invisible_default = choice_point.is_invisible_default
	choice.thread_at_generation = self.state.callstack.fork_thread()

	choice.text = Utils.trim(start_text + choice_only_text, [" ", "\t"])

	return choice

# (InkObject) -> bool
func is_truthy(obj):
	var truthy = false
	if Utils.is_ink_class(obj, "Value"):
		var val = obj

		if Utils.is_ink_class(obj, "DivertTargetValue"):
			var div_target = val
			error(str("Shouldn't use a divert target (to ", div_target.target_path.to_string(),
					  ") as a conditional value. Did you intend a function call 'likeThis()'",
					  " or a read count check 'likeThis'? (no arrows)"))
			return false

		return val.is_truthy

	return truthy

# (InkObject) -> bool
func perform_logic_and_flow_control(content_obj):
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
			self.state.diverted_pointer = current_divert.target_pointer.duplicate()

		if current_divert.pushes_to_stack:
			self.state.callstack.push(
				current_divert.stack_push_type,
				0,
				self.state.output_stream.size()
			)

		if self.state.diverted_pointer.is_null && !current_divert.is_external:
			if current_divert && current_divert.debug_metadata.source_name != null:
				error("Divert target doesn't exist: " + current_divert.debug_metadata.source_name)
				return false
			else:
				error("Divert resolution failed: " + current_divert.to_string())
				return false

		return true
	elif Utils.is_ink_class(content_obj, "ControlCommand"):
		var eval_command = content_obj

		match eval_command.command_type:

			ControlCommand.CommandType.EVAL_START:
				self.assert(self.state.in_expression_evaluation == false, "Already in expression evaluation?")
				self.state.in_expression_evaluation = true

			ControlCommand.CommandType.EVAL_END:
				self.assert(self.state.in_expression_evaluation == true, "Not in expression evaluation mode")
				self.state.in_expression_evaluation = false

			ControlCommand.CommandType.EVAL_OUTPUT:
				if self.state.evaluation_stack.size() > 0:
					var output = self.state.pop_evaluation_stack()

					if !Utils.as_or_null(output, "Void"):
						var text = Ink.StringValue.new_with(output.to_string())
						self.state.push_to_output_stream(text)

			ControlCommand.CommandType.NO_OP:
				pass

			ControlCommand.CommandType.DUPLICATE:
				self.state.push_evaluation_stack(self.state.peek_evaluation_stack())

			ControlCommand.CommandType.POP_EVALUATED_VALUE:
				self.state.pop_evaluation_stack()

			ControlCommand.CommandType.POP_FUNCTION, ControlCommand.CommandType.POP_TUNNEL:
				var is_pop_function = (eval_command.command_type == ControlCommand.CommandType.POP_FUNCTION)
				var pop_type = PushPopType.FUNCTION if is_pop_function else PushPopType.TUNNEL

				var override_tunnel_return_target = null # DivertTargetValue
				if pop_type == PushPopType.TUNNEL:
					var popped = self.state.pop_evaluation_stack()
					override_tunnel_return_target = Utils.as_or_null(popped, "DivertTargetValue")
					if override_tunnel_return_target == null:
						self.assert(Utils.is_ink_class(popped, "Void"),
									"Expected void if ->-> doesn't override target")

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

			ControlCommand.CommandType.BEGIN_STRING:
				self.state.push_to_output_stream(eval_command)

				self.assert(self.state.in_expression_evaluation == true,
							"Expected to be in an expression when evaluating a string")
				self.state.in_expression_evaluation = false

			ControlCommand.CommandType.END_STRING:
				var content_stack_for_string = [] # Stack<InkObject>

				var output_count_consumed = 0
				var i = self.state.output_stream.size() - 1
				while (i >= 0):
					var obj = self.state.output_stream[i]

					output_count_consumed += 1

					var command = Utils.as_or_null(obj, "ControlCommand")
					if (command != null &&
						command.command_type == ControlCommand.CommandType.BEGIN_STRING):
						break

					if Utils.is_ink_class(obj, "StringValue"):
						content_stack_for_string.push_front(obj)

					i -= 1

				self.state.pop_from_output_stream(output_count_consumed)

				var _str = ""
				for c in content_stack_for_string:
					_str += c.to_string()

				self.state.in_expression_evaluation = true
				self.state.push_evaluation_stack(Ink.StringValue.new_with(_str))

			ControlCommand.CommandType.CHOICE_COUNT:
				var choice_count = self.state.generated_choices.size()
				self.state.push_evaluation_stack(Ink.IntValue.new_with(choice_count))

			ControlCommand.CommandType.TURNS:
				self.state.push_evaluation_stack(Ink.IntValue.new_with(self.state.current_turn_index + 1))

			ControlCommand.CommandType.TURNS_SINCE, ControlCommand.CommandType.READ_COUNT:
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
					if eval_command.command_type == ControlCommand.CommandType.TURNS_SINCE:
						either_count = self.state.turns_since_for_container(container)
					else:
						either_count = self.state.visit_count_for_container(container)
				else:
					if eval_command.command_type == ControlCommand.CommandType.TURNS_SINCE:
						either_count = -1
					else:
						either_count = 0

					warning(str("Failed to find container for ", eval_command.to_string(),
								" lookup at ", divert_target.target_path.to_string()))

				self.state.push_evaluation_stack(Ink.IntValue.new_with(either_count))

			ControlCommand.CommandType.RANDOM:
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
				self.state.push_evaluation_stack(Ink.IntValue.new_with(chosen_value))

				self.state.previous_random = next_random

			ControlCommand.CommandType.SEED_RANDOM:
				var _seed = Utils.as_or_null(self.state.pop_evaluation_stack(), "IntValue")
				if _seed == null:
					error("Invalid value passed to SEED_RANDOM")
					return false

				self.state.story_seed = _seed.value
				self.state.previous_random = 0

				self.state.push_evaluation_stack(Void.new())

			ControlCommand.CommandType.VISIT_INDEX:
				var count = self.state.visit_count_for_container(self.state.current_pointer.container) - 1
				self.state.push_evaluation_stack(Ink.IntValue.new_with(count))

			ControlCommand.CommandType.SEQUENCE_SHUFFLE_INDEX:
				var shuffle_index = self.next_sequence_shuffle_index()
				self.state.push_evaluation_stack(Ink.IntValue.new_with(shuffle_index))

			ControlCommand.CommandType.START_THREAD:
				pass

			ControlCommand.CommandType.DONE:
				if self.state.callstack.can_pop_thread:
					self.state.callstack.pop_thread()
				else:
					self.state.did_safe_exit = true
					self.state.current_pointer = Pointer.null()

			ControlCommand.CommandType.END:
				self.state.force_end()

			ControlCommand.CommandType.LIST_FROM_INT:
				var int_val = Utils.as_or_null(self.state.pop_evaluation_stack(), "IntValue")
				var list_name_val = Utils.as_or_null(self.state.pop_evaluation_stack(), "StringValue")

				if int_val == null:
					Utils.throw_story_exception("Passed non-integer when creating a list element from a numerical value.")
					return false

				var generated_list_value = null # ListValue

				var found_list_def = self.list_definitions.try_list_get_definition(list_name_val.value)
				if found_list_def.exists:
					var found_item = found_list_def.result.try_get_item_with_value(int_val.value)
					if found_item.exists:
						generated_list_value = Ink.ListValue.new_with_single_item(found_item.result, int_val.value)
				else:
					Utils.throw_story_exception("Failed to find LIST called " + list_name_val.value)
					return null

				if generated_list_value == null:
					generated_list_value = Ink.ListValue.new()

				self.state.push_evaluation_stack(generated_list_value)

			ControlCommand.CommandType.LIST_RANGE:
				var max_value = Utils.as_or_null(self.state.pop_evaluation_stack(), "Value")
				var min_value = Utils.as_or_null(self.state.pop_evaluation_stack(), "Value")

				var target_list = Utils.as_or_null(self.state.pop_evaluation_stack(), "ListValue")

				if target_list == null || min_value == null || max_value == null:
					Utils.throw_story_exception("Expected list, minimum and maximum for LIST_RANGE")
					return false

				var result = target_list.value.list_with_sub_range(min_value.value_object, max_value.value_object)

				self.state.push_evaluation_stack(Ink.ListValue.new_with(result))

			ControlCommand.CommandType.LIST_RANDOM:

				var list_val = Utils.as_or_null(self.state.pop_evaluation_stack(), "ListValue")
				if list_val == null:
					Utils.throw_story_exception("Expected list for LIST_RANDOM")
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

				self.state.push_evaluation_stack(Ink.ListValue.new_with(new_list))

			_:
				error("unhandled ControlCommand: " + eval_command.to_string())
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
			found_value = Ink.IntValue.new_with(count)
		else:
			found_value = self.state.variables_state.get_variable_with_name(var_ref.name)

			if found_value == null:
				warning(str("Variable not found: '", var_ref.name,
							"', using default value of 0 (false). this can ",
							"happen with temporary variables if the declaration",
							"hasn't yet been hit. Globals are always given a default",
							"value on load if a value doesn't exist in the save state."))
				found_value = Ink.IntValue.new_with(0)

		self.state.push_evaluation_stack(found_value)
		return true

	elif Utils.as_or_null(content_obj, "NativeFunctionCall"):
		var function = content_obj
		var func_params = self.state.pop_evaluation_stack(function.number_of_parameters)
		var result = function.call(func_params)
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
				func_detail = "(" + container.path.to_string() + ") "

			Utils.throw_story_exception(str(
				"Story was running a function ", func_detail,
				"when you called ChoosePathString(", path,
				") - this is almost certainly not not what you want! Full stack trace: \n",
				self.state.callstack.callstack_trace
			))

			return

	self.state.pass_arguments_to_evaluation_stack(arguments)
	self.choose_path(InkPath().new_with_components_string(path))

func async_we_cant(activity_str):
	if self._async_continue_active:
		Utils.throw_story_exception(str(
			"Can't ", activity_str, ". Story is in the middle of a ContinueAsync().",
			"Make more ContinueAsync() calls or a single Continue() call beforehand."
		))

	return _async_continue_active

# (InkPath, bool)
func choose_path(p, incrementing_turn_index = true):
	self.state.set_chosen_path(p, incrementing_turn_index)

	self.visit_changed_containers_due_to_divert()

# (int) -> void
func choose_choice_index(choice_idx):
	var choices = self.current_choices
	self.assert(choice_idx >= 0 && choice_idx < choices.size(), "choice out of range")

	var choice_to_choose = choices[choice_idx]
	emit_signal("on_make_choice", choice_to_choose)

	self.state.callstack.current_thread = choice_to_choose.thread_at_generation

	choose_path(choice_to_choose.target_path)

# (String) -> bool
func has_function(function_name):
	return knot_container_with_name(function_name) != null

# (String, Array<Variant<) -> Variant
func evaluate_function(function_name, arguments = null, return_text_output = false):
	# Like inkjs, evaluate_function behaves differently than the C# version.
	# In C#, you can pass a (second) parameter `out textOutput` to get the
	# text outputted by the function. Instead, we maintain the regular signature,
	# plus an optional third parameter return_text_output. If set to true, we will
	# return both the text_output and the returned value, as a Dictionary.

	emit_signal("on_evaluate_function", function_name, arguments)
	if async_we_cant("evaluate a function"):
		return

	if function_name == null:
		Utils.throw_story_exception ("Function is null")
		return null
	elif function_name == "" || Utils.trim(function_name) == "":
		Utils.throw_story_exception ("Function is empty or white space.")
		return null

	var func_container = knot_container_with_name(function_name)
	if func_container == null:
		Utils.throw_story_exception ("Function doesn't exist: '" + function_name + "'")
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
func evaluate_expression(expr_container):
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
func call_external_function(func_name, number_of_arguments):
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
			self.assert(fallback_function_container != null,
						str("Trying to call EXTERNAL function '", func_name,
							"' which has not been bound, and fallback ink function could not be found."))

			self.state.callstack.push(
				PushPopType.FUNCTION,
				0,
				self.state.output_stream.size()
			)

			self.state.diverted_pointer = Pointer.start_of(fallback_function_container)
			return
		else:
			self.assert(false,
						str("Trying to call EXTERNAL function '", func_name,
							"' which has not been bound (and ink fallbacks disabled)."))

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
		return_obj = Ink.Value.create(func_result)
		self.assert(return_obj != null,
					str("Could not create ink value from returned object of type ",
						typeof(func_result)))
	else:
		return_obj = Void.new()

	self.state.push_evaluation_stack(return_obj)

# (String, ExternalFunctionDef) -> void
func bind_external_function_general(func_name, object, method, lookahead_safe = true):
	if async_we_cant("bind an external function"):
		return

	self.assert(!_externals.has(func_name),
				str("Function '", func_name, "' has already been bound."))
	_externals[func_name] = ExternalFunctionDef.new(object, method, lookahead_safe)

# try_coerce not needed.

# (String, Variant, String) -> void
func bind_external_function(func_name, object, method_name, lookahead_safe = false):
	self.assert(object != null || method_name != null, "Can't bind a null function")

	bind_external_function_general(func_name, object, method_name, lookahead_safe)

# (String) -> void
func unbind_external_function(func_name):
	if async_we_cant("unbind an external a function"):
		return

	self.assert(_externals.has(func_name), str("Function '", func_name, "' has not been bound."))
	_externals.erase(func_name)

func validate_external_bindings():
	var missing_externals = StringSet.new()

	validate_external_bindings_with(_main_content_container, missing_externals)
	_has_validated_externals = true

	if missing_externals.size() == 0:
		_has_validated_externals = true
	else:
		var message = "ERROR: Missing function binding for external%s: '%s' %s" % [
			"s" if missing_externals.size() > 1 else "",
			Utils.join("', '", missing_externals.to_array()),
			", and no fallback ink function found." if allow_external_function_fallbacks else " (ink fallbacks disabled)"
		]

		error(message)
		return false

func validate_external_bindings_with(o, missing_externals):
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
func observe_variable(variable_name, object, method_name):
	if async_we_cant("observe a new variable"):
		return

	if _variable_observers == null:
		_variable_observers = {}

	if !self.state.variables_state.global_variable_exists_with_name(variable_name):
		Utils.throw_exception(str("Cannot observe variable '", variable_name,
								  "' because it wasn't declared in the ink story."))
		return

	if _variable_observers.has(variable_name):
		_variable_observers[variable_name].connect("variable_changed", object, method_name)
	else:
		var new_observer = VariableObserver.new(variable_name)
		new_observer.connect("variable_changed", object, method_name)

		_variable_observers[variable_name] = new_observer

# (Array<String>, Object, String) -> void
func observe_variables(variable_names, object, method_name):
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

# (String, InkObject) -> void
func variable_state_did_change_event(variable_name, new_value_obj):
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

# (String) -> Array<String>
func tags_for_content_at_path(path):
	return self.tags_at_start_of_flow_container_with_path_string(path)

# (String) -> Array<String>
func tags_at_start_of_flow_container_with_path_string(path_string):
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

# () -> String
func build_string_of_container():
	# TODO: Implement
	return ""

# (Container) -> String
func build_string_of_container_with(container):
	# TODO: Implement
	return ""

# () -> void
func next_content():

	self.state.previous_pointer = self.state.current_pointer.duplicate()

	if !self.state.diverted_pointer.is_null:

		self.state.current_pointer = self.state.diverted_pointer.duplicate()
		self.state.diverted_pointer = Pointer.null()

		self.visit_changed_containers_due_to_divert()

		if !self.state.current_pointer.is_null:
			return

	var successful_pointer_increment = self.increment_content_pointer()

	if !successful_pointer_increment:
		var did_pop = false

		if self.state.callstack.can_pop_type(PushPopType.FUNCTION):

			self.state.pop_callstack(PushPopType.FUNCTION)

			if self.state.in_expression_evaluation:
				self.state.push_evaluation_stack(Void.new())

			did_pop = true
		elif self.state.callstack.can_pop_thread:
			self.state.callstack.pop_thread()

			did_pop = true
		else:
			self.state.try_exit_function_evaluation_from_game()

		if did_pop && !self.state.current_pointer.is_null:
			self.next_content()

# () -> bool
func increment_content_pointer():
	var successful_increment = true

	var pointer = self.state.callstack.current_element.current_pointer.duplicate()
	pointer.index += 1

	while pointer.index >= pointer.container.content.size():

		successful_increment = false

		var next_ancestor = Utils.as_or_null(pointer.container.parent, "InkContainer")
		if !next_ancestor:
			break

		var index_in_ancestor = next_ancestor.content.find(pointer.container)
		if index_in_ancestor == -1:
			break

		pointer = Pointer.new(next_ancestor, index_in_ancestor)

		pointer.index += 1

		successful_increment = true

	if !successful_increment: pointer = Pointer.null()

	var current_element = self.state.callstack.current_element
	current_element.current_pointer = pointer.duplicate()

	return successful_increment

# () -> bool
func try_follow_default_invisible_choice():
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

# () -> int
func next_sequence_shuffle_index():
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

	var seq_path_str = seq_container.path.to_string()
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
func error(message, use_end_line_number = false):
	var InkRuntime = _get_runtime()
	if InkRuntime != null:
		InkRuntime.should_interrupt = true

	if InkRuntime.should_pause_execution_on_runtime_error:
		Utils.throw_story_exception(message)
	else:
		_error_raised_during_step.append(Error.new(message, use_end_line_number))

# (String) -> void
func warning(message):
	add_error(message, true)

# (String, bool, bool) -> void
func add_error(message, is_warning = false, use_end_line_number = false):
	var dm = self.current_debug_metadata

	var error_type_str = "WARNING" if is_warning else "ERROR"

	if dm != null:
		var line_num = dm.end_line_number if use_end_line_number else dm.start_line_number
		message = "RUNTIME %s: '%s' line %s: %s" % [error_type_str, dm.file_name, line_num, message]
	elif !self.state.current_pointer.is_null:
		message = "RUNTIME %s: (%s): %s" % [error_type_str, self.state.current_pointer.path.to_string(), message]
	else:
		message = "RUNTIME " + error_type_str + ": " + message

	self.state.add_error(message, is_warning)

	if !is_warning:
		self.state.force_end()

# (bool, message, Array<Variant>) -> void
func assert(condition, message = null, format_params = null):
	if condition == false:
		if message == null:
			message = "Story assert"

		if format_params != null && format_params.size() > 0:
			message = message % format_params

		Utils.throw_exception(message + " " + str(self.current_debug_metadata))

var current_debug_metadata setget , get_current_debug_metadata # DebugMetadata
func get_current_debug_metadata():
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

var current_line_number setget , get_current_line_number # int
func get_current_line_number():
	var dm = self.current_debug_metadata
	if dm != null:
		return dm.start_line_number

	return 0

var main_content_container setget , get_main_content_container # Container
func get_main_content_container():
	if _temporary_evaluation_container:
		return _temporary_evaluation_container
	else:
		return _main_content_container

var _main_content_container = null # InkContainer
var _list_definitions = null # ListDefinitionsOrigin

var _externals = null # Dictionary<String, ExternalFunctionDef>
var _variable_observers = null # Dictionary<String, VariableObserver>

var _has_validated_externals = false # bool

var _temporary_evaluation_container = null # InkContainer

var _state = null # StoryState

var _async_continue_active = false # bool
var _state_snapshot_at_last_newline = null # StoryState
var _saw_lookahead_unsafe_function_after_newline = false # bool

var _recursive_continue_count = 0 # int

var _async_saving = false # bool

var _profiler = null # Profiler

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type):
	return type == "Story" || .is_class(type)

func get_class():
	return "Story"

# ############################################################################ #

var Json setget , get_Json
func get_Json():
	return _Json.get_ref()
var _Json = WeakRef.new()

var _error_raised_during_step = []

func _initialize_runtime():
	var InkRuntime = _get_runtime()

	Utils.assert(InkRuntime != null,
				 str("Could not retrieve 'InkRuntime' singleton from the scene tree."))

	_Json = weakref(InkRuntime.json)

func _get_runtime():
	return Engine.get_main_loop().root.get_node("__InkRuntime")

class VariableObserver extends Reference:
	var variable_name # String

	signal variable_changed(variable_name, new_value)

	func _init(variable_name):
		self.variable_name = variable_name

class ExternalFunctionDef extends Reference:
	var object # WeakRef<Reference>
	var method # String
	var lookahead_safe # bool

	func _init(object, method, lookahead_safe):
		self.object = weakref(object)
		self.method = method
		self.lookahead_safe = lookahead_safe

	func execute(params):
		var object_ref = object.get_ref()
		if object_ref:
			return object_ref.callv(method, params)

class Error:
	var message
	var use_end_line_number

	func _init(message, use_end_line_number):
		self.message = message
		self.use_end_line_number = use_end_line_number
