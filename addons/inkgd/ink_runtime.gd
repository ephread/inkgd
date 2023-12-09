# warning-ignore-all:unused_class_variable
# warning-ignore-all:shadowed_variable
# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2023 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends Node

# Hiding this type to prevent registration of "private" nodes.
# See https://github.com/godotengine/godot-proposals/issues/1047
# class_name InkRuntimeNode

# Expected to be added to the SceneTree as a singleton object.

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
var stop_execution_on_exception: bool = true

## Uses `assert` instead of `push_error` to report story errors, thus
## making them more explicit during development.
var stop_execution_on_error: bool = true


# ############################################################################ #
# Deprecated Properties
# ############################################################################ #

# Skips saving global values that remain equal to the initial values that were
# declared in Ink.
var dont_save_default_values: bool:
	get:
		printerr(
				"'dont_save_default_values' is deprecated, " +
				"use 'InkVariablesState.dont_save_default_values' instead."
		)
		return InkVariablesState.dont_save_default_values
	set(value):
		InkVariablesState.dont_save_default_values = value


var should_pause_execution_on_runtime_error: bool: get = get_speore, set = set_speore
func get_speore() -> bool:
	printerr(
			"'should_pause_execution_on_runtime_error' is deprecated, " +
			"use 'stop_execution_on_exception' instead."
	)
	return stop_execution_on_exception
func set_speore(value: bool):
	printerr(
			"'should_pause_execution_on_runtime_error' is deprecated, " +
			"use 'stop_execution_on_exception' instead."
	)
	stop_execution_on_exception = value


var should_pause_execution_on_story_error: bool: get = get_speose, set = set_speose
func get_speose() -> bool:
	printerr(
			"'should_pause_execution_on_story_error' is deprecated, " +
			"use 'stop_execution_on_error' instead."
	)
	return stop_execution_on_error
func set_speose(value: bool):
	printerr(
			"'should_pause_execution_on_story_error' is deprecated, " +
			"use 'stop_execution_on_error' instead."
	)
	stop_execution_on_error = value


# ############################################################################ #
# Internal Properties
# ############################################################################ #

# Recorded exceptions don't emit the 'exception' signal, since they are
# expected to be processed by the story and emitted through 'on_error'.
var record_story_exceptions: bool = false
var current_story_exceptions: Array = []

var catch_exceptions = true

var has_raised_exceptions: bool:
	get:
		return (_story_exception_raised || _argument_exception_raised || _exception_raised)

var has_raised_uncaught_exceptions: bool:
	get:
		return !catch_exceptions && has_raised_exceptions

# ############################################################################ #
# Private Properties
# ############################################################################ #

var _story_exception_raised: bool = false
var _argument_exception_raised: bool = false
var _exception_raised: bool = false


# ############################################################################ #
# Overrides
# ############################################################################ #

func _init():
	name = "__InkRuntime"


# ############################################################################ #
# Internal Methods
# ############################################################################ #

func clear_raised_exceptions():
	current_story_exceptions = []

	_story_exception_raised = false
	_argument_exception_raised = false
	_exception_raised = false


func handle_exception(message: String) -> void:
	var exception_message = "EXCEPTION: %s" % message
	var stack_trace = _get_stack_trace()

	_handle_generic_exception(
			exception_message,
			stop_execution_on_exception,
			stack_trace
	)

	_exception_raised = true
	emit_signal("exception_raised", exception_message, stack_trace)


func handle_argument_exception(message: String) -> void:
	var exception_message = "ARGUMENT EXCEPTION: %s" % message
	var stack_trace = _get_stack_trace()

	_handle_generic_exception(
			exception_message,
			stop_execution_on_error,
			stack_trace
	)

	_argument_exception_raised = true
	emit_signal("exception_raised", exception_message, stack_trace)


func handle_story_exception(message: String, use_end_line_number: bool, metadata) -> void:
	# When exceptions are "recorded", they are not reported immediately.
	# 'Story' will take care of that at the end of the step.
	if record_story_exceptions:
		current_story_exceptions.append(StoryError.new(message, use_end_line_number, metadata))
	else:
		var exception_message = "STORY EXCEPTION: %s" % message
		var stack_trace = _get_stack_trace()

		_handle_generic_exception(exception_message, stop_execution_on_error, stack_trace)

		_story_exception_raised = true
		emit_signal("exception_raised", exception_message, stack_trace)


# ############################################################################ #
# Private Methods
# ############################################################################ #

func _handle_generic_exception(
		message: String,
		should_pause_execution: bool,
		stack_trace: PackedStringArray
) -> void:
	if OS.is_debug_build():
		if should_pause_execution:
			assert(false, message)
		elif Engine.is_editor_hint():
			printerr(message)
			if stack_trace.size() > 0:
				printerr("Stack trace:")
				for line in stack_trace:
					printerr(line)
		else:
			push_error(message)


func _get_stack_trace() -> PackedStringArray:
	var trace := PackedStringArray()

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
