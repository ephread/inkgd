# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends InkBase

class_name InkCallStack

# ############################################################################ #
# Imports
# ############################################################################ #

var PushPopType = preload("res://addons/inkgd/runtime/enums/push_pop.gd").PushPopType

# ############################################################################ #

class Element extends InkBase:

	var current_pointer := InkPointer.new_null()

	var in_expression_evaluation = false # bool
	var temporary_variables = null # Dictionary<String, InkObject>
	var type = 0 # PushPopType
	var evaluation_stack_height_when_pushed = 0 # int
	var function_start_in_ouput_stream = 0 # int

	# (PushPopType, InkPointer, bool) -> InkElement
	func _init(type, pointer, in_expression_evaluation = false):
		current_pointer = pointer
		self.in_expression_evaluation = in_expression_evaluation
		temporary_variables = {}
		self.type = type

	# () -> InkElement
	func copy():
		var copy = Element.new(type, current_pointer, in_expression_evaluation)
		copy.temporary_variables = temporary_variables.duplicate()
		copy.evaluation_stack_height_when_pushed = evaluation_stack_height_when_pushed
		copy.function_start_in_ouput_stream = function_start_in_ouput_stream
		return copy

class InkThread extends InkBase:
	
	var callstack = null # Array<Element>
	var thread_index = 0 # int
	var previous_pointer := InkPointer.new_null()

	func _init():
		get_static_json()
		callstack = []

	# Dictionary<string, object>, Story
	func _init_with(jthread_obj, story_context):
		thread_index = int(jthread_obj["threadIndex"])
		var jthread_callstack = jthread_obj["callstack"]

		for jel_tok in jthread_callstack:
			var jelement_obj = jel_tok
			var push_pop_type = int(jelement_obj["type"])

			var pointer = InkPointer.new_null()
			var current_container_path_str = null
			var current_container_path_str_token = null

			if jelement_obj.has("cPath"):
				current_container_path_str_token = jelement_obj["cPath"]
				current_container_path_str = str(current_container_path_str_token)

				var thread_pointer_result = story_context.content_at_path(InkPath.new_with_components_string(current_container_path_str))
				pointer = InkPointer.new(thread_pointer_result.container, int(jelement_obj["idx"]))

				if thread_pointer_result.obj == null:
					InkUtils.throw_exception(
							"When loading state, internal story location " +
							"couldn't be found: '%s'. " % current_container_path_str +
							"Has the story changed since this save data was created?"
					)
					return
				elif thread_pointer_result.approximate:
					story_context.warning(
							"When loading state, exact internal story location " +
							"couldn't be found: '%s', so it was" % current_container_path_str +
							"approximated to '%s' " + pointer.container.path._to_string() +
							"to recover. Has the story changed since this save data was created?"
					)

			var in_expression_evaluation = bool(jelement_obj["exp"])
			var el = Element.new(push_pop_type, pointer, in_expression_evaluation)

			var temps
			if jelement_obj.has("temp"):
				temps = jelement_obj["temp"] # Dictionary<string, object>
				el.temporary_variables = Json.jobject_to_dictionary_runtime_objs(temps)
			else:
				el.temporary_variables.clear()

			callstack.append(el)

		var prev_content_obj_path
		if jthread_obj.has("previousContentObject"):
			prev_content_obj_path = str(jthread_obj["previousContentObject"])
			var prev_path = InkPath.new_with_components_string(prev_content_obj_path)
			previous_pointer = story_context.pointer_at_path(prev_path)

	# () -> InkThread
	func copy():
		var copy = InkThread.new()
		copy.thread_index = thread_index
		for e in callstack:
			copy.callstack.append(e.copy())
		copy.previous_pointer = previous_pointer
		return copy

	# (SimpleJson.Writer) -> void
	func write_json(writer):
		writer.write_object_start()

		writer.write_property_start("callstack")
		writer.write_array_start()

		for el in callstack:
			writer.write_object_start()
			if !el.current_pointer.is_null:
				writer.write_property("cPath", el.current_pointer.container.path.components_string)
				writer.write_property("idx", el.current_pointer.index)

			writer.write_property("exp", el.in_expression_evaluation)
			writer.write_property("type", int(el.type))

			if el.temporary_variables.size() > 0:
				writer.write_property_start("temp")
				Json.write_dictionary_runtime_objs(writer, el.temporary_variables)
				writer.write_property_end()

			writer.write_object_end()

		writer.write_array_end()
		writer.write_property_end()

		writer.write_property("threadIndex", thread_index)

		if !previous_pointer.is_null:
			writer.write_property("previousContentObject", previous_pointer.resolve().path._to_string())

		writer.write_object_end()

	# ######################################################################## #

	static func new_with(jthread_obj, story_context):
		var thread = InkThread.new()
		thread._init_with(jthread_obj, story_context)
		return thread

	# ######################################################################## #
	var Json : get = get_Json
	func get_Json():
		return _Json.get_ref()

	var _Json = WeakRef.new()

	func get_static_json():
		var InkRuntime = Engine.get_main_loop().root.get_node("__InkRuntime")

		InkUtils.__assert__(InkRuntime != null,
					str("Could not retrieve 'InkRuntime' singleton from the scene tree."))

		_Json = weakref(InkRuntime.json)

# () -> Array<InkElement>
var elements : get = get_elements
func get_elements():
	return callstack

# () -> int
var depth : get = get_depth
func get_depth():
	return elements.size()

# () -> InkElement
var current_element : get = get_current_element
func get_current_element():
	var thread = _threads.back()
	var cs = thread.callstack
	return cs.back()

# () -> int
var current_element_index : get = get_current_element_index
func get_current_element_index():
	return callstack.size() - 1

# () -> InkThread
# (InkThread) -> void
var current_thread : get = get_current_thread, set = set_current_thread
func get_current_thread():
	return _threads.back()

func set_current_thread(value):
	InkUtils.__assert__(_threads.size() == 1,
				"Shouldn't be directly setting the current thread when we have a stack of them")
	_threads.clear()
	_threads.append(value)

# () -> bool
var can_pop : get = get_can_pop
func get_can_pop():
	return callstack.size() > 1

# (InkStory | CallStack) -> CallStack
func _init(story_context_or_to_copy):
	if story_context_or_to_copy is InkStory:
		var story_context = story_context_or_to_copy
		_start_of_root = InkPointer.start_of(story_context.root_content_container)
		reset()
	elif story_context_or_to_copy is InkCallStack:
		var to_copy = story_context_or_to_copy
		_threads = []
		for other_thread in to_copy._threads:
			_threads.append(other_thread.copy())
		_thread_counter = to_copy._thread_counter
		_start_of_root = to_copy._start_of_root

# () -> void
func reset():
	_threads = []
	_threads.append(InkThread.new())
	_threads[0].callstack.append(Element.new(PushPopType.TUNNEL, _start_of_root))

# (Dictionary<string, object>, InkStory) -> void
func set_json_token(jobject, story_context):
	_threads.clear()
	var jthreads = jobject["threads"]

	for jthread_tok in jthreads:
		var jthread_obj = jthread_tok
		var thread = InkThread.new_with(jthread_obj, story_context)
		_threads.append(thread)

	_thread_counter = int(jobject["threadCounter"])
	_start_of_root = InkPointer.start_of(story_context.root_content_container)


# (SimpleJson.Writer) -> void
func write_json(writer):
	writer.write_object(_anonymous_write_json)

# () -> void
func push_thread():
	var new_thread = current_thread.copy()
	_thread_counter += 1
	new_thread.thread_index = _thread_counter
	_threads.append(new_thread)

# () -> void
func fork_thread():
	var forked_thread = current_thread.copy()
	_thread_counter += 1
	forked_thread.thread_index = _thread_counter
	return forked_thread

# () -> void
func pop_thread():
	if can_pop_thread:
		_threads.erase(current_thread)
	else:
		InkUtils.throw_exception("Can't pop thread")

# () -> bool
var can_pop_thread : get = get_can_pop_thread
func get_can_pop_thread():
	return _threads.size() > 1 && !element_is_evaluate_from_game

# () -> bool
var element_is_evaluate_from_game : get = get_element_is_evaluate_from_game
func get_element_is_evaluate_from_game():
	return current_element.type == PushPopType.FUNCTION_EVALUATION_FROM_GAME

# (PushPopType, int, int) -> void
func push(type, external_evaluation_stack_height = 0, output_stream_length_with_pushed = 0):
	var element = Element.new(type, current_element.current_pointer, false)

	element.evaluation_stack_height_when_pushed = external_evaluation_stack_height
	element.function_start_in_ouput_stream = output_stream_length_with_pushed

	callstack.append(element)

# (PushPopType | null) -> void
func can_pop_type(type = null):
	if !can_pop:
		return false

	if type == null:
		return true

	return current_element.type == type

# (PushPopType | null) -> void
func pop(type = null):
	if can_pop_type(type):
		callstack.pop_back()
		return
	else:
		InkUtils.throw_exception("Mismatched push/pop in Callstack")

# (String, int) -> InkObject
func get_temporary_variable_with_name(name, context_index = -1) -> InkObject:
	if context_index == -1:
		context_index = current_element_index + 1

	var var_value = null

	var context_element = callstack[context_index - 1]

	if context_element.temporary_variables.has(name):
		var_value = context_element.temporary_variables[name]
		return var_value
	else:
		return null

# (String, InkObject, bool, int) -> void
func set_temporary_variable(name, value, declare_new, context_index = -1):
	if context_index == -1:
		context_index = current_element_index + 1

	var context_element = callstack[context_index - 1]

	if !declare_new && !context_element.temporary_variables.has(name):
		InkUtils.throw_exception("Could not find temporary variable to set: %s" % name)
		return

	if context_element.temporary_variables.has(name):
		var old_value = context_element.temporary_variables[name]
		InkListValue.retain_list_origins_for_assignment(old_value, value)

	context_element.temporary_variables[name] = value


# (String) -> int
func context_for_variable_named(name):
	if current_element.temporary_variables.has(name):
		return current_element_index + 1
	else:
		return 0

# (int) -> InkThread | null
func thread_with_index(index):
	for thread in _threads:
		if thread.thread_index == index:
			return thread

	return null

var callstack : get = get_callstack
func get_callstack():
	return current_thread.callstack

var callstack_trace : get = get_callstack_trace
func get_callstack_trace():
	var sb = ""
	var t = 0
	while t < _threads.size():
		var thread = _threads[t]
		var is_current = (t == _threads.size() - 1)
		sb += str("=== THREAD ", str(t + 1), "/", str(_threads.size()), " ",
				("(current) " if is_current else "" ), "===\n")

		var i = 0
		while i < thread.callstack.size():
			if thread.callstack[i].type == PushPopType.FUNCTION:
				sb += "  [FUNCTION] "
			else:
				sb += "  [TUNNEL] "

			var pointer = thread.callstack[i].current_pointer
			if !pointer.is_null:
				sb += "<SOMEWHERE IN "
				sb += pointer.container.path._to_string()
				sb += "\n>"

			i += 1
		t += 1

	return sb

var _threads = null # Array<InkThread>
var _thread_counter = 0 # int
var _start_of_root := InkPointer.new_null()

# C# Actions & Delegates ##################################################### #

#  (SimpleJson.Writer) -> void
func _anonymous_write_json(writer: InkSimpleJSON.Writer) -> void:
	writer.write_property_start("threads")
	writer.write_array_start()
	for thread in _threads:
		thread.write_json(writer)
	writer.write_array_end()
	writer.write_property_end()

	writer.write_property_start("threadCounter")
	writer.write(_thread_counter)
	writer.write_property_end()
