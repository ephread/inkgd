# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends InkBase

class_name InkStoryState

# ############################################################################ #
# Imports
# ############################################################################ #

var PushPopType = preload("res://addons/inkgd/runtime/enums/push_pop.gd").PushPopType
var ValueType = preload("res://addons/inkgd/runtime/values/value_type.gd").ValueType

# ############################################################################ #

const INK_SAVE_STATE_VERSION: int = 9
const MIN_COMPATIBLE_LOAD_VERSION: int = 8

# ############################################################################ #

signal on_did_load_state()

# ############################################################################ #

func to_json() -> String:
	var writer: InkSimpleJSON.Writer = InkSimpleJSON.Writer.new()
	write_json(writer)
	return writer._to_string()

func load_json(json: String) -> void:
	var jobject: Dictionary = InkSimpleJSON.text_to_dictionary(json)
	load_json_obj(jobject)
	emit_signal("on_did_load_state")

func visit_count_at_path_string(path_string: String) -> int:
	if _patch != null:
		var path = InkPath.new_with_components_string(path_string)
		var container: InkContainer = story.content_at_path(path).container
		if container == null:
			InkUtils.throw_exception("Content at path not found: %s" % path_string)
			return 0

		var visit_count: InkTryGetResult = _patch.try_get_visit_count(container)
		if visit_count.exists:
			return visit_count.result

	if _visit_counts.has(path_string):
		return _visit_counts[path_string]

	return 0

func visit_count_for_container(container: InkContainer) -> int:
	if !container.visits_should_be_counted:
		story.error(
				"Read count for target (%s - on %s) " % [container.name, container.debugMetadata] +
				"unknown. The story may need to be compiled with countAllVisits flag (-c)."
		)
		return 0

	var count: int = 0

	if _patch != null:
		var visit_count: InkTryGetResult = _patch.try_get_visit_count(container)
		if visit_count.exists:
			return visit_count.result

	var container_path_str: String = container.path._to_string()

	if _visit_counts.has(container_path_str):
		count = _visit_counts[container_path_str]

	return count

func increment_visit_count_for_container(container: InkContainer) -> void:
	if _patch != null:
		var curr_count: int = visit_count_for_container(container)
		curr_count += 1
		_patch.set_visit_count(container, curr_count)
		return

	var count: int = 0
	var container_path_str: String = container.path._to_string()
	if _visit_counts.has(container_path_str):
		count = _visit_counts[container_path_str]
	count += 1

	_visit_counts[container_path_str] = count

func record_turn_index_visit_to_container(container: InkContainer) -> void:
	if _patch != null:
		_patch.set_turn_index(container, current_turn_index)
		return

	var container_path_str: String = container.path._to_string()

	_turn_indices[container_path_str] = current_turn_index

# (InkContainer) -> int
func turns_since_for_container(container: InkContainer) -> int:
	if !container.turn_index_should_be_counted:
		story.error(
				"TURNS_SINCE() for target (%s - on %s) " \
				% [container.name, container.debugMetadata] +
				"unknown. The story may need to be compiled with countAllVisits flag (-c)."
		)
		return 0

	if _patch != null:
		var turn_index: InkTryGetResult = _patch.try_get_turn_index(container)
		if turn_index.exists:
			return current_turn_index - turn_index.result

	var container_path_str: String = container.path._to_string()
	if _turn_indices.has(container_path_str):
		return current_turn_index - _turn_indices[container_path_str]
	else:
		return -1

var callstack_depth: int: get = get_callstack_depth # int
func get_callstack_depth() -> int:
	return callstack.depth

var output_stream: Array: get = get_output_stream # Array<InkObject>
func get_output_stream() -> Array:
	return _current_flow.output_stream

var current_choices: Array: get = get_current_choices # Array<Choice>
func get_current_choices() -> Array:
	if can_continue:
		return []
	return _current_flow.current_choices

var generated_choices: Array: get = get_generated_choices # Array<Choice>
func get_generated_choices() -> Array:
	return _current_flow.current_choices

# Array<String>
var current_errors = null

# Array<String>
var current_warnings = null

var variables_state: InkVariablesState

var callstack: InkCallStack: get = get_callstack
func get_callstack() -> InkCallStack:
	return _current_flow.callstack

# Array<InkObject>
var evaluation_stack: Array

# Pointer
var diverted_pointer: InkPointer = InkPointer.new_null()

var current_turn_index: int = 0
var story_seed: int = 0
var previous_random: int = 0
var did_safe_exit: bool = false

var story : get = get_story
func get_story():
	return _story.get_ref()
var _story = WeakRef.new()

# String?
var current_path_string : get = get_current_path_string
func get_current_path_string():
	var pointer = current_pointer
	if pointer.is_null:
		return null
	else:
		return pointer.path._to_string()

var current_pointer: InkPointer: get = get_current_pointer, set = set_current_pointer
func get_current_pointer() -> InkPointer:
	var pointer = callstack.current_element.current_pointer
	return callstack.current_element.current_pointer

func set_current_pointer(value: InkPointer):
	var current_element = callstack.current_element
	current_element.current_pointer = value

var previous_pointer: InkPointer: get = get_previous_pointer, set = set_previous_pointer
func get_previous_pointer() -> InkPointer:
	return callstack.current_thread.previous_pointer

func set_previous_pointer(value: InkPointer):
	var current_thread = callstack.current_thread
	current_thread.previous_pointer = value

var can_continue: bool: get = get_can_continue
func get_can_continue() -> bool:
	return !current_pointer.is_null && !has_error

var has_error: bool: get = get_has_error
func get_has_error() -> bool:
	return current_errors != null && current_errors.size() > 0

var has_warning: bool: get = get_has_warning
func get_has_warning() -> bool:
	return current_warnings != null && current_warnings.size() > 0

var current_text: String: get = get_current_text
func get_current_text():
	if _output_stream_text_dirty:
		var _str = ""

		for output_obj in output_stream:
			var text_content: InkStringValue = output_obj as InkStringValue
			if text_content != null:
				_str += text_content.value

		_current_text = clean_output_whitespace(_str)

		_output_stream_text_dirty = false

	return _current_text

var _current_text: String = ""

# (String) -> String
func clean_output_whitespace(str_to_clean: String) -> String:
	var _str: String = ""

	var current_whitespace_start: int = -1
	var start_of_line: int = 0

	var i: int = 0
	while(i < str_to_clean.length()):
		var c: String = str_to_clean[i]

		var is_inline_whitespace: bool = (c == " " || c == "\t")

		if is_inline_whitespace && current_whitespace_start == -1:
			current_whitespace_start = i

		if !is_inline_whitespace:
			if (c != "\n" && current_whitespace_start > 0 && current_whitespace_start != start_of_line):
				_str += " "

			current_whitespace_start = -1

		if c == "\n":
			start_of_line = i + 1

		if !is_inline_whitespace:
			_str += c

		i += 1

	return _str

# Array<String>
var current_tags: Array: get = get_current_tags
func get_current_tags():
	if _output_stream_tags_dirty:
		_current_tags = []

		for output_obj in output_stream:
			var tag = output_obj as InkTag
			if tag != null:
				_current_tags.append(tag.text)

		_output_stream_tags_dirty = false

	return _current_tags

# Array<String>
var _current_tags: Array = []

var current_flow_name: String: get = get_current_flow_name
func get_current_flow_name() -> String:
	return _current_flow.name

var in_expression_evaluation: bool:
		set = set_in_expression_evaluation,
		get = get_in_expression_evaluation
func get_in_expression_evaluation() -> bool:
	return callstack.current_element.in_expression_evaluation
func set_in_expression_evaluation(value: bool):
	var current_element = callstack.current_element
	current_element.in_expression_evaluation = value

# (InkStory) -> InkStoryState
func _init(story):
	get_json()

	_story = weakref(story)

	_current_flow = InkFlow.new_with_name(DEFAULT_FLOW_NAME, story)
	output_stream_dirty()

	evaluation_stack = []

	variables_state = InkVariablesState.new(callstack, story.list_definitions)

	_visit_counts = {}
	_turn_indices = {}
	current_turn_index = -1

	randomize()
	story_seed = randi() % 100
	previous_random = 0

	go_to_start()


func go_to_start() -> void:
	var current_element = callstack.current_element
	current_element.current_pointer = InkPointer.start_of(story.main_content_container)


func switch_flow_internal(flow_name: String) -> void:
	if flow_name == null:
		InkUtils.throw_exception("Must pass a non-null string to Story.SwitchFlow")

	if _named_flows == null:
		_named_flows = {} # Dictionary<String, Flow>
		_named_flows[DEFAULT_FLOW_NAME] = _current_flow

	if flow_name == _current_flow.name:
		return

	var flow
	if _named_flows.has(flow_name):
		flow = _named_flows[flow_name]
	else:
		flow = InkFlow.new_with_name(flow_name, story)
		_named_flows[flow_name] = flow

	_current_flow = flow
	variables_state.callstack = _current_flow.callstack

	output_stream_dirty()


func switch_to_default_flow_internal() -> void:
	if _named_flows == null:
		return

	switch_flow_internal(DEFAULT_FLOW_NAME)


func remove_flow_internal(flow_name: String) -> void:
	if flow_name == null:
		InkUtils.throw_exception("Must pass a non-null string to Story.DestroyFlow")
		return

	if flow_name == DEFAULT_FLOW_NAME:
		InkUtils.throw_exception("Cannot destroy default flow")
		return

	if _current_flow.name == flow_name:
		switch_to_default_flow_internal()

	_named_flows.erase(flow_name)

# () -> InkStoryState
func copy_and_start_patching():
	var copy = InkStoryState.new(story)

	copy._patch = InkStatePatch.new(_patch)

	copy._current_flow.name = _current_flow.name
	copy._current_flow.callstack = InkCallStack.new(_current_flow.callstack)
	copy._current_flow.current_choices += _current_flow.current_choices
	copy._current_flow.output_stream += _current_flow.output_stream
	copy.output_stream_dirty()

	if _named_flows != null:
		copy._named_flows = {} # Dictionary<String, Flow>
		for named_flow_key in _named_flows.keys():
			var named_flow_value = _named_flows[named_flow_key]
			copy._named_flows[named_flow_key] = named_flow_value
		copy._named_flows[_current_flow.name] = copy._current_flow

	if has_error:
		copy.current_errors = [] # Array<String>
		copy.current_errors += current_errors

	if has_warning:
		copy.current_warnings = [] # Array<String>
		copy.current_warnings += current_warnings

	copy.variables_state = variables_state
	copy.variables_state.callstack = copy.callstack
	copy.variables_state.patch = copy._patch

	copy.evaluation_stack += evaluation_stack

	if !diverted_pointer.is_null:
		copy.diverted_pointer = diverted_pointer

	copy.previous_pointer = previous_pointer

	copy._visit_counts = _visit_counts
	copy._turn_indices = _turn_indices
	copy.current_turn_index = current_turn_index
	copy.story_seed = story_seed
	copy.previous_random = previous_random

	copy.did_safe_exit = did_safe_exit

	return copy


func restore_after_patch() -> void:
	variables_state.callstack = callstack
	variables_state.patch = _patch


func apply_any_patch() -> void:
	if _patch == null:
		return

	variables_state.apply_patch()

	for path_to_count_key in _patch.visit_counts:
		apply_count_changes(path_to_count_key, _patch.visit_counts[path_to_count_key], true)

	for path_to_index_key in _patch.turn_indices:
		apply_count_changes(path_to_index_key, _patch.turn_indices[path_to_index_key], false)

	_patch = null


func apply_count_changes(container: InkContainer, new_count: int, is_visit: bool) -> void:
	var counts = _visit_counts if is_visit else  _turn_indices
	counts[container.path._to_string()] = new_count


func write_json(writer: InkSimpleJSON.Writer) -> void:
	writer.write_object_start()

	writer.write_property_start("flows")
	writer.write_object_start()

	if _named_flows != null:
		for named_flow_key in _named_flows.keys():
			var named_flow_value = _named_flows[named_flow_key]
			writer.write_property(named_flow_key, named_flow_value.write_json)
	else:
		writer.write_property(_current_flow.name, _current_flow.write_json)

	writer.write_object_end()
	writer.write_property_end()

	writer.write_property("currentFlowName", _current_flow.name)
	writer.write_property("variablesState", variables_state.write_json)
	writer.write_property("evalStack", _anonymous_write_property_eval_stack)

	if !diverted_pointer.is_null:
		writer.write_property("currentDivertTarget", diverted_pointer.path.components_string)

	writer.write_property("visitCounts", _anonymous_write_property_visit_counts)
	writer.write_property("turnIndices", _anonymous_write_property_turn_indices)

	writer.write_property("turnIdx", current_turn_index)
	writer.write_property("storySeed", story_seed)
	writer.write_property("previousRandom", previous_random)

	writer.write_property("inkSaveVersion", INK_SAVE_STATE_VERSION)
	writer.write_property("inkFormatVersion", story.INK_VERSION_CURRENT)
	writer.write_object_end()


func load_json_obj(jobject: Dictionary) -> void:
	var jsave_version = null # Variant
	if !jobject.has("inkSaveVersion"):
		InkUtils.throw_exception("ink save format incorrect, can't load.")
		return
	else:
		jsave_version = int(jobject["inkSaveVersion"])
		if jsave_version < MIN_COMPATIBLE_LOAD_VERSION:
			InkUtils.throw_exception(
					"Ink save format isn't compatible with the current version (saw " +
					"'%d', but minimum is %d " % [jsave_version, MIN_COMPATIBLE_LOAD_VERSION] +
					"), so can't load."
			)
			return

	if jobject.has("flows"):
		var flows_obj_dict = jobject["flows"]

		if flows_obj_dict.size() == 1:
			_named_flows = null
		elif _named_flows == null:
			_named_flows = {} # Dictionary<String, Flow>
		else:
			_named_flows.clear()

		for named_flow_obj_key in flows_obj_dict.keys():
			var name = named_flow_obj_key
			var flow_obj = flows_obj_dict[named_flow_obj_key]

			var flow = InkFlow.new_with_name_and_jobject(name, story, flow_obj)

			if flows_obj_dict.size() == 1:
				_current_flow = InkFlow.new_with_name_and_jobject(name, story, flow_obj)
			else:
				_named_flows[name] = flow

		if _named_flows != null && _named_flows.size() > 1:
			var curr_flow_name = jobject["currentFlowName"]
			_current_flow = _named_flows[curr_flow_name]
	else:
		_named_flows = null
		_current_flow.name = DEFAULT_FLOW_NAME
		_current_flow.callstack.set_json_token(jobject["callstackThreads"], story)
		_current_flow.output_stream = Json.jarray_to_runtime_obj_list(jobject["outputStream"])
		_current_flow.current_choices = Json.jarray_to_runtime_obj_list(jobject["currentChoices"])

		var jchoice_threads_obj = jobject["choiceThreads"] if jobject.has("choiceThreads") else null
		_current_flow.load_flow_choice_threads(jchoice_threads_obj, story)

	output_stream_dirty()

	variables_state.set_json_token(jobject["variablesState"])
	variables_state.callstack = _current_flow.callstack

	evaluation_stack = Json.jarray_to_runtime_obj_list(jobject["evalStack"])

	if jobject.has("currentDivertTarget"):
		var current_divert_target_path = jobject["currentDivertTarget"]
		var divert_path = InkPath.new_with_components_string(current_divert_target_path._to_string())
		diverted_pointer = story.pointer_at_path(divert_path)

	_visit_counts = Json.jobject_to_int_dictionary(jobject["visitCounts"])
	_turn_indices = Json.jobject_to_int_dictionary(jobject["turnIndices"])
	current_turn_index = int(jobject["turnIdx"])
	story_seed = int(jobject["storySeed"])

	# inkjs bug
	if jobject.has("previousRandom"):
		previous_random = int(jobject["previousRandom"])
	else:
		previous_random = 0


# () -> void
func reset_errors() -> void:
	current_errors = null
	current_warnings = null


# (Array<InkObject>?) -> void
func reset_output(objs = null) -> void:
	output_stream.clear()
	if objs != null: output_stream += objs
	output_stream_dirty()


func push_to_output_stream(obj: InkObject) -> void:
	var text = obj as InkStringValue
	if text:
		var list_text = try_splitting_head_tail_whitespace(text)
		if list_text != null:
			for text_obj in list_text:
				push_to_output_stream_individual(text_obj)

			output_stream_dirty()
			return

	push_to_output_stream_individual(obj)
	output_stream_dirty()


func pop_from_output_stream(count: int) -> void:
	InkUtils.remove_range(output_stream, output_stream.size() - count, count)
	output_stream_dirty()


func try_splitting_head_tail_whitespace(single: InkStringValue):
	var _str = single.value

	var head_first_newline_idx = -1
	var head_last_newline_idx = -1

	var i = 0
	while (i < _str.length()):
		var c = _str[i]
		if (c == "\n"):
			if head_first_newline_idx == -1:
				head_first_newline_idx = i
			head_last_newline_idx = i
		elif c == " " || c == "\t":
			i += 1
			continue
		else:
			break
		i += 1


	var tail_last_newline_idx = -1
	var tail_first_newline_idx = -1

	var j = _str.length() - 1
	while (j >= 0):
		var c = _str[j]
		if (c == "\n"):
			if tail_last_newline_idx == -1:
				tail_last_newline_idx = j
			tail_first_newline_idx = j
		elif c == ' ' || c == '\t':
			j -= 1
			continue
		else:
			break
		j -= 1

	if head_first_newline_idx == -1 && tail_last_newline_idx == -1:
		return null

	var list_texts = [] # Array<StringValue>
	var inner_str_start = 0
	var inner_str_end = _str.length()

	if head_first_newline_idx != -1:
		if head_first_newline_idx > 0:
			var leading_spaces = InkStringValue.new_with(_str.substr(0, head_first_newline_idx))
			list_texts.append(leading_spaces)

		list_texts.append(InkStringValue.new_with("\n"))
		inner_str_start = head_last_newline_idx + 1

	if tail_last_newline_idx != -1:
		inner_str_end = tail_first_newline_idx

	if inner_str_end > inner_str_start:
		var inner_str_text = _str.substr(inner_str_start, inner_str_end - inner_str_start)
		list_texts.append(InkStringValue.new_with(inner_str_text))

	if tail_last_newline_idx != -1 && tail_first_newline_idx > head_last_newline_idx:
		list_texts.append(InkStringValue.new_with("\n"))
		if tail_last_newline_idx < _str.length() - 1:
			var num_spaces = (_str.length() - tail_last_newline_idx) - 1
			var trailing_spaces = InkStringValue.new_with(_str.substr(tail_last_newline_idx + 1, num_spaces))
			list_texts.append(trailing_spaces)

	return list_texts


func push_to_output_stream_individual(obj: InkObject) -> void:
	var glue = obj as InkGlue
	var text = obj as InkStringValue

	var include_in_output = true

	if glue:
		trim_newlines_from_output_stream()
		include_in_output = true
	elif text:
		var function_trim_index = -1
		var curr_el = callstack.current_element
		if curr_el.type == PushPopType.FUNCTION:
			function_trim_index = curr_el.function_start_in_ouput_stream

		var glue_trim_index = -1
		var i = output_stream.size() - 1
		while (i >= 0):
			var o = output_stream[i]
			var c = o as InkControlCommand
			var g = o as InkGlue

			if g:
				glue_trim_index = i
				break
			elif c && c.command_type == InkControlCommand.CommandType.BEGIN_STRING:
				if i >= function_trim_index:
					function_trim_index = -1

				break

			i -= 1

		var trim_index = -1
		if glue_trim_index != -1 && function_trim_index != -1:
			trim_index = min(function_trim_index, glue_trim_index)
		elif glue_trim_index != -1:
			trim_index = glue_trim_index
		else:
			trim_index = function_trim_index

		if trim_index != -1:
			if text.is_newline:
				include_in_output = false
			elif text.is_non_whitespace:

				if glue_trim_index > -1:
					remove_existing_glue()

				if function_trim_index > -1:
					var callstack_elements = callstack.elements
					var j = callstack_elements.size() - 1
					while j >= 0:
						var el = callstack_elements[j]
						if el.type == PushPopType.FUNCTION:
							el.function_start_in_ouput_stream = -1
						else:
							break

						j -= 1
		elif text.is_newline:
			if output_stream_ends_in_newline || !output_stream_contains_content:
				include_in_output = false

	if include_in_output:
		output_stream.append(obj)
		output_stream_dirty()


func trim_newlines_from_output_stream() -> void:
	var remove_whitespace_from = -1 # int

	var i = output_stream.size() - 1
	while i >= 0:
		var obj = output_stream[i]
		var cmd = obj as InkControlCommand
		var txt = obj as InkStringValue

		if cmd || (txt && txt.is_non_whitespace):
			break
		elif txt && txt.is_newline:
			remove_whitespace_from = i

		i -= 1

	if remove_whitespace_from >= 0:
		i = remove_whitespace_from
		while i < output_stream.size():
			var text = output_stream[i] as InkStringValue
			if text:
				output_stream.remove_at(i)
			else:
				i += 1

	output_stream_dirty()


func remove_existing_glue() -> void:
	var i = output_stream.size() - 1
	while (i >= 0):
		var c = output_stream[i]
		if c is InkGlue:
			output_stream.remove_at(i)
		elif c is InkControlCommand:
			break

		i -= 1

	output_stream_dirty()


var output_stream_ends_in_newline: bool: get = get_output_stream_ends_in_newline
func get_output_stream_ends_in_newline() -> bool:
	if output_stream.size() > 0:
		var i = output_stream.size() - 1
		while (i >= 0):
			var obj = output_stream[i]
			if obj is InkControlCommand:
				break
			var text = output_stream[i] as InkStringValue
			if text:
				if text.is_newline:
					return true
				elif text.is_non_whitespace:
					break

			i -= 1

	return false


var output_stream_contains_content: bool: get = get_output_stream_contains_content
func get_output_stream_contains_content() -> bool:
	for content in output_stream:
		if content is InkStringValue:
			return true

	return false


var in_string_evaluation: bool: get = get_in_string_evaluation
func get_in_string_evaluation() -> bool:
	var i = output_stream.size() - 1

	while (i >= 0):
		var cmd = output_stream[i] as InkControlCommand
		if cmd && cmd.command_type == InkControlCommand.CommandType.BEGIN_STRING:
			return true

		i -= 1

	return false


# (InkObject) -> void
func push_evaluation_stack(obj: InkObject) -> void:
	var list_value = obj as InkListValue
	if list_value:
		var raw_list = list_value.value
		if raw_list.origin_names != null:
			if raw_list.origins == null: raw_list.origins = [] # Array<ListDefinition>
			raw_list.origins.clear()

			for n in raw_list.origin_names:
				var def: InkTryGetResult = story.list_definitions.try_list_get_definition(n)

				if raw_list.origins.find(def.result) < 0:
					raw_list.origins.append(def.result)

	evaluation_stack.append(obj)


# () -> InkObject
func peek_evaluation_stack() -> InkObject:
	return evaluation_stack.back()


# This method combines both methods found in upstream.
# (int) -> InkObject | Array<InkObject>
func pop_evaluation_stack(number_of_objects: int = -1):
	if number_of_objects == -1:
		# This code raises an exception to match the behaviour of upstream.
		# `pop_back` doesn't raise an error on an empty collection.
		if evaluation_stack.size() == 0:
			InkUtils.throw_exception("trying to pop an empty evaluation stack")
		else :
			return evaluation_stack.pop_back()

	if number_of_objects > evaluation_stack.size():
		InkUtils.throw_exception("trying to pop too many objects")
		return []

	var popped = InkUtils.get_range(evaluation_stack,
								evaluation_stack.size() - number_of_objects,
								number_of_objects)

	InkUtils.remove_range(
		evaluation_stack,
		evaluation_stack.size() - number_of_objects, number_of_objects
	)
	return popped


# () -> void
func force_end() -> void:
	callstack.reset()

	_current_flow.current_choices.clear()

	current_pointer = InkPointer.new_null()
	previous_pointer = InkPointer.new_null()

	did_safe_exit = true


func trim_whitespace_from_function_end() -> void:
	assert(callstack.current_element.type == PushPopType.FUNCTION)

	var function_start_point = callstack.current_element.function_start_in_ouput_stream

	if function_start_point == -1:
		function_start_point = 0

	var i = output_stream.size() - 1
	while (i >= function_start_point):
		var obj = output_stream[i]
		var txt = obj as InkStringValue
		var cmd = obj as InkControlCommand
		if !txt:
			i -= 1
			continue
		if cmd: break

		if txt.is_newline || txt.is_inline_whitespace:
			output_stream.remove_at(i)
			output_stream_dirty()
		else:
			break

		i -= 1


# (PushPopType?) -> void
func pop_callstack(pop_type = null) -> void:
	if (callstack.current_element.type == PushPopType.FUNCTION):
		trim_whitespace_from_function_end()

	callstack.pop(pop_type)


# (InkPath, bool) -> void
func set_chosen_path(path: InkPath, incrementing_turn_index: bool) -> void:
	_current_flow.current_choices.clear()

	var new_pointer = story.pointer_at_path(path)

	if !new_pointer.is_null && new_pointer.index == -1:
		new_pointer = InkPointer.new(new_pointer.container, 0)

	current_pointer = new_pointer

	if incrementing_turn_index:
		current_turn_index += 1


# (InkContainer, Array<InkObject>?) -> void
func start_function_evaluation_from_game(func_container: InkContainer, arguments) -> void:
	callstack.push(PushPopType.FUNCTION_EVALUATION_FROM_GAME, evaluation_stack.size())
	var current_element = callstack.current_element
	current_element.current_pointer = InkPointer.start_of(func_container)

	pass_arguments_to_evaluation_stack(arguments)


# (Array<InkObject>?) -> void
func pass_arguments_to_evaluation_stack(arguments) -> void:
	if arguments != null:
		var i = 0
		while (i < arguments.size()):
			if !(arguments[i] is int || arguments[i] is float || arguments[i] is String || ((arguments[i] is Object) && arguments[i] is InkList)):
				InkUtils.throw_argument_exception(
						"ink arguments when calling EvaluateFunction / " +
						"ChoosePathStringWithParameters must be int, " +
						"float, string or InkList. Argument was " +
						("null" if arguments[i] == null else InkUtils.typename_of(arguments[i]))
				)
				return

			push_evaluation_stack(InkValue.create(arguments[i]))

			i += 1


# () -> bool
func try_exit_function_evaluation_from_game() -> bool:
	if callstack.current_element.type == PushPopType.FUNCTION_EVALUATION_FROM_GAME:
		current_pointer = InkPointer.new_null()
		did_safe_exit = true
		return true

	return false


# () -> Variant
func complete_function_evaluation_from_game():
	if callstack.current_element.type != PushPopType.FUNCTION_EVALUATION_FROM_GAME:
		InkUtils.throw_exception(
				"Expected external function evaluation to be complete. Stack trace: %s" % \
				callstack.callstack_trace
		)
		return null

	var original_evaluation_stack_height = callstack.current_element.evaluation_stack_height_when_pushed

	var returned_obj = null
	while (evaluation_stack.size() > original_evaluation_stack_height):
		var popped_obj = pop_evaluation_stack()
		if returned_obj == null:
			returned_obj = popped_obj

	pop_callstack(PushPopType.FUNCTION_EVALUATION_FROM_GAME)

	if returned_obj:
		if returned_obj is InkVoid:
			return null

		var return_val = returned_obj as InkValue

		if return_val.value_type == ValueType.DIVERT_TARGET:
			return return_val.value_object._to_string()

		return return_val.value_object

	return null


func add_error(message: String, is_warning: bool) -> void:
	if !is_warning:
		if current_errors == null:
			current_errors = [] # Array<string>
		current_errors.append(message)
	else:
		if current_warnings == null:
			current_warnings = [] # Array<string>
		current_warnings.append(message)


func output_stream_dirty() -> void:
	_output_stream_text_dirty = true
	_output_stream_tags_dirty = true

# ############################################################################ #

# Dictionary<string, Int>
var _visit_counts: Dictionary

# Dictionary<string, Int>
var _turn_indices: Dictionary

var _output_stream_text_dirty: bool = true # bool
var _output_stream_tags_dirty: bool = true # bool

var _patch # StatePatch?

var _current_flow = null # Flow?
var _named_flows = null # Dictionary<String, Flow>?
const DEFAULT_FLOW_NAME: String = "DEFAULT_FLOW" # String


# C# Actions & Delegates ##################################################### #

func _anonymous_write_property_eval_stack(writer) -> void:
	Json.write_list_runtime_objs(writer, evaluation_stack)

func _anonymous_write_property_visit_counts(writer) -> void:
	Json.write_int_dictionary(writer, _visit_counts)

func _anonymous_write_property_turn_indices(writer) -> void:
	Json.write_int_dictionary(writer, _turn_indices)


# ############################################################################ #

var Json : get = get_Json
func get_Json():
	return _Json.get_ref()
var _Json: WeakRef = WeakRef.new()

func get_json():
	var InkRuntime = Engine.get_main_loop().root.get_node("__InkRuntime")

	InkUtils.__assert__(
			InkRuntime != null,
			str("Could not retrieve 'InkRuntime' singleton from the scene tree.")
	)

	_Json = weakref(InkRuntime.json)

# ############################################################################ #

func _get_runtime() -> Node:
	return Engine.get_main_loop().root.get_node("__InkRuntime")
