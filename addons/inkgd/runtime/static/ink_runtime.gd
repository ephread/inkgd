# warning-ignore-all:unused_class_variable
# warning-ignore-all:shadowed_variable
# ############################################################################ #
# Copyright © 2015-present inkle Ltd.
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

tool
extends Node

class_name InkRuntimeNode

# Expected to be added to the SceneTree as a singleton object.

# ############################################################################ #
# Imports
# ############################################################################ #

var StaticJson = load("res://addons/inkgd/runtime/static/json.gd")
var StaticNativeFunctionCall = load("res://addons/inkgd/runtime/static/native_function_call.gd")

# ############################################################################ #
# Signals
# ############################################################################ #

## Emitted when the runtime encountered an exception. Exception are not
## recoverable and may corrupt the state. They are the consequence of either
## a programmer error or a bug in the runtime.
signal exception_raised(message, stack_trace)

# ############################################################################ #
# Properties
# ############################################################################ #

## Uses `assert` instead of `push_error` to report critical errors, thus
## making them more explicit during development.
var should_pause_execution_on_exception: bool = true

## Uses `assert` instead of `push_error` to report story errors, thus
## making them more explicit during development.
var should_pause_execution_on_error: bool = true

# ############################################################################ #

var should_pause_execution_on_runtime_error setget set_speore, get_speore
func get_speore():
	printerr("'should_pause_execution_on_runtime_error' is deprecated, use 'should_pause_execution_on_exception' instead.")
	return should_pause_execution_on_exception
func set_speore(value):
	printerr("'should_pause_execution_on_runtime_error' is deprecated, use 'should_pause_execution_on_exception' instead.")
	should_pause_execution_on_exception = value

var should_pause_execution_on_story_error setget set_speose, get_speose
func get_speose():
	printerr("'should_pause_execution_on_story_error' is deprecated, use 'should_pause_execution_on_error' instead.")
	return should_pause_execution_on_error
func set_speose(value):
	printerr("'should_pause_execution_on_story_error' is deprecated, use 'should_pause_execution_on_error' instead.")
	should_pause_execution_on_error = value

# ############################################################################ #
# Original Static Properties
# ############################################################################ #

# skips saving global values that remain equal to the initial values that were
# declared in Ink.
var dont_save_default_values: bool = true

var native_function_call = StaticNativeFunctionCall.new()
var json = StaticJson.new(native_function_call)

# ############################################################################ #
# Internal Properties
# ############################################################################ #

# Recorded exceptions don't emit the 'exception' signal, since they are
# expected to be processed by the story and emitted through 'on_error'.
var record_story_exceptions: bool = false
var current_story_exceptions: Array = []

# ############################################################################ #
# Overrides
# ############################################################################ #

func _init():
	name = "__InkRuntime"

# ############################################################################ #
# Internal Methods
# ############################################################################ #

func handle_exception(message: String) -> void:
	var exception_message = "EXCEPTION: %s" % message
	var stack_trace = _get_stack_trace()

	_handle_generic_exception(
			exception_message,
			should_pause_execution_on_exception,
			stack_trace
	)

	emit_signal("exception_raised", exception_message)

func handle_argument_exception(message: String) -> void:
	var exception_message = "ARGUMENT EXCEPTION: %s" % message
	var stack_trace = _get_stack_trace()

	_handle_generic_exception(
			exception_message,
			should_pause_execution_on_exception,
			stack_trace
	)

	emit_signal("exception_raised", exception_message, stack_trace)

func handle_story_exception(message: String, use_end_line_number: bool) -> void:
	if record_story_exceptions:
		current_story_exceptions.append(StoryError.new(message, use_end_line_number))

	var exception_message = "STORY EXCEPTION: %s" % message
	var stack_trace = _get_stack_trace()

	_handle_generic_exception(exception_message, should_pause_execution_on_error, stack_trace)

	if !record_story_exceptions:
		emit_signal("exception_raised", exception_message, stack_trace)

# ############################################################################ #
# Private Methods
# ############################################################################ #

func _handle_generic_exception(
		message: String,
		should_pause_execution: bool,
		stack_trace: PoolStringArray
) -> void:
	if OS.is_debug_build():
		if stack_trace.size() > 0:
			printerr(message)
			printerr("Stack trace:")
			for line in stack_trace:
				printerr(line)

		if should_pause_execution:
			assert(false, message)
		elif Engine.editor_hint:
			printerr(message)
		else:
			push_error(message)

func _get_stack_trace() -> PoolStringArray:
	var trace := PoolStringArray()

	var i = 1
	for stack_element in get_stack():
		if i <= 3:
			i += 1
			continue

		trace.append(str(
				"    ", (i - 3), " - ", stack_element["source"], ":",
				stack_element["line"], " - at function: ", stack_element["function"]
		))

		i += 1

	return trace

# ############################################################################ #
# Internal Class
# ############################################################################ #

class StoryError:
	var message: String
	var use_end_line_number: bool

	func _init(message: String, use_end_line_number: bool):
		self.message = message
		self.use_end_line_number = use_end_line_number
