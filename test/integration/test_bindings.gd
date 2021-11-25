# ############################################################################ #
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://test/integration/test_base.gd"

# ############################################################################ #

func test_external_binding():
	var story = Story.new(load_file("external_binding"))

	story.bind_external_function("message", self, "_external_binding_message")
	story.bind_external_function("multiply", self, "_external_binding_multiply")
	story.bind_external_function("times", self, "_external_binding_times")

	assert_eq(story.continue(), "15\n")

	assert_eq(story.continue(), "knock knock knock\n")

	assert_eq(_test_external_binding_message, "MESSAGE: hello world")

func test_game_ink_back_and_forth():
	_game_ink_back_and_forth_story = Story.new(load_file("game_ink_back_and_forth"))

	_game_ink_back_and_forth_story.bind_external_function("gameInc", self, "_game_ink_back_and_forth_game_inc")
	var final_result = _game_ink_back_and_forth_story.evaluate_function("topExternal", [5], true)

	assert_eq(final_result.result, 7)
	assert_eq(final_result.output, "In top external\n")

func test_variable_observer():
	var story = Story.new(load_file("variable_observer"))

	self._test_variable_observer_current_var_value = 0
	self._test_variable_observer_observer_call_count = 0

	story.observe_variable("testVar", self, "_variable_observer_test")
	story.continue_maximally()

	assert_eq(self._test_variable_observer_current_var_value, 15)
	assert_eq(self._test_variable_observer_observer_call_count, 1)
	assert_eq(story.current_choices.size(), 1)

	story.choose_choice_index(0)
	story.continue()

	assert_eq(self._test_variable_observer_current_var_value, 25)
	assert_eq(self._test_variable_observer_observer_call_count, 2)

# ############################################################################ #

var _game_ink_back_and_forth_story = null

func _game_ink_back_and_forth_game_inc(x):
	x += 1
	x = _game_ink_back_and_forth_story.evaluate_function ("inkInc", [x])
	return x

# ############################################################################ #

var _test_variable_observer_current_var_value = 0
var _test_variable_observer_observer_call_count = 0

func _variable_observer_test(var_name, new_value):
	self._test_variable_observer_current_var_value = new_value
	self._test_variable_observer_observer_call_count += 1

# ############################################################################ #

var _test_external_binding_message = null

func _external_binding_message(arg):
	_test_external_binding_message = "MESSAGE: " + arg

func _external_binding_multiply(arg1, arg2):
	return arg1 * arg2

func _external_binding_times(number_of_times, string_value):
	var result = ""

	var i = 0
	while (i < number_of_times):
		result += string_value
		i += 1

	return result

# ############################################################################ #

func _prefix():
	return "bindings/"
