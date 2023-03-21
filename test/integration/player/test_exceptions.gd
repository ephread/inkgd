# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://test/integration/player/test_base.gd"

# These tests serve little purpose in classic Godot but are critical in
# Godot Mono to ensure Ink Lists and Paths are properly converted back and
# forth between GDScript and C#.

var _error_messages_encountered := []

# ############################################################################ #
# Overrides
# ############################################################################ #

func before_each():
	super.before_each()
	_ink_player.error_encountered.connect(_error_encountered)


func after_each():
	_error_messages_encountered = []
	_ink_player.error_encountered.disconnect(_error_encountered)
	super.after_each()

# ############################################################################ #
# Methods
# ############################################################################ #

func test_that_exception_is_received() -> void:
	await _load_story("flow")
	_ink_player.stop_execution_on_exception = false
	_ink_player.remove_flow("DEFAULT_FLOW")

	assert_gt(_exception_messages_raised.size(), 0)
	assert_eq(_exception_messages_raised[0], "EXCEPTION: Cannot destroy default flow")


func test_that_argument_exception_is_received() -> void:
	await _load_story("functions")
	_ink_player.stop_execution_on_exception = false
	_ink_player.allow_external_function_fallbacks = true
	_ink_player.evaluate_function("the_function", [Vector2(3, 6)])

	assert_gt(_exception_messages_raised.size(), 0)
	assert_true(_exception_messages_raised[0].find("ARGUMENT EXCEPTION: ink arguments when calling EvaluateFunction / ChoosePathStringWithParameters must be") != -1)


func test_that_story_exception_is_received() -> void:
	await _load_story("ink_error")
	_ink_player.stop_execution_on_error = false
	_ink_player.continue_story_maximally()

	assert_gt(_error_messages_encountered.size(), 0)
	assert_eq(_error_messages_encountered[0], "RUNTIME ERROR: (0, 2): Expected list for LIST_RANDOM")


func test_that_external_story_exception_is_received() -> void:
	await _load_story("flow")
	_ink_player.stop_execution_on_error = false
	_ink_player.set_variable("non_existing_variable", 3)

	assert_gt(_exception_messages_raised.size(), 0)
	assert_eq(_exception_messages_raised[0], "STORY EXCEPTION: Cannot assign to a variable (non_existing_variable) that hasn't been declared in the story")


# ############################################################################ #
# Private Methods
# ############################################################################ #

func _error_encountered(message: String, type: int):
	_error_messages_encountered.append(message)
