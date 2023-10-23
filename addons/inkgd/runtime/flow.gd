# warning-ignore-all:shadowed_variable
# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends InkBase

class_name InkFlow

# ############################################################################ #
# Imports
# ############################################################################ #

var CallStack = load("res://addons/inkgd/runtime/callstack.gd")

# ############################################################################ #
# Self-reference
# ############################################################################ #

static func Flow():
	return load("res://addons/inkgd/runtime/flow.gd")

# ############################################################################ #

var name # string
var callstack # CallStack
var output_stream # Array<InkObject>
var current_choices # Array<Choice>

func _init(static_json = null):
	get_static_json(static_json)

# (String, Story) -> Flow
func _init_with_name(name, story):
	self.name = name
	self.callstack = CallStack.new(story, self.StaticJSON)
	self.output_stream = []
	self.current_choices = []

# (String, Story, Dictionary<String, Variant>) -> Flow
func _init_with_name_and_jobject(name, story, jobject):
	self.name = name
	self.callstack = CallStack.new(story, self.StaticJSON)
	self.callstack.set_json_token(jobject["callstack"], story)
	self.output_stream = self.StaticJSON.jarray_to_runtime_obj_list(jobject["outputStream"])
	self.current_choices = self.StaticJSON.jarray_to_runtime_obj_list(jobject["currentChoices"])

	# jchoice_threads_obj is null if 'choiceThreads' doesn't exist.
	var jchoice_threads_obj = jobject.get("choiceThreads");
	self.load_flow_choice_threads(jchoice_threads_obj, story)

# (SimpleJson.Writer) -> void
func write_json(writer):
	writer.write_object_start()
	writer.write_property("callstack", Callable(self.callstack, "write_json"))
	writer.write_property(
		"outputStream",
		Callable(self, "_anonymous_write_property_output_stream")
	)

	var has_choice_threads = false
	for c in self.current_choices:
		c.original_thread_index = c.thread_at_generation.thread_index

		if self.callstack.thread_with_index(c.original_thread_index) == null:
			if !has_choice_threads:
				has_choice_threads = true
				writer.write_property_start("choiceThreads")
				writer.write_object_start()

			writer.write_property_start(c.original_thread_index)
			c.thread_at_generation.write_json(writer)
			writer.write_property_end()

	if has_choice_threads:
		writer.write_object_end()
		writer.write_property_end()

	writer.write_property(
		"currentChoices",
		Callable(self, "_anonymous_write_property_current_choices")
	)

	writer.write_object_end()

# (Dictionary, Story) -> void
func load_flow_choice_threads(jchoice_threads, story):
	for choice in self.current_choices:
		var found_active_thread = self.callstack.thread_with_index(choice.original_thread_index)
		if found_active_thread != null:
			choice.thread_at_generation = found_active_thread.copy()
		else:
			var jsaved_choice_thread = jchoice_threads[str(choice.original_thread_index)]
			choice.thread_at_generation = CallStack.InkThread.new_with(jsaved_choice_thread, story)

# (SimpleJson.Writer) -> void
func _anonymous_write_property_output_stream(w):
	self.StaticJSON.write_list_runtime_objs(w, self.output_stream)

# (SimpleJson.Writer) -> void
func _anonymous_write_property_current_choices(w):
	w.write_array_start()
	for c in self.current_choices:
		self.StaticJSON.write_choice(w, c)
	w.write_array_end()

func equals(ink_base) -> bool:
	return false

func _to_string() -> String:
	return str(self)

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_ink_class(type):
	return type == "Flow" || super.is_ink_class(type)

func get_ink_class():
	return "Flow"

static func new_with_name(name, story, static_json = null):
	var flow = Flow().new(static_json)
	flow._init_with_name(name, story)
	return flow

static func new_with_name_and_jobject(name, story, jobject, static_json = null):
	var flow = Flow().new(static_json)
	flow._init_with_name_and_jobject(name, story, jobject)
	return flow

# ############################################################################ #
var StaticJSON: InkStaticJSON:
	get: return _static_json.get_ref()

var _static_json = WeakRef.new()

func get_static_json(static_json = null):
	if static_json != null:
		_static_json = weakref(static_json)
		return

	var InkRuntime = Engine.get_main_loop().root.get_node("__InkRuntime")

	InkUtils.__assert__(InkRuntime != null,
				 str("[InkFlow] Could not retrieve 'InkRuntime' singleton from the scene tree."))

	_static_json = weakref(InkRuntime.json)
