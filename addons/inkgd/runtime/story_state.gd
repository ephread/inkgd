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

extends "res://addons/inkgd/runtime/ink_base.gd"

# ############################################################################ #
# Self-reference
# ############################################################################ #

static func StoryState():
	return load("res://addons/inkgd/runtime/story_state.gd")

# ############################################################################ #
# Imports
# ############################################################################ #

var PushPopType = preload("res://addons/inkgd/runtime/push_pop.gd").PushPopType
var Pointer = load("res://addons/inkgd/runtime/pointer.gd")
var CallStack = load("res://addons/inkgd/runtime/callstack.gd")
var VariablesState = load("res://addons/inkgd/runtime/variables_state.gd")
var InkPath = load("res://addons/inkgd/runtime/ink_path.gd")
var Ink = load("res://addons/inkgd/runtime/value.gd")
var ControlCommand = load("res://addons/inkgd/runtime/control_command.gd")
var SimpleJson = load("res://addons/inkgd/runtime/simple_json.gd")
var StatePatch = load("res://addons/inkgd/runtime/state_patch.gd")
var Flow = load("res://addons/inkgd/runtime/flow.gd")

# ############################################################################ #

const INK_SAVE_STATE_VERSION = 9
const MIN_COMPATIBLE_LOAD_VERSION = 8

signal on_did_load_state()

# () -> String
func to_json():
	var writer = SimpleJson.Writer.new()
	write_json(writer)
	return writer.to_string()

# (String) -> void
func load_json(json):
	var jobject = SimpleJson.text_to_dictionary(json)
	load_json_obj(jobject)
	emit_signal("on_did_load_state")

# (String) -> int
func visit_count_at_path_string(path_string):
	if self._patch != null:
		var container = self.story.content_at_path(Path.new_with_components_string(path_string)).container
		if container == null:
			Utils.throw_exception(str("Content at path not found: ", path_string))
			return 0

		var visit_count = self._patch.try_get_visit_count(container)
		if visit_count.exists:
			return visit_count.result

	if self._visit_counts.has(path_string):
		return self._visit_counts[path_string]

	return 0

# (InkContainer) -> int
func visit_count_for_container(container):
	if !container.visits_should_be_counted:
		self.story.error(
			str("Read count for target (", container.name, " - on ",
				container.debugMetadata, ") unknown. The story may need to",
				"be compiled with countAllVisits flag (-c).")
		)
		return 0

	var count = 0

	if self._patch != null:
		var visit_count = self._patch.try_get_visit_count(container)
		if visit_count.exists:
			return visit_count.result

	var container_path_str = container.path.to_string()

	if self._visit_counts.has(container_path_str):
		count = self._visit_counts[container_path_str]

	return count


# (InkContainer) -> void
func increment_visit_count_for_container(container):
	if self._patch != null:
		var curr_count = visit_count_for_container(container)
		curr_count += 1
		self._patch.set_visit_count(container, curr_count)
		return

	var count = 0
	var container_path_str = container.path.to_string()
	if self._visit_counts.has(container_path_str):
		count = self._visit_counts[container_path_str]
	count += 1

	self._visit_counts[container_path_str] = count

# (InkContainer) -> void
func record_turn_index_visit_to_container(container):
	if self._patch != null:
		self._patch.set_turn_index(container, self.current_turn_index)
		return

	var container_path_str = container.path.to_string()

	self._turn_indices[container_path_str] = self.current_turn_index

# (InkContainer) -> ink
func turns_since_for_container(container):
	if !container.turn_index_should_be_counted:
		self.story.error(
			str("TURNS_SINCE() for target (", container.name, " - on ",
				container.debugMetadata, ") unknown. The story may need",
				"to be compiled with countAllVisits flag (-c).")
				)
		return null

	if self._patch != null:
		var turn_index = self._patch.try_get_turn_index(container)
		if turn_index.exists:
			return self.current_turn_index - turn_index.result

	var container_path_str = container.path.to_string()
	if self._turn_indices.has(container_path_str):
		return self.current_turn_index - self._turn_indices[container_path_str]
	else:
		return -1

var callstack_depth setget , get_callstack_depth # int
func get_callstack_depth():
	return self.callstack.depth

var output_stream setget , get_output_stream # Array<InkObject>
func get_output_stream():
	return self._current_flow.output_stream

var current_choices setget , get_current_choices # Array<Choice>
func get_current_choices():
	if self.can_continue: return []
	return self._current_flow.current_choices

var generated_choices setget , get_generated_choices # Array<Choice>
func get_generated_choices():
	return self._current_flow.current_choices

var current_errors = null # Array<String>
var current_warnings = null # Array<String>
var variables_state = null # VariableState

var callstack setget , get_callstack # CallStack
func get_callstack():
	return self._current_flow.callstack

var evaluation_stack = null # Array<InkObject>
var diverted_pointer = Pointer.null() # Pointer

var current_turn_index = 0 # int
var story_seed = 0 # int
var previous_random = 0 # int
var did_safe_exit = false # bool

var story setget , get_story
func get_story():
	return _story.get_ref()
var _story = WeakRef.new()

var current_path_string setget , get_current_path_string # String
func get_current_path_string():
	var pointer = self.current_pointer
	if pointer.is_null:
		return null
	else:
		return pointer.path.to_string()

var current_pointer setget set_current_pointer, get_current_pointer # Pointer
func get_current_pointer():
	var pointer = self.callstack.current_element.current_pointer
	return self.callstack.current_element.current_pointer.duplicate()

func set_current_pointer(value):
	var current_element = self.callstack.current_element
	current_element.current_pointer = value.duplicate()

var previous_pointer setget set_previous_pointer, get_previous_pointer # Pointer
func get_previous_pointer():
	return self.callstack.current_thread.previous_pointer.duplicate()

func set_previous_pointer(value):
	var current_thread = self.callstack.current_thread
	current_thread.previous_pointer = value.duplicate()

var can_continue setget , get_can_continue # bool
func get_can_continue():
	return !self.current_pointer.is_null && !self.has_error

var has_error setget , get_has_error # bool
func get_has_error():
	return self.current_errors != null && self.current_errors.size() > 0

var has_warning setget , get_has_warning # bool
func get_has_warning():
	return self.current_warnings != null && self.current_warnings.size() > 0

var current_text setget , get_current_text # String
func get_current_text():
	if self._output_stream_text_dirty:
		var _str = ""

		for output_obj in self.output_stream:
			var text_content = Utils.as_or_null(output_obj, "StringValue")
			if text_content != null:
				_str += text_content.value

		self._current_text = self.clean_output_whitespace(_str)

		self._output_stream_text_dirty = false

	return self._current_text

var _current_text = null # String

# (String) -> String
func clean_output_whitespace(str_to_clean):
	var _str = ""

	var current_whitespace_start = -1
	var start_of_line = 0

	var i = 0
	while(i < str_to_clean.length()):
		var c = str_to_clean[i]

		var is_inline_whitespace = (c == " " || c == "\t")

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

var current_tags setget , get_current_tags # Array<String>
func get_current_tags():
	if self._output_stream_tags_dirty:
		self._current_tags = [] # Array<String>

		for output_obj in self.output_stream:
			var tag = Utils.as_or_null(output_obj, "Tag")
			if tag != null:
				self._current_tags.append(tag.text)

		self._output_stream_tags_dirty = false

	return self._current_tags

var _current_tags # Array<String>

var current_flow_name setget , get_current_flow_name # String
func get_current_flow_name():
	return self._current_flow.name

var in_expression_evaluation setget set_in_expression_evaluation, get_in_expression_evaluation # bool
func get_in_expression_evaluation():
	return self.callstack.current_element.in_expression_evaluation
func set_in_expression_evaluation(value):
	var current_element = self.callstack.current_element
	current_element.in_expression_evaluation = value

# (Story) -> StoryState
func _init(story):
	get_json()

	self._story = weakref(story)

	self._current_flow = Flow.new_with_name(DEFAULT_FLOW_NAME, story)
	self.output_stream_dirty()

	self.evaluation_stack = [] # Array<InkObject>

	self.variables_state = VariablesState.new(self.callstack, self.story.list_definitions)

	self._visit_counts = {} # Dictionary<String, int>
	self._turn_indices = {} # Dictionary<String, int>
	self.current_turn_index = -1

	randomize()
	self.story_seed = randi() % 100
	self.previous_random = 0

	self.go_to_start()

# () -> void
func go_to_start():
	var current_element = self.callstack.current_element
	current_element.current_pointer = Pointer.start_of(self.story.main_content_container)

# (String) -> void
func switch_flow_internal(flow_name):
	if flow_name == null:
		Utils.throw_exception("Must pass a non-null string to Story.SwitchFlow")

	if self._named_flows == null:
		self._named_flows = {} # Dictionary<String, Flow>
		self._named_flows[DEFAULT_FLOW_NAME] = self._current_flow

	if flow_name == self._current_flow.name:
		return

	var flow
	if self._named_flows.has(flow_name):
		flow = self._named_flows[flow_name]
	else:
		flow = Flow.new_with_name(flow_name, self.story)
		self._named_flows[flow_name] = flow

	self._current_flow = flow
	self.variables_state.callstack = self._current_flow.callstack

	self.output_stream_dirty()

# () -> void
func switch_to_default_flow_internal():
	if self._named_flows == null:
		return

	self.switch_flow_internal(DEFAULT_FLOW_NAME)

# () -> void
func remove_flow_internal(flow_name):
	if flow_name == null:
		Utils.throw_exception("Must pass a non-null string to Story.DestroyFlow")
		return

	if flow_name == DEFAULT_FLOW_NAME:
		Utils.throw_exception("Cannot destroy default flow")
		return

	if self._current_flow.name == flow_name:
		self.switch_to_default_flow_internal()

	self._named_flows.erase(flow_name)

# () -> StoryState
func copy_and_start_patching():
	var copy = StoryState().new(self.story)

	copy._patch = StatePatch.new(self._patch)

	copy._current_flow.name = self._current_flow.name
	copy._current_flow.callstack = CallStack.new(self._current_flow.callstack)
	copy._current_flow.current_choices += self._current_flow.current_choices
	copy._current_flow.output_stream += self._current_flow.output_stream
	copy.output_stream_dirty()

	if self._named_flows != null:
		copy._named_flows = {} # Dictionary<String, Flow>
		for named_flow_key in self._named_flows.keys():
			var named_flow_value = self._named_flows[named_flow_key]
			copy._named_flows[named_flow_key] = named_flow_value
		copy._named_flows[self._current_flow.name] = copy._current_flow

	if self.has_error:
		copy.current_errors = [] # Array<String>
		copy.current_errors += self.current_errors

	if self.has_warning:
		copy.current_warnings = [] # Array<String>
		copy.current_warnings += self.current_warnings

	copy.variables_state = variables_state
	copy.variables_state.callstack = copy.callstack
	copy.variables_state.patch = copy._patch

	copy.evaluation_stack += self.evaluation_stack

	if !diverted_pointer.is_null:
		copy.diverted_pointer = self.diverted_pointer.duplicate()

	copy.previous_pointer = self.previous_pointer.duplicate()

	copy._visit_counts = self._visit_counts
	copy._turn_indices = self._turn_indices
	copy.current_turn_index = self.current_turn_index
	copy.story_seed = self.story_seed
	copy.previous_random = self.previous_random

	copy.did_safe_exit = self.did_safe_exit

	return copy

# () -> void
func restore_after_patch():
	self.variables_state.callstack = self.callstack
	self.variables_state.patch = self._patch

# () -> void
func apply_any_patch():
	if self._patch == null:
		return

	self.variables_state.apply_patch()

	for path_to_count_key in self._patch.visit_counts:
		apply_count_changes(path_to_count_key, self._patch.visit_counts[path_to_count_key], true)

	for path_to_index_key in self._patch.turn_indices:
		apply_count_changes(path_to_index_key, self._patch.turn_indices[path_to_index_key], false)

	self._patch = null

# (InkContainer, Int, Bool) -> void
func apply_count_changes(container, new_count, is_visit):
	var counts = self._visit_counts if is_visit else  self._turn_indices
	counts[container.path.to_string()] = new_count

# (SimpleJson.Writer) -> void
func write_json(writer):
	writer.write_object_start()

	writer.write_property_start("flows")
	writer.write_object_start()

	if self._named_flows != null:
		for named_flow_key in self._named_flows.keys():
			var named_flow_value = self._named_flows[named_flow_key]
			writer.write_property(named_flow_key, funcref(named_flow_value, "write_json"))
	else:
		writer.write_property(self._current_flow.name, funcref(self._current_flow, "write_json"))

	writer.write_object_end()
	writer.write_property_end()

	writer.write_property("currentFlowName", self._current_flow.name)
	writer.write_property("variablesState", funcref(self.variables_state, "write_json"))
	writer.write_property("evalStack", funcref(self, "_anonymous_write_property_eval_stack"))

	if !self.diverted_pointer.is_null:
		writer.write_property("currentDivertTarget", self.diverted_pointer.path.components_string)

	writer.write_property("visitCounts", funcref(self, "_anonymous_write_property_visit_counts"))
	writer.write_property("turnIndices", funcref(self, "_anonymous_write_property_turn_indices"))

	writer.write_property("turnIdx", self.current_turn_index)
	writer.write_property("storySeed", self.story_seed)
	writer.write_property("previousRandom", self.previous_random)

	writer.write_property("inkSaveVersion", INK_SAVE_STATE_VERSION)
	writer.write_property("inkFormatVersion", self.story.INK_VERSION_CURRENT)
	writer.write_object_end()

func load_json_obj(jobject):
	var jsave_version = null # Variant
	if !jobject.has("inkSaveVersion"):
		Utils.throw_exception("ink save format incorrect, can't load.")
		return
	else:
		jsave_version = int(jobject["inkSaveVersion"])
		if jsave_version < MIN_COMPATIBLE_LOAD_VERSION:
			Utils.throw_exception(str(
				"Ink save format isn't compatible with the current version (saw '",
				jsave_version, "', but minimum is ", MIN_COMPATIBLE_LOAD_VERSION,
				"), so can't load."
			))
			return

	if jobject.has("flows"):
		var flows_obj_dict = jobject["flows"]

		if flows_obj_dict.size() == 1:
			self._named_flows = null
		elif self._named_flows == null:
			self._named_flows = {} # Dictionary<String, Flow>
		else:
			self._named_flows.clear()

		for named_flow_obj_key in flows_obj_dict.keys():
			var name = named_flow_obj_key
			var flow_obj = flows_obj_dict[named_flow_obj_key]

			var flow = Flow.new_with_name_and_jobject(name, self.story, flow_obj)

			if flows_obj_dict.size() == 1:
				self._current_flow = Flow.new_with_name_and_jobject(name, self.story, flow_obj)
			else:
				self._named_flows[name] = flow

		if self._named_flows != null && self._named_flows.size() > 1:
			var curr_flow_name = jobject["currentFlowName"]
			self._current_flow = self._named_flows[curr_flow_name]
	else:
		self._named_flows = null
		self._current_flow.name = DEFAULT_FLOW_NAME
		self._current_flow.callstack.set_json_token(jobject["callstackThreads"], self.story)
		self._current_flow.output_stream = self.Json.jarray_to_runtime_obj_list(jobject["outputStream"])
		self._current_flow.current_choices = self.Json.jarray_to_runtime_obj_list(jobject["currentChoices"])

		var jchoice_threads_obj = jobject["choiceThreads"] if jobject.has("choiceThreads") else null
		self._current_flow.load_flow_choice_threads(jchoice_threads_obj, self.story)

	self.output_stream_dirty()

	self.variables_state.set_json_token(jobject["variablesState"])
	self.variables_state.callstack = self._current_flow.callstack

	self.evaluation_stack = self.Json.jarray_to_runtime_obj_list(jobject["evalStack"])

	if jobject.has("currentDivertTarget"):
		var current_divert_target_path = jobject["currentDivertTarget"]
		var divert_path = InkPath.new_with_components_string(current_divert_target_path.to_string())
		self.diverted_pointer = self.story.pointer_at_path(divert_path)

	self._visit_counts = self.Json.jobject_to_int_dictionary(jobject["visitCounts"])
	self._turn_indices = self.Json.jobject_to_int_dictionary(jobject["turnIndices"])
	self.current_turn_index = int(jobject["turnIdx"])
	self.story_seed = int(jobject["storySeed"])

	# inkjs bug
	if jobject.has("previousRandom"):
		self.previous_random = int(jobject["previousRandom"])
	else:
		self.previous_random = 0

	# inkgd: Restore ability to continue.
	var InkRuntime = _get_runtime()
	if InkRuntime != null:
		InkRuntime.should_interrupt = false

# () -> void
func reset_errors():
	self.current_errors = null
	self.current_warnings = null

# (Array<InkObject>) -> void
func reset_output(objs = null):
	self.output_stream.clear()
	if objs != null: self.output_stream += objs
	self.output_stream_dirty()

# (InkObject) -> void
func push_to_output_stream(obj):
	var text = Utils.as_or_null(obj, "StringValue")
	if text:
		var list_text = self.try_splitting_head_tail_whitespace(text)
		if list_text != null:
			for text_obj in list_text:
				self.push_to_output_stream_individual(text_obj)

			self.output_stream_dirty()
			return

	self.push_to_output_stream_individual(obj)
	self.output_stream_dirty()

# (int) -> void
func pop_from_output_stream(count):
	Utils.remove_range(self.output_stream, self.output_stream.size() - count, count)
	self.output_stream_dirty()

# (StringValue) -> StringValue
func try_splitting_head_tail_whitespace(single):
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
			var leading_spaces = Ink.StringValue.new_with(_str.substr(0, head_first_newline_idx))
			list_texts.append(leading_spaces)

		list_texts.append(Ink.StringValue.new_with("\n"))
		inner_str_start = head_last_newline_idx + 1

	if tail_last_newline_idx != -1:
		inner_str_end = tail_first_newline_idx

	if inner_str_end > inner_str_start:
		var inner_str_text = _str.substr(inner_str_start, inner_str_end - inner_str_start)
		list_texts.append(Ink.StringValue.new(inner_str_text))

	if tail_last_newline_idx != -1 && tail_first_newline_idx > head_last_newline_idx:
		list_texts.append(Ink.StringValue.new("\n"))
		if tail_last_newline_idx < _str.length() - 1:
			var num_spaces = (_str.length() - tail_last_newline_idx) - 1
			var trailing_spaces = Ink.StringValue.new(_str.substr(tail_last_newline_idx + 1, num_spaces))
			list_texts.append(trailing_spaces)

	return list_texts

# (InkObject) -> void
func push_to_output_stream_individual(obj):
	var glue = Utils.as_or_null(obj, "Glue")
	var text = Utils.as_or_null(obj, "StringValue")

	var include_in_output = true

	if glue:
		self.trim_newlines_from_output_stream()
		include_in_output = true
	elif text:
		var function_trim_index = -1
		var curr_el = self.callstack.current_element
		if curr_el.type == PushPopType.FUNCTION:
			function_trim_index = curr_el.function_start_in_ouput_stream

		var glue_trim_index = -1
		var i = self.output_stream.size() - 1
		while (i >= 0):
			var o = self.output_stream[i]
			var c = Utils.as_or_null(o, "ControlCommand")
			var g = Utils.as_or_null(o, "Glue")

			if g:
				glue_trim_index = i
				break
			elif c && c.command_type == ControlCommand.CommandType.BEGIN_STRING:
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
					self.remove_existing_glue()

				if function_trim_index > -1:
					var callstack_elements = self.callstack.elements
					var j = callstack_elements.size() - 1
					while j >= 0:
						var el = callstack_elements[j]
						if el.type == PushPopType.FUNCTION:
							el.function_start_in_ouput_stream = -1
						else:
							break

						j -= 1
		elif text.is_newline:
			if self.output_stream_ends_in_newline || !self.output_stream_contains_content:
				include_in_output = false

	if include_in_output:
		self.output_stream.append(obj)
		self.output_stream_dirty()

# () -> void
func trim_newlines_from_output_stream():
	var remove_whitespace_from = -1 # int

	var i = self.output_stream.size() - 1
	while i >= 0:
		var obj = self.output_stream[i]
		var cmd = Utils.as_or_null(obj, "ControlCommand")
		var txt = Utils.as_or_null(obj, "StringValue")

		if cmd || (txt && txt.is_non_whitespace):
			break
		elif txt && txt.is_newline:
			remove_whitespace_from = i

		i -= 1

	if remove_whitespace_from >= 0:
		i = remove_whitespace_from
		while i < self.output_stream.size():
			var text = Utils.as_or_null(self.output_stream[i], "StringValue")
			if text:
				self.output_stream.remove(i)
			else:
				i += 1

	self.output_stream_dirty()

# () -> void
func remove_existing_glue():
	var i = self.output_stream.size() - 1
	while (i >= 0):
		var c = self.output_stream[i]
		if Utils.is_ink_class(c, "Glue"):
			self.output_stream.remove(i)
		elif Utils.is_ink_class(c, "ControlCommand"):
			break

		i -= 1

	self.output_stream_dirty()

var output_stream_ends_in_newline setget , get_output_stream_ends_in_newline # bool
func get_output_stream_ends_in_newline():
	if self.output_stream.size() > 0:
		var i = self.output_stream.size() - 1
		while (i >= 0):
			var obj = self.output_stream[i]
			if Utils.is_ink_class(obj, "ControlCommand"):
				break
			var text = Utils.as_or_null(self.output_stream[i], "StringValue")
			if text:
				if text.is_newline:
					return true
				elif text.is_non_whitespace:
					break

			i -= 1

	return false

var output_stream_contains_content setget , get_output_stream_contains_content # bool
func get_output_stream_contains_content():
	for content in self.output_stream:
		if Utils.is_ink_class(content, "StringValue"):
			return true

	return false

var in_string_evaluation setget , get_in_string_evaluation # bool
func get_in_string_evaluation():
	var i = self.output_stream.size() - 1

	while (i >= 0):
		var cmd = Utils.as_or_null(self.output_stream[i], "ControlCommand")
		if cmd && cmd.command_type == ControlCommand.CommandType.BEGIN_STRING:
			return true

		i -= 1

	return false

# (InkObject) -> void
func push_evaluation_stack(obj):
	var list_value = Utils.as_or_null(obj, "ListValue")
	if list_value:
		var raw_list = list_value.value
		if raw_list.origin_names != null:
			if raw_list.origins == null: raw_list.origins = [] # Array<ListDefinition>
			raw_list.origins.clear()

			for n in raw_list.origin_names:
				var def = self.story.list_definitions.try_list_get_definition(n)

				if raw_list.origins.find(def.result) < 0:
					raw_list.origins.append(def.result)

	self.evaluation_stack.append(obj)

# () -> InkObject
func peek_evaluation_stack():
	return self.evaluation_stack.back()

# (int) -> Array<InkObject>
func pop_evaluation_stack(number_of_objects = -1):
	if number_of_objects == -1:
		return self.evaluation_stack.pop_back()

	if number_of_objects > self.evaluation_stack.size():
		Utils.throw_argument_exception("trying to pop too many objects")
		return

	var popped = Utils.get_range(self.evaluation_stack,
								 self.evaluation_stack.size() - number_of_objects,
								 number_of_objects)

	Utils.remove_range(
		self.evaluation_stack,
		self.evaluation_stack.size() - number_of_objects, number_of_objects
	)
	return popped

# () -> void
func force_end():
	self.callstack.reset()

	self._current_flow.current_choices.clear()

	self.current_pointer = Pointer.null()
	self.previous_pointer = Pointer.null()

	self.did_safe_exit = true

# () -> void
func trim_whitespace_from_function_end():
	assert(self.callstack.current_element.type == PushPopType.FUNCTION)

	var function_start_point = self.callstack.current_element.function_start_in_ouput_stream

	if function_start_point == -1:
		function_start_point = 0

	var i = self.output_stream.size() - 1
	while (i >= function_start_point):
		var obj = self.output_stream[i]
		var txt = Utils.as_or_null(obj, "StringValue")
		var cmd = Utils.as_or_null(obj, "ControlCommand")
		if !txt:
			i -= 1
			continue
		if cmd: break

		if txt.is_newline || txt.is_inline_whitespace:
			self.output_stream.remove(i)
			self.output_stream_dirty()
		else:
			break

		i -= 1

# (PushPopType) -> void
func pop_callstack(pop_type = null):
	if (self.callstack.current_element.type == PushPopType.FUNCTION):
		self.trim_whitespace_from_function_end()

	self.callstack.pop(pop_type)

# (InkPath, bool) -> void
func set_chosen_path(path, incrementing_turn_index):
	self._current_flow.current_choices.clear()

	var new_pointer = self.story.pointer_at_path(path)

	if !new_pointer.is_null && new_pointer.index == -1:
		new_pointer.index = 0

	self.current_pointer = new_pointer

	if incrementing_turn_index:
		self.current_turn_index += 1

# (InkContainer, [InkObject]) -> void
func start_function_evaluation_from_game(func_container, arguments):
	self.callstack.push(PushPopType.FUNCTION_EVALUATION_FROM_GAME, self.evaluation_stack.size())
	var current_element = self.callstack.current_element
	current_element.current_pointer = Pointer.start_of(func_container)

	self.pass_arguments_to_evaluation_stack(arguments)

# ([InkObject]) -> void
func pass_arguments_to_evaluation_stack(arguments):
	if arguments != null:
		var i = 0
		while (i < arguments.size()):
			if !(arguments[i] is int || arguments[i] is float || arguments[i] is String || ((arguments[i] is Object) && arguments[i].is_class("InkList"))):
				Utils.throw_argument_exception(str(
					"ink arguments when calling EvaluateFunction / ",
					"ChoosePathStringWithParameters must be int, ",
					"float, string or InkList. Argument was ",
					"null" if arguments[i] == null else Utils.typename_of(arguments[i])
				))
				return

			push_evaluation_stack(Ink.Value.create(arguments[i]))

			i += 1

# () -> bool
func try_exit_function_evaluation_from_game():
	if self.callstack.current_element.type == PushPopType.FUNCTION_EVALUATION_FROM_GAME:
		self.current_pointer = Pointer.null()
		self.did_safe_exit = true
		return true

	return false

# () -> Variant
func complete_function_evaluation_from_game():
	if self.callstack.current_element.type != PushPopType.FUNCTION_EVALUATION_FROM_GAME:
		Utils.throw_exception(str(
			"Expected external function evaluation to be complete. Stack trace: ",
			self.callstack_trace
		))
		return null

	var original_evaluation_stack_height = self.callstack.current_element.evaluation_stack_height_when_pushed

	var returned_obj = null
	while (self.evaluation_stack.size() > original_evaluation_stack_height):
		var popped_obj = self.pop_evaluation_stack()
		if returned_obj == null:
			returned_obj = popped_obj

	self.pop_callstack(PushPopType.FUNCTION_EVALUATION_FROM_GAME)

	if returned_obj:
		if Utils.is_ink_class(returned_obj, "Void"):
			return null

		var return_val = Utils.as_or_null(returned_obj, "Value")

		if return_val.value_type == Ink.ValueType.DIVERT_TARGET:
			return return_val.value_object.to_string()

		return return_val.value_object

	return null

# (string, bool) -> void
func add_error(message, is_warning):
	if !is_warning:
		if self.current_errors == null:
			self.current_errors = [] # Array<string>
		self.current_errors.append(message)
		if OS.is_debug_build():
			var InkRuntime = _get_runtime()
			if InkRuntime != null && InkRuntime.should_pause_execution_on_story_error:
				assert(false, message)
			else:
				push_error(message)
	else:
		if self.current_warnings == null:
			self.current_warnings = [] # Array<string>
		self.current_warnings.append(message)
		if OS.is_debug_build(): push_warning(message)

# () -> void
func output_stream_dirty():
	self._output_stream_text_dirty = true
	self._output_stream_tags_dirty = true

var _visit_counts = null # Dictionary<string, Int>
var _turn_indices = null # Dictionary<string, Int>

var _output_stream_text_dirty = true # bool
var _output_stream_tags_dirty = true # bool

var _patch # StatePatch

var _current_flow = null # Flow
var _named_flows = null # Dictionary<String, Flow>
const DEFAULT_FLOW_NAME = "DEFAULT_FLOW" # String

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type):
	return type == "StoryState" || .is_class(type)

func get_class():
	return "StoryState"

# C# Actions & Delegates ##################################################### #

func _anonymous_write_property_eval_stack(writer):
	self.Json.write_list_runtime_objs(writer, self.evaluation_stack)

func _anonymous_write_property_visit_counts(writer):
	self.Json.write_int_dictionary(writer, self._visit_counts)

func _anonymous_write_property_turn_indices(writer):
	self.Json.write_int_dictionary(writer, self._turn_indices)

# ############################################################################ #

var Json setget , get_Json
func get_Json():
	return _Json.get_ref()
var _Json = WeakRef.new()

func get_json():
	var InkRuntime = Engine.get_main_loop().root.get_node("__InkRuntime")

	Utils.assert(InkRuntime != null,
				 str("Could not retrieve 'InkRuntime' singleton from the scene tree."))

	_Json = weakref(InkRuntime.json)

# ############################################################################ #

func _get_runtime():
	return Engine.get_main_loop().root.get_node("__InkRuntime")
