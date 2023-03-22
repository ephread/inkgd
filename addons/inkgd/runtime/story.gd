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

# ############################################################################ #

var current_choices: Array: get = get_current_choices # Array<Choice>
func get_current_choices() -> Array:
	var choices: Array = [] # Array<Choice>

	for c in _state.current_choices:
		if !c.is_invisible_default:
			c.index = choices.size()
			choices.append(c)

	return choices

# String?
var current_text : get = get_current_text
func get_current_text():
	if async_we_cant("call currentText since it's a work in progress"):
		return null

	return state.current_text

# Array?
var current_tags: get = get_current_tags # Array<String>
func get_current_tags():
	if async_we_cant("call currentTags since it's a work in progress"):
		return null

	return state.current_tags

var current_errors: get = get_current_errors # Array<String>
func get_current_errors(): return state.current_errors

var current_warnings: get = get_current_warnings # Array<String>
func get_current_warnings(): return state.current_warnings

var current_flow_name: get = get_current_flow_name # String
func get_current_flow_name(): return state.current_flow_name

var has_error: get = get_has_error # bool
func get_has_error(): return state.has_error

var has_warning: get = get_has_warning # bool
func get_has_warning(): return state.has_warning

var variables_state: get = get_variables_state # VariablesState
func get_variables_state(): return state.variables_state

var list_definitions: get = get_list_definitions # ListDefinitionsOrigin
func get_list_definitions():
	return _list_definitions

var state: InkStoryState: get = get_state # StoryState
func get_state():
	return _state

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
	_main_content_container = content_container

	if lists != null:
		_list_definitions = InkListDefinitionsOrigin.new(lists)

	_externals = {} # Dictionary<String, ExternalFunctionDef>


func _init(json_string: String):
	_init_with(null)

	var root_object = InkSimpleJSON.text_to_dictionary(json_string)

	var version_obj = root_object["inkVersion"]
	if version_obj == null:
		InkUtils.throw_exception(
				"ink version number not found. " +
				"Are you sure it's a valid .ink.json file?"
		)
		return

	var format_from_file = int(version_obj)
	if format_from_file > INK_VERSION_CURRENT:
		InkUtils.throw_exception(
				"Version of ink used to build story was newer " +
				"than the current version of the engine"
		)
		return
	elif format_from_file < INK_VERSION_MINIMUM_COMPATIBLE:
		InkUtils.throw_exception(
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
		InkUtils.throw_exception(
				"Root node for ink not found. Are you sure it's a valid .ink.json file?"
		)
		return

	if root_object.has("listDefs"):
		_list_definitions = Json.jtoken_to_list_definitions(root_object["listDefs"])

	_main_content_container = Json.jtoken_to_runtime_object(root_token) as InkContainer

	reset_state()


# () -> String
func to_json() -> String:
	var writer: InkSimpleJSON.Writer = InkSimpleJSON.Writer.new()
	to_json_with_writer(writer)
	return writer._to_string()


func write_root_property(writer: InkSimpleJSON.Writer) -> void:
	Json.write_runtime_container(writer, _main_content_container)


func to_json_with_writer(writer: InkSimpleJSON.Writer) -> void:
	writer.write_object_start()

	writer.write_property("inkVersion", INK_VERSION_CURRENT)

	writer.write_property("root", write_root_property)

	if _list_definitions != null:
		writer.write_property_start("listDefs")
		writer.write_object_start()

		for def in _list_definitions.lists:
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

	_state = InkStoryState.new(self)
	_state.variables_state.variable_changed.connect(variable_state_did_change_event)

	reset_globals()


# () -> void
func reset_errors() -> void:
	_state.reset_errors()


# () -> void
func reset_callstack() -> void:
	if async_we_cant("ResetCallstack"):
		return

	_state.force_end()


# () -> void
func reset_globals() -> void:
	if (_main_content_container.named_content.has("global decl")):
		var original_pointer = state.current_pointer

		choose_path(InkPath.new_with_components_string("global decl"), false)

		continue_internal()

		state.current_pointer = original_pointer

	state.variables_state.snapshot_default_globals()


func switch_flow(flow_name: String) -> void:
	if async_we_cant("SwitchFlow"):
		return

	if _async_saving:
		InkUtils.throw_exception("Story is already in background saving mode, can't switch flow to " + flow_name)

	state.switch_flow_internal(flow_name)


func remove_flow(flow_name: String) -> void:
	state.remove_flow_internal(flow_name)


func switch_to_default_flow() -> void:
	state.switch_to_default_flow_internal()


func continue_story() -> String:
	continue_async(0)
	return current_text


var can_continue: bool: get = get_continue
func get_continue() -> bool:
	return state.can_continue


var async_continue_complete: bool: get = get_async_continue_complete
func get_async_continue_complete() -> bool:
	return !_async_continue_active


func continue_async(millisecs_limit_async: float):
	if !_has_validated_externals:
		validate_external_bindings()

	continue_internal(millisecs_limit_async)


func continue_internal(millisecs_limit_async: float = 0) -> void:
	if _profiler != null:
		_profiler.pre_continue()

	var is_async_time_limited = millisecs_limit_async > 0

	_recursive_continue_count += 1

	if !_async_continue_active:
		_async_continue_active = is_async_time_limited

		if !can_continue:
			InkUtils.throw_exception("Can't continue - should check canContinue before calling Continue")
			return

		_state.did_safe_exit = false
		_state.reset_output()

		if _recursive_continue_count == 1:
			_state.variables_state.batch_observing_variable_changes = true

	var duration_stopwatch = InkStopWatch.new()
	duration_stopwatch.start()

	var output_stream_ends_in_newline = false
	_saw_lookahead_unsafe_function_after_newline = false

	# In the original code, exceptions raised during 'continue_single_step()'
	# are catched and added to the error array. Since exceptions don't exist
	# in GDScript, they are recorded instead. See 'ink_runtime.gd' for more
	# information.
	_enable_story_exception_recording(true)
	var first_time = true
	while (first_time || can_continue):
		first_time = false

		output_stream_ends_in_newline = continue_single_step()
		var recorded_exceptions = _get_and_clear_recorded_story_exceptions()
		if recorded_exceptions.size() > 0:
			for error in recorded_exceptions:
				add_story_error(error)
			break

		if output_stream_ends_in_newline:
			break

		if _async_continue_active && duration_stopwatch.elapsed_milliseconds > millisecs_limit_async:
			break

	_enable_story_exception_recording(false)
	duration_stopwatch.stop()

	if output_stream_ends_in_newline || !can_continue:

		if _state_snapshot_at_last_newline != null:
			restore_state_snapshot()

		if !can_continue:
			if state.callstack.can_pop_thread:
				add_error("Thread available to pop, threads should always be flat by the end of evaluation?")

			if state.generated_choices.size() == 0 && !state.did_safe_exit && _temporary_evaluation_container == null:
				if state.callstack.can_pop_type(PushPopType.TUNNEL):
					add_error("unexpectedly reached end of content. Do you need a '->->' to return from a tunnel?")
				elif state.callstack.can_pop_type(PushPopType.FUNCTION):
					add_error("unexpectedly reached end of content. Do you need a '~ return'?")
				elif !state.callstack.can_pop:
					add_error("ran out of content. Do you need a '-> DONE' or '-> END'?")
				else:
					add_error("unexpectedly reached end of content for unknown reason. Please debug compiler!")

		state.did_safe_exit = false
		_saw_lookahead_unsafe_function_after_newline = false

		if _recursive_continue_count == 1:
			_state.variables_state.batch_observing_variable_changes = false

		_async_continue_active = false
		emit_signal("on_did_continue")

	_recursive_continue_count -= 1

	if _profiler != null:
		_profiler.post_continue()

	if state.has_error || state.has_warning:
		if !get_signal_connection_list("on_error").is_empty():
			if state.has_error:
				for err in state.current_errors:
					emit_signal("on_error", err, ErrorType.ERROR)

			if state.has_warning:
				for err in state.current_warnings:
					emit_signal("on_error", err, ErrorType.WARNING)

			reset_errors()
		else:
			var exception = "Ink had "

			if state.has_error:
				exception += str(state.current_errors.size())
				exception += " error" if state.current_errors.size() == 1 else " errors"
				if state.has_warning:
					exception += " and "

			if state.has_warning:
				exception += str(state.current_warnings.size())
				exception += " warning" if state.current_warnings.size() == 1 else " warnings"

			exception += ". It is strongly suggested that you assign an error handler to story.onError. The first issue was: "
			exception += state.current_errors[0] if state.has_error else state.current_warnings[0]

			# If you get this exception, please connect an error handler to the appropriate signal: "on_error".
			_throw_story_exception(exception)


func continue_single_step() -> bool:
	if _profiler != null:
		_profiler.pre_step()

	step()

	if _profiler != null:
		_profiler.post_step()


	if !can_continue && !state.callstack.element_is_evaluate_from_game:
		try_follow_default_invisible_choice()


	if _profiler != null:
		_profiler.pre_snapshot()

	if !state.in_string_evaluation:
		if _state_snapshot_at_last_newline != null:

			var change = calculate_newline_output_state_change(
				_state_snapshot_at_last_newline.current_text, state.current_text,
				_state_snapshot_at_last_newline.current_tags.size(), state.current_tags.size()
			)

			if change == OutputStateChange.EXTENDED_BEYOND_NEWLINE || _saw_lookahead_unsafe_function_after_newline:
				restore_state_snapshot()

				return true
			elif change == OutputStateChange.NEWLINE_REMOVED:
				discard_snapshot()

		if state.output_stream_ends_in_newline:
			if can_continue:
				if _state_snapshot_at_last_newline == null:
					state_snapshot()
			else:
				discard_snapshot()

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

	while (can_continue):
		_str += continue_story()

	return _str


func content_at_path(path: InkPath) -> InkSearchResult:
	return main_content_container.content_at_path(path)


func knot_container_with_name(name: String) -> InkContainer:
	if main_content_container.named_content.has(name):
		return main_content_container.named_content[name] as InkContainer

	return null


func pointer_at_path(path: InkPath) -> InkPointer:
	if (path.length == 0):
		return InkPointer.new_null()

	var p = InkPointer.new()

	var path_length_to_use = path.length

	var result = null # SearchResult
	if (path.last_component.is_index):
		path_length_to_use = path.length - 1
		result = main_content_container.content_at_path(path, 0, path_length_to_use)
		p = InkPointer.new(result.container, path.last_component.index)
	else:
		result = main_content_container.content_at_path(path)
		p = InkPointer.new(result.container, -1)

	if result.obj == null || result.obj == main_content_container && path_length_to_use > 0:
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
	_state_snapshot_at_last_newline = _state
	_state = _state.copy_and_start_patching()


func restore_state_snapshot() -> void:
	_state_snapshot_at_last_newline.restore_after_patch()

	_state = _state_snapshot_at_last_newline
	_state_snapshot_at_last_newline = null

	if !_async_saving:
		_state.apply_any_patch()


func discard_snapshot() -> void:
	if !_async_saving:
		_state.apply_any_patch()

	_state_snapshot_at_last_newline = null


func copy_state_for_background_thread_save() -> InkStoryState:
	if async_we_cant("start saving on a background thread"):
		return null

	if _async_saving:
		InkUtils.throw_exception(
				"Story is already in background saving mode, " +
				"can't call CopyStateForBackgroundThreadSave again!"
		)
		return null

	var state_to_save = _state
	_state = _state.copy_and_start_patching()
	_async_saving = true

	return state_to_save


func background_save_complete() -> void:
	if _state_snapshot_at_last_newline == null:
		_state.apply_any_patch()

	_async_saving = false


func step() -> void:
	var should_add_to_stream = true

	var pointer = state.current_pointer
	if pointer.is_null:
		return

	var container_to_enter = pointer.resolve() as InkContainer
	while (container_to_enter):
		visit_container(container_to_enter, true)

		if container_to_enter.content.size() == 0:
			break

		pointer = InkPointer.start_of(container_to_enter)
		container_to_enter = pointer.resolve() as InkContainer

	state.current_pointer = pointer

	if _profiler != null:
		_profiler.step(state.callstack)

	var current_content_obj = pointer.resolve()
	var is_logic_or_flow_control = perform_logic_and_flow_control(current_content_obj)

	if state.current_pointer.is_null:
		return

	if is_logic_or_flow_control:
		should_add_to_stream = false

	var choice_point = current_content_obj as InkChoicePoint
	if choice_point:
		var choice = process_choice(choice_point)
		if choice:
			state.generated_choices.append(choice)

		current_content_obj = null
		should_add_to_stream = false

	if current_content_obj is InkContainer:
		should_add_to_stream = false

	if should_add_to_stream:
		var var_pointer = current_content_obj as InkVariablePointerValue
		if var_pointer && var_pointer.context_index == -1:
			var context_idx = state.callstack.context_for_variable_named(var_pointer.variable_name)
			current_content_obj = InkVariablePointerValue.new_with_context(var_pointer.variable_name, context_idx)

		if state.in_expression_evaluation:
			state.push_evaluation_stack(current_content_obj)
		else:
			state.push_to_output_stream(current_content_obj)

	next_content()

	var control_cmd = current_content_obj as InkControlCommand
	if control_cmd && control_cmd.command_type == InkControlCommand.CommandType.START_THREAD:
		state.callstack.push_thread()


func visit_container(container: InkContainer, at_start: bool) -> void:
	if !container.counting_at_start_only || at_start:
		if container.visits_should_be_counted:
			state.increment_visit_count_for_container(container)

		if container.turn_index_should_be_counted:
			state.record_turn_index_visit_to_container(container)


var _prev_containers = [] # Array<Container>
func visit_changed_containers_due_to_divert() -> void:
	var previous_pointer = state.previous_pointer
	var pointer = state.current_pointer

	if pointer.is_null || pointer.index == -1:
		return

	_prev_containers.clear()
	if !previous_pointer.is_null:
		var prev_ancestor = previous_pointer.resolve() as InkContainer
		prev_ancestor = prev_ancestor if prev_ancestor else previous_pointer.container as InkContainer
		while prev_ancestor:
			_prev_containers.append(prev_ancestor)
			prev_ancestor = prev_ancestor.parent as InkContainer

	var current_child_of_container = pointer.resolve()

	if current_child_of_container == null: return

	var current_container_ancestor = current_child_of_container.parent as InkContainer

	var all_children_entered_at_start = true
	while current_container_ancestor && (_prev_containers.find(current_container_ancestor) < 0 || current_container_ancestor.counting_at_start_only):

		var entering_at_start = (current_container_ancestor.content.size() > 0 &&
								current_child_of_container == current_container_ancestor.content[0] &&
								all_children_entered_at_start)

		if !entering_at_start:
			all_children_entered_at_start = false

		visit_container(current_container_ancestor, entering_at_start)

		current_child_of_container = current_container_ancestor
		current_container_ancestor = current_container_ancestor.parent as InkContainer


func process_choice(choice_point: InkChoicePoint) -> InkChoice:
	var show_choice = true

	if choice_point.has_condition:
		var condition_value = state.pop_evaluation_stack()
		if !is_truthy(condition_value):
			show_choice = false

	var start_text = ""
	var choice_only_text = ""

	if choice_point.has_choice_only_content:
		var choice_only_str_val = state.pop_evaluation_stack() as InkStringValue
		choice_only_text = choice_only_str_val.value

	if choice_point.has_start_content:
		var start_str_val = state.pop_evaluation_stack() as InkStringValue
		start_text = start_str_val.value

	if choice_point.once_only:
		var visit_count = state.visit_count_for_container(choice_point.choice_target)
		if visit_count > 0:
			show_choice = false

	if !show_choice:
		return null

	var choice = InkChoice.new()
	choice.target_path = choice_point.path_on_choice
	choice.source_path = choice_point.path._to_string()
	choice.is_invisible_default = choice_point.is_invisible_default
	choice.thread_at_generation = state.callstack.fork_thread()

	choice.text = InkUtils.trim(start_text + choice_only_text, [" ", "\t"])

	return choice


func is_truthy(obj: InkObject) -> bool:
	var truthy = false
	if obj is InkValue:
		var val = obj

		if obj is InkDivertTargetValue:
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

	if content_obj is InkDivert:
		var current_divert = content_obj

		if current_divert.is_conditional:
			var condition_value = state.pop_evaluation_stack()

			if !is_truthy(condition_value):
				return true

		if current_divert.has_variable_target:
			var var_name = current_divert.variable_divert_name
			var var_contents = state.variables_state.get_variable_with_name(var_name)

			if var_contents == null:
				error(str("Tried to divert using a target from a variable that could not be found (",
						var_name, ")"))
				return false
			elif !var_contents is InkDivertTargetValue:
				var int_content = var_contents as InkIntValue

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
			state.diverted_pointer = pointer_at_path(target.target_path)

		elif current_divert.is_external:
			call_external_function(current_divert.target_path_string, current_divert.external_args)
			return true
		else:
			state.diverted_pointer = current_divert.target_pointer

		if current_divert.pushes_to_stack:
			state.callstack.push(
				current_divert.stack_push_type,
				0,
				state.output_stream.size()
			)

		if state.diverted_pointer.is_null && !current_divert.is_external:
			if current_divert && current_divert.debug_metadata != null && current_divert.debug_metadata.source_name != null:
				error("Divert target doesn't exist: " + current_divert.debug_metadata.source_name)
				return false
			else:
				error("Divert resolution failed: " + current_divert._to_string())
				return false

		return true
	elif content_obj is InkControlCommand:
		var eval_command = content_obj

		match eval_command.command_type:

			InkControlCommand.CommandType.EVAL_START:
				__assert__(
						state.in_expression_evaluation == false,
						"Already in expression evaluation?"
				)
				state.in_expression_evaluation = true

			InkControlCommand.CommandType.EVAL_END:
				__assert__(
						state.in_expression_evaluation == true,
						"Not in expression evaluation mode"
				)
				state.in_expression_evaluation = false

			InkControlCommand.CommandType.EVAL_OUTPUT:
				if state.evaluation_stack.size() > 0:
					var output = state.pop_evaluation_stack()

					if !(output is InkVoid):
						var text = InkStringValue.new_with(output._to_string())
						state.push_to_output_stream(text)

			InkControlCommand.CommandType.NO_OP:
				pass

			InkControlCommand.CommandType.DUPLICATE:
				state.push_evaluation_stack(state.peek_evaluation_stack())

			InkControlCommand.CommandType.POP_EVALUATED_VALUE:
				state.pop_evaluation_stack()

			InkControlCommand.CommandType.POP_FUNCTION, InkControlCommand.CommandType.POP_TUNNEL:
				var is_pop_function = (
						eval_command.command_type == InkControlCommand.CommandType.POP_FUNCTION
				)
				var pop_type = PushPopType.FUNCTION if is_pop_function else PushPopType.TUNNEL

				var override_tunnel_return_target = null # DivertTargetValue
				if pop_type == PushPopType.TUNNEL:
					var popped = state.pop_evaluation_stack()
					override_tunnel_return_target = popped as InkDivertTargetValue
					if override_tunnel_return_target == null:
						__assert__(
								popped is InkVoid,
								"Expected void if ->-> doesn't override target"
						)

				if state.try_exit_function_evaluation_from_game():
					pass
				elif state.callstack.current_element.type != pop_type || !state.callstack.can_pop:
					var names = {} # Dictionary<PushPopType, String>
					names[PushPopType.FUNCTION] = "function return statement (~ return)"
					names[PushPopType.TUNNEL] = "tunnel onwards statement (->->)"

					var expected = names[state.callstack.current_element.type]
					if !state.callstack.can_pop:
						expected = "end of flow (-> END or choice)"

					var error_msg = "Found %s, when expected %s" % [names[pop_type], expected]

					error(error_msg)
				else:
					state.pop_callstack()

					if override_tunnel_return_target:
						state.diverted_pointer = pointer_at_path(override_tunnel_return_target.target_path)

			InkControlCommand.CommandType.BEGIN_STRING:
				state.push_to_output_stream(eval_command)

				__assert__(
						state.in_expression_evaluation == true,
						"Expected to be in an expression when evaluating a string"
				)
				state.in_expression_evaluation = false

			InkControlCommand.CommandType.END_STRING:
				var content_stack_for_string = [] # Stack<InkObject>

				var output_count_consumed = 0
				var i = state.output_stream.size() - 1
				while (i >= 0):
					var obj = state.output_stream[i]

					output_count_consumed += 1

					var command = obj as InkControlCommand
					if (command != null &&
						command.command_type == InkControlCommand.CommandType.BEGIN_STRING):
						break

					if obj is InkStringValue:
						content_stack_for_string.push_front(obj)

					i -= 1

				state.pop_from_output_stream(output_count_consumed)

				var _str = ""
				for c in content_stack_for_string:
					_str += c._to_string()

				state.in_expression_evaluation = true
				state.push_evaluation_stack(InkStringValue.new_with(_str))

			InkControlCommand.CommandType.CHOICE_COUNT:
				var choice_count = state.generated_choices.size()
				state.push_evaluation_stack(InkIntValue.new_with(choice_count))

			InkControlCommand.CommandType.TURNS:
				state.push_evaluation_stack(InkIntValue.new_with(state.current_turn_index + 1))

			InkControlCommand.CommandType.TURNS_SINCE, InkControlCommand.CommandType.READ_COUNT:
				var target = state.pop_evaluation_stack()
				if !target is InkDivertTargetValue:
					var extra_note = ""
					if target is InkIntValue:
						extra_note = ". Did you accidentally pass a read count ('knot_name') instead of a target ('-> knot_name')?"
					error(str("TURNS_SINCE expected a divert target (knot, stitch, label name), but saw ",
							target, extra_note))
					return false

				var divert_target = target as InkDivertTargetValue
				var container = content_at_path(divert_target.target_path).correct_obj as InkContainer

				var either_count = 0
				if container != null:
					if eval_command.command_type == InkControlCommand.CommandType.TURNS_SINCE:
						either_count = state.turns_since_for_container(container)
					else:
						either_count = state.visit_count_for_container(container)
				else:
					if eval_command.command_type == InkControlCommand.CommandType.TURNS_SINCE:
						either_count = -1
					else:
						either_count = 0

					warning(str("Failed to find container for ", eval_command._to_string(),
								" lookup at ", divert_target.target_path._to_string()))

				state.push_evaluation_stack(InkIntValue.new_with(either_count))

			InkControlCommand.CommandType.RANDOM:
				var max_int = state.pop_evaluation_stack() as InkIntValue
				var min_int = state.pop_evaluation_stack() as InkIntValue

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

				var result_seed = state.story_seed + state.previous_random
				seed(result_seed)

				var next_random = randi()
				var chosen_value = (next_random % random_range) + min_int.value
				state.push_evaluation_stack(InkIntValue.new_with(chosen_value))

				state.previous_random = next_random

			InkControlCommand.CommandType.SEED_RANDOM:
				var _seed = state.pop_evaluation_stack() as InkIntValue
				if _seed == null:
					error("Invalid value passed to SEED_RANDOM")
					return false

				state.story_seed = _seed.value
				state.previous_random = 0

				state.push_evaluation_stack(InkVoid.new())

			InkControlCommand.CommandType.VISIT_INDEX:
				var count = state.visit_count_for_container(state.current_pointer.container) - 1
				state.push_evaluation_stack(InkIntValue.new_with(count))

			InkControlCommand.CommandType.SEQUENCE_SHUFFLE_INDEX:
				var shuffle_index = next_sequence_shuffle_index()
				state.push_evaluation_stack(InkIntValue.new_with(shuffle_index))

			InkControlCommand.CommandType.START_THREAD:
				pass

			InkControlCommand.CommandType.DONE:
				if state.callstack.can_pop_thread:
					state.callstack.pop_thread()
				else:
					state.did_safe_exit = true
					state.current_pointer = InkPointer.new_null()

			InkControlCommand.CommandType.END:
				state.force_end()

			InkControlCommand.CommandType.LIST_FROM_INT:
				var int_val = state.pop_evaluation_stack() as InkIntValue
				var list_name_val = state.pop_evaluation_stack() as InkStringValue

				if int_val == null:
					_throw_story_exception(
							"Passed non-integer when creating a list element from a numerical value."
					)
					return false

				var generated_list_value = null # ListValue

				var found_list_def: InkTryGetResult = list_definitions.try_list_get_definition(list_name_val.value)
				if found_list_def.exists:
					var found_item: InkTryGetResult = found_list_def.result.try_get_item_with_value(int_val.value)
					if found_item.exists:
						generated_list_value = InkListValue.new_with_single_item(
								found_item.result,
								int_val.value
						)
				else:
					_throw_story_exception("Failed to find LIST called %s" % list_name_val.value)
					return false

				if generated_list_value == null:
					generated_list_value = InkListValue.new()

				state.push_evaluation_stack(generated_list_value)

			InkControlCommand.CommandType.LIST_RANGE:
				var max_value = state.pop_evaluation_stack() as InkValue
				var min_value = state.pop_evaluation_stack() as InkValue

				var target_list = state.pop_evaluation_stack() as InkListValue

				if target_list == null || min_value == null || max_value == null:
					_throw_story_exception("Expected list, minimum and maximum for LIST_RANGE")
					return false

				var result = target_list.value.list_with_sub_range(min_value.value_object, max_value.value_object)

				state.push_evaluation_stack(InkListValue.new_with(result))

			InkControlCommand.CommandType.LIST_RANDOM:

				var list_val = state.pop_evaluation_stack() as InkListValue
				if list_val == null:
					_throw_story_exception("Expected list for LIST_RANDOM")
					return false

				var list = list_val.value

				var new_list: InkList = null

				if list.size() == 0:
					new_list = InkList.new()
				else:
					var result_seed = state.story_seed + state.previous_random
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

					state.previous_random = next_random

				state.push_evaluation_stack(InkListValue.new_with(new_list))

			_:
				error("unhandled ControlCommand: " + eval_command._to_string())
				return false

		return true

	elif content_obj as InkVariableAssignment:
		var var_ass = content_obj
		var assigned_val = state.pop_evaluation_stack()
		if assigned_val is Array:
			assigned_val = assigned_val.front()

		state.variables_state.assign(var_ass, assigned_val)

		return true

	elif content_obj as InkVariableReference:
		var var_ref = content_obj
		var found_value: InkValue = null

		if var_ref.path_for_count != null:
			var container = var_ref.container_for_count
			var count = state.visit_count_for_container(container)
			found_value = InkIntValue.new_with(count)
		else:
			found_value = state.variables_state.get_variable_with_name(var_ref.name)

			if found_value == null:
				warning(str("Variable not found: '", var_ref.name,
							"', using default value of 0 (false). this can ",
							"happen with temporary variables if the declaration ",
							"hasn't yet been hit. Globals are always given a default ",
							"value on load if a value doesn't exist in the save state."))
				found_value = InkIntValue.new_with(0)

		state.push_evaluation_stack(found_value)
		return true

	elif content_obj as InkNativeFunctionCall:
		var function = content_obj
		var func_params = state.pop_evaluation_stack(function.number_of_parameters)
		var result = function.call_with_parameters(func_params, _make_story_error_metadata())
		state.push_evaluation_stack(result)
		return true

	return false

# (String, bool, Array) -> void
func choose_path_string(path, reset_callstack = true, arguments = null):
	if async_we_cant("call ChoosePathString right now"):
		return

	emit_signal("on_choose_path_string", path, arguments)

	if reset_callstack:
		reset_callstack()
	else:
		if state.callstack.current_element.type == PushPopType.FUNCTION:
			var func_detail = ""
			var container = state.callstack.current_element.current_pointer.container
			if container != null:
				func_detail = "(" + container.path._to_string() + ") "

			InkUtils.throw_exception(
					"Story was running a function %s" % func_detail +
					" when you called ChoosePathString(%s) " % path +
					" - this is almost certainly not not what you want! Full stack trace: \n" +
					state.callstack.callstack_trace
			)

			return

	state.pass_arguments_to_evaluation_stack(arguments)
	choose_path(InkPath.new_with_components_string(path))


func async_we_cant(activity_str):
	if _async_continue_active:
		InkUtils.throw_exception(
				"Can't %s. Story is in the middle of a ContinueAsync(). " % activity_str +
				"Make more ContinueAsync() calls or a single continue_story() call beforehand."
		)

	return _async_continue_active


# (InkPath, bool)
func choose_path(p, incrementing_turn_index = true):
	state.set_chosen_path(p, incrementing_turn_index)

	visit_changed_containers_due_to_divert()


# (int) -> void
func choose_choice_index(choice_idx):
	var choices = current_choices
	__assert__(
			choice_idx >= 0 && choice_idx < choices.size(),
			"choice out of range"
	)

	var choice_to_choose = choices[choice_idx]
	emit_signal("on_make_choice", choice_to_choose)

	state.callstack.current_thread = choice_to_choose.thread_at_generation

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
		InkUtils.throw_exception("Function is null")
		return null
	elif function_name == "" || InkUtils.trim(function_name) == "":
		InkUtils.throw_exception("Function is empty or white space.")
		return null

	var func_container = knot_container_with_name(function_name)
	if func_container == null:
		InkUtils.throw_exception("Function doesn't exist: '%s'" % function_name)
		return null

	var output_stream_before = state.output_stream.duplicate() # Array<InkObject>
	_state.reset_output()

	state.start_function_evaluation_from_game(func_container, arguments)

	var string_output = ""
	while can_continue:
		string_output += continue_story()

	var text_output = string_output

	_state.reset_output(output_stream_before)

	var result = state.complete_function_evaluation_from_game()

	emit_signal("on_complete_evaluate_function", function_name, arguments, text_output, result)
	if return_text_output:
		return { "result": result, "output": text_output }
	else:
		return result


# (InkContainer) -> InkObject
func evaluate_expression(expr_container: InkContainer) -> InkObject:
	var start_callstack_height = state.callstack.elements.size()

	state.callstack.push(PushPopType.TUNNEL)

	_temporary_evaluation_container = expr_container

	state.go_to_start()

	var eval_stack_height = state.evaluation_stack.size()

	continue_story()

	_temporary_evaluation_container = null

	if state.callstack.elements.size() > start_callstack_height:
		state.pop_callstack()

	var end_stack_height = state.evaluation_stack.size()
	if end_stack_height > eval_stack_height:
		return state.pop_evaluation_stack()
	else:
		return null

var allow_external_function_fallbacks = false # bool


# (String, int) -> void
func call_external_function(func_name: String, number_of_arguments: int) -> void:
	var _func_def: ExternalFunctionDef = null
	var fallback_function_container: InkContainer = null

	if _externals.has(func_name):
		_func_def = _externals.get(func_name)
		if _func_def != null && !_func_def.lookahead_safe && _state_snapshot_at_last_newline != null:
			_saw_lookahead_unsafe_function_after_newline = true
			return

	if _func_def == null:
		if allow_external_function_fallbacks:
			fallback_function_container = knot_container_with_name(func_name)
			__assert__(
				fallback_function_container != null,
				"Trying to call EXTERNAL function '%s' " % func_name +
				"which has not been bound, and fallback ink function" +
				"could not be found."
			)

			state.callstack.push(
				PushPopType.FUNCTION,
				0,
				state.output_stream.size()
			)

			state.diverted_pointer = InkPointer.start_of(fallback_function_container)
			return
		else:
			__assert__(
				false,
				"Trying to call EXTERNAL function '%s' " % func_name +
				"which has not been bound (and ink fallbacks disabled)."
			)
			return

	var arguments = [] # Array<Variant>
	var i = 0
	while i < number_of_arguments:
		var popped_obj = state.pop_evaluation_stack() as InkValue
		var value_obj = popped_obj.value_object
		arguments.append(value_obj)

		i += 1

	arguments.reverse()

	var func_result = _func_def.execute(arguments)

	var return_obj = null
	if func_result != null:
		return_obj = InkValue.create(func_result)
		__assert__(
			return_obj != null,
			"Could not create ink value from returned object of type %s" % \
			InkUtils.typename_of(typeof(func_result))
		)
	else:
		return_obj = InkVoid.new()

	state.push_evaluation_stack(return_obj)


# (String, Variant, ExternalFunctionDef, bool) -> void
func bind_external_function_general(
	func_name: String,
	object,
	method: String,
	lookahead_safe: bool = true
) -> void:
	if async_we_cant("bind an external function"):
		return

	__assert__(
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
	__assert__(
			object != null || method_name != null,
			"Can't bind a null function"
	)

	bind_external_function_general(func_name, object, method_name, lookahead_safe)


func unbind_external_function(func_name: String) -> void:
	if async_we_cant("unbind an external a function"):
		return

	__assert__(
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
			InkUtils.join("', '", missing_externals.to_array()),
			", and no fallback ink function found." if allow_external_function_fallbacks else " (ink fallbacks disabled)"
		]

		error(message)


func validate_external_bindings_with(o, missing_externals: InkStringSet) -> void:
	if o is InkContainer:
		for inner_content in o.content:
			var inner_container = inner_content as InkContainer
			if inner_container == null || !inner_container.has_valid_name:
				validate_external_bindings_with(inner_content, missing_externals)

		for inner_key in o.named_content:
			validate_external_bindings_with(
				o.named_content[inner_key] as InkObject,
				missing_externals
			)
		return

	if o is InkDivert && o.is_external:
		var name = o.target_path_string

		if !_externals.has(name):
			if allow_external_function_fallbacks:
				var fallback_found = main_content_container.named_content.has(name)
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

	if !state.variables_state.global_variable_exists_with_name(variable_name):
		InkUtils.throw_exception(
				"Cannot observe variable '%s'" % variable_name +
				"because it wasn't declared in the ink story."
		)
		return

	if _variable_observers.has(variable_name):
		_variable_observers[variable_name].variable_changed.connect(Callable(object, method_name))
	else:
		var new_observer = VariableObserver.new(variable_name)
		new_observer.variable_changed.connect(Callable(object, method_name))

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
				observer.variable_changed.disconnect(Callable(object, method_name))

				if observer.get_signal_connection_list("variable_changed").is_empty():
					_variable_observers.erase(specific_variable_name)
			else:
				var connections = observer.get_signal_connection_list("variable_changed");
				for connection in connections:
					observer.disconnect(connection["signal"].get_name(), connection.callable)

				_variable_observers.erase(specific_variable_name)

	elif object != null && method_name != null:
		var keys_to_remove = []
		for observer_key in _variable_observers:
			var observer = _variable_observers[observer_key]
			if observer.variable_changed.is_connected(Callable(object, method_name)):
				observer.variable_changed.disconnect(Callable(object, method_name))

			if observer.get_signal_connection_list("variable_changed").is_empty():
				keys_to_remove.append(observer_key)

		for key in keys_to_remove:
			_variable_observers.erase(key)


func variable_state_did_change_event(variable_name: String, new_value_obj: InkObject) -> void:
	if _variable_observers == null:
		return

	if _variable_observers.has(variable_name):
		var observer = _variable_observers[variable_name]

		if !new_value_obj is InkValue:
			InkUtils.throw_exception("Tried to get the value of a variable that isn't a standard type")
			return

		var val = new_value_obj

		observer.emit_signal("variable_changed", variable_name, val.value_object)


var global_tags: get = get_global_tags # Array<String>
func get_global_tags():
	return tags_at_start_of_flow_container_with_path_string("")

# (String) -> Array<String>?
func tags_for_content_at_path(path: String):
	return tags_at_start_of_flow_container_with_path_string(path)

# (String) -> Array<String>?
func tags_at_start_of_flow_container_with_path_string(path_string: String):
	var path = InkPath.new_with_components_string(path_string)

	var flow_container = content_at_path(path).container
	while (true):
		var first_content = flow_container.content[0]
		if first_content is InkContainer:
			flow_container = first_content
		else: break

	var tags = null # Array<String>
	for c in flow_container.content:
		var tag = c  as InkTag
		if tag:
			if tags == null: tags = [] # Array<String> ()
			tags.append(tag.text)
		else: break

	return tags


func build_string_of_container() -> String:
	# TODO: Implement
	return ""


func build_string_of_container_with(_container: InkContainer) -> String:
	# TODO: Implement
	return ""


func next_content() -> void:

	state.previous_pointer = state.current_pointer

	if !state.diverted_pointer.is_null:

		state.current_pointer = state.diverted_pointer
		state.diverted_pointer = InkPointer.new_null()

		visit_changed_containers_due_to_divert()

		if !state.current_pointer.is_null:
			return

	var successful_pointer_increment = increment_content_pointer()

	if !successful_pointer_increment:
		var did_pop = false

		if state.callstack.can_pop_type(PushPopType.FUNCTION):

			state.pop_callstack(PushPopType.FUNCTION)

			if state.in_expression_evaluation:
				state.push_evaluation_stack(InkVoid.new())

			did_pop = true
		elif state.callstack.can_pop_thread:
			state.callstack.pop_thread()

			did_pop = true
		else:
			state.try_exit_function_evaluation_from_game()

		if did_pop && !state.current_pointer.is_null:
			next_content()


func increment_content_pointer() -> bool:
	var successful_increment = true

	var pointer = state.callstack.current_element.current_pointer
	pointer = InkPointer.new(pointer.container, pointer.index + 1)

	while pointer.index >= pointer.container.content.size():

		successful_increment = false

		var next_ancestor = pointer.container.parent as InkContainer
		if !next_ancestor:
			break

		var index_in_ancestor = next_ancestor.content.find(pointer.container)
		if index_in_ancestor == -1:
			break

		pointer = InkPointer.new(next_ancestor, index_in_ancestor + 1)

		successful_increment = true

	if !successful_increment: pointer = InkPointer.new_null()

	var current_element = state.callstack.current_element
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

	var callstack = state.callstack
	callstack.current_thread = choice.thread_at_generation

	if _state_snapshot_at_last_newline != null:
		state.callstack.current_thread = state.callstack.fork_thread()

	choose_path(choice.target_path, false)

	return true


func next_sequence_shuffle_index() -> int:
	var num_elements_int_val = state.pop_evaluation_stack() as InkIntValue
	if num_elements_int_val == null:
		error("expected number of elements in sequence for shuffle index")
		return 0

	var seq_container = state.current_pointer.container

	var num_elements = num_elements_int_val.value

	var seq_count_val = state.pop_evaluation_stack() as InkIntValue
	var seq_count = seq_count_val.value
	var loop_index = seq_count / num_elements
	var iteration_index = seq_count % num_elements

	var seq_path_str = seq_container.path._to_string()
	var sequence_hash = 0
	for c in seq_path_str:
		sequence_hash += int(c)

	var random_seed = sequence_hash + loop_index + state.story_seed
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
		unpicked_indices.remove_at(chosen)

		if i == iteration_index:
			return chosen_index

		i += 1

	InkUtils.throw_exception("Should never reach here")
	return -1


# (String, bool) -> void
func error(message: String, use_end_line_number: bool = false) -> void:
	InkUtils.throw_story_exception(message, use_end_line_number, _make_story_error_metadata())


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
		current_debug_metadata,
		state.current_pointer
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

		if current_debug_metadata != null:
			InkUtils.throw_exception("%s %s" % [message, str(current_debug_metadata)])
		else:
			InkUtils.throw_exception(message)


var current_debug_metadata: InkDebugMetadata: get = get_current_debug_metadata
func get_current_debug_metadata() -> InkDebugMetadata:
	var dm # DebugMetadata

	var pointer = state.current_pointer
	if !pointer.is_null && pointer.resolve():
		dm = pointer.resolve().debug_metadata
		if dm != null:
			return dm

	var i = state.callstack.elements.size() - 1
	while (i >= 0):
		pointer = state.callstack.elements[i].current_pointer
		if !pointer.is_null && pointer.resolve() != null:
			dm = pointer.resolve().debug_metadata
			if dm != null:
				return dm

		i -= 1

	i = state.output_stream.size() - 1
	while(i >= 0):
		var output_obj = state.output_stream[i]
		dm = output_obj.debug_metadata
		if dm != null:
			return dm

		i -= 1

	return null


var current_line_number: int: get = get_current_line_number
func get_current_line_number() -> int:
	var dm = current_debug_metadata
	if dm != null:
		return dm.start_line_number

	return 0


var main_content_container: InkContainer : get = get_main_content_container
func get_main_content_container():
	if _temporary_evaluation_container:
		return _temporary_evaluation_container
	else:
		return _main_content_container


var _main_content_container: InkContainer = null
var _list_definitions: InkListDefinitionsOrigin = null

# Dictionary<String, ExternalFunctionDef>?
var _externals = null
# Dictionary<String, VariableObserver>?
var _variable_observers = null

var _has_validated_externals: bool = false

var _temporary_evaluation_container: InkContainer = null

var _state: InkStoryState = null

var _async_continue_active: bool = false
# StoryState?
var _state_snapshot_at_last_newline = null
var _saw_lookahead_unsafe_function_after_newline: bool = false # bool

var _recursive_continue_count: int = 0

var _async_saving: bool = false

# Profiler?
var _profiler = null

func connect_exception(target: Object, method: String, binds = [], flags = 0) -> int:
	var runtime = _get_runtime()
	if runtime == null:
		return ERR_UNAVAILABLE

	if runtime.exception_raised.is_connected(Callable(target, method)):
		return OK

	return runtime.exception_raised.connect(Callable(target, method).bind(binds), flags)


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
	current_pointer = InkPointer.new_null()
) -> void:
	var error_type_str = "WARNING" if is_warning else "ERROR"

	if dm != null:
		var line_num = dm.end_line_number if use_end_line_number else dm.start_line_number
		message = "RUNTIME %s: '%s' line %s: %s" % [error_type_str, dm.file_name, line_num, message]
	elif !current_pointer.is_null:
		message = "RUNTIME %s: (%s): %s" % [error_type_str, current_pointer.path._to_string(), message]
	else:
		message = "RUNTIME " + error_type_str + ": " + message

	state.add_error(message, is_warning)

	if !is_warning:
		state.force_end()


func _throw_story_exception(message: String):
	InkUtils.throw_story_exception(message, false, _make_story_error_metadata())


# This method is used to ensure that the debug metadata and pointer used
# to report errors are the ones at the moment the error occured (and not
# the current one). Since GDScript doesn't have exceptions, errors may be
# stored until they can be processed at the end of `continue_internal`.
func _make_story_error_metadata():
	return StoryErrorMetadata.new(current_debug_metadata, state.current_pointer)


# ############################################################################ #

var Json : get = get_Json
func get_Json():
	return _Json.get_ref()
var _Json = WeakRef.new()

func _initialize_runtime():
	var ink_runtime = _get_runtime()

	InkUtils.__assert__(
		ink_runtime != null,
		str("Could not retrieve 'InkRuntime' singleton from the scene tree.")
	)

	_Json = weakref(ink_runtime.json)

func _get_runtime():
	return Engine.get_main_loop().root.get_node("__InkRuntime")


# ############################################################################ #

class VariableObserver extends RefCounted:
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
			InkUtils.throw_exception(
					"Object binded to %s has been deallocated, cannot execute." % method
			)
			return null
