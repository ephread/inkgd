# warning-ignore-all:unused_class_variable
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

# Expected to be added to the SceneTree as a singleton object.

# ############################################################################ #
# Imports
# ############################################################################ #

var StaticJson = load("res://addons/inkgd/runtime/static/json.gd")
var StaticNativeFunctionCall = load("res://addons/inkgd/runtime/static/native_function_call.gd")

# ############################################################################ #
# Signals
# ############################################################################ #

signal exception(message)

# ############################################################################ #

var native_function_call = StaticNativeFunctionCall.new()
var json = StaticJson.new(native_function_call)

# ############################################################################ #

# An internal property tracking whether the story should stop.
# It replaces the exception mechanism found in the original C# implemntation.
var should_interrupt = false

# Uses `assert` instead of `push_error` to report critical errors, thus
# making them more explicit.
var should_pause_execution_on_runtime_error = true

# Uses `assert` instead of `push_error` to report story errors, thus
# making them more explicit.
var should_pause_execution_on_story_error = true

# ############################################################################ #
# Original Static Properties
# ############################################################################ #

var dont_save_default_values = true

func _init():
	name = "__InkRuntime"

func handle_exception(message):
	handle_generic_exception("EXCEPTION: %s" % message)

func handle_story_exception(message):
	handle_generic_exception("STORY EXCEPTION: %s" % message)

func handle_argument_exception(message):
	handle_generic_exception("ARGUMENT EXCEPTION: %s" % message)

func handle_generic_exception(message):
	should_interrupt = true

	if should_pause_execution_on_runtime_error && OS.is_debug_build():
		assert(false, message)
	else:
		push_error(message)
		printerr(message)

	emit_signal("exception", message)
