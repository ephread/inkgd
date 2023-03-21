# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://test/integration/player/test_base.gd"


# ############################################################################ #
# Overrides
# ############################################################################ #

func after_each():
	_ink_player.allow_external_function_fallbacks = true
	super.after_each()

# ############################################################################ #
# Methods
# ############################################################################ #

func test_has_function() -> void:
	await _load_story("functions")
	_ink_player.allow_external_function_fallbacks = true

	assert_true(_ink_player.has_function("external_function"))
	assert_false(_ink_player.has_function("__function"))

	assert_eq(_exception_messages_raised.size(), 0)


func test_evaluate_function() -> void:
	await _load_story("functions")
	_ink_player.allow_external_function_fallbacks = true

	var result: InkFunctionResult = _ink_player.evaluate_function("the_function", [4])

	assert_eq(result.return_value, 8)
	assert_eq(result.text_output, "Hello World!\n")

	assert_eq(_exception_messages_raised.size(), 0)


func test_evaluate_missing_function() -> void:
	await _load_story("functions")
	_ink_player.allow_external_function_fallbacks = true

	_ink_player.evaluate_function("__function", [40])

	# TODO: bind "on_error" instead.
	assert_eq(_exception_messages_raised.size(), 1)

func test_evaluate_missing_arguments() -> void:
	await _load_story("functions")
	_ink_player.allow_external_function_fallbacks = true

	_ink_player.evaluate_function("the_function", [])

	# TODO: bind "on_error" instead.
	assert_eq(_exception_messages_raised.size(), 1)


func test_function_fallback() -> void:
	await _load_story("functions")
	_ink_player.allow_external_function_fallbacks = true

	assert_eq(_ink_player.continue_story_maximally(), "The count is 7\n")

	assert_eq(_exception_messages_raised.size(), 0)


func test_function_no_fallback() -> void:
	await _load_story("functions")
	_ink_player.continue_story_maximally()

	assert_eq(_exception_messages_raised.size(), 1)


func test_function_binding() -> void:
	await _load_story("functions")
	_ink_player.bind_external_function("external_function", self, "_external_function")

	assert_eq(_ink_player.continue_story_maximally(), "The count is 14\n")

	_ink_player.allow_external_function_fallbacks = true
	_ink_player.unbind_external_function("external_function")

	_ink_player.choose_path("start")
	assert_eq(_ink_player.continue_story_maximally(), "The count is 7\n")

	assert_eq(_exception_messages_raised.size(), 0)


# ############################################################################ #
# Private Methods
# ############################################################################ #

func _external_function(count: int) -> int:
	return count + 10
