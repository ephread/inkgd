# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://test/integration/runtime/test_base.gd"

# ############################################################################ #

func test_arithmetic():
	var story = InkStory.new(load_file("arithmetic"))
	assert_eq(story.continue_maximally(), "36\n2\n3\n2\n2.33333333333333\n8\n8\n")

func test_basic_string_literals():
	var story = InkStory.new(load_file("basic_string_literals"))
	assert_eq(story.continue_maximally(), "Hello world 1\nHello world 2.\n")

func test_evaluating_function_variable_state_bug():
	var story = InkStory.new(load_file("evaluating_function_variable_state_bug"))

	assert_eq(story.continue_story(), "Start\n")
	assert_eq(story.continue_story(), "In tunnel.\n")

	var func_result = story.evaluate_function("function_to_evaluate")
	assert_eq(func_result, "RIGHT")

	assert_eq(story.continue_story(), "End\n")

func test_evaluating_ink_functions_from_game():
	var story = InkStory.new(load_file("evaluating_ink_functions_from_game"))

	story.continue_story()

	var returned_divert_target = story.evaluate_function("test")

	assert_eq("somewhere.here", returned_divert_target)

func test_evaluating_ink_functions_from_game_2():
	var story = InkStory.new(load_file("evaluating_ink_functions_from_game_2"))

	var text_output = null
	var func_result = story.evaluate_function("func1", null, true)

	assert_eq(func_result["output"], "This is a function\n")
	assert_eq(func_result["result"], 5)

	assert_eq(story.continue_story(), "One\n")

	func_result = story.evaluate_function("func2", null, true)
	assert_eq(func_result["output"], "This is a function without a return value\n")
	assert_eq(func_result["result"], null)

	assert_eq(story.continue_story(), "Two\n")

	func_result = story.evaluate_function("add", [1, 2], true)
	assert_eq(func_result["output"], "x = 1, y = 2\n")
	assert_eq(func_result["result"], 3)

	assert_eq(story.continue_story(), "Three\n")

func test_evaluation_stack_leaks():
	var story = InkStory.new(load_file("evaluation_stack_leaks"))

	assert_eq(story.continue_maximally(), "else\nelse\nhi\n")
	assert_eq(0, story.state.evaluation_stack.size())

func test_factorial_by_reference():
	var story = InkStory.new(load_file("factorial_by_reference"))

	assert_eq(story.continue_maximally(), "120\n")

func test_factorial_recursive():
	var story = InkStory.new(load_file("factorial_recursive"))

	assert_eq(story.continue_maximally(), "120\n")

func test_increment():
	var story = InkStory.new(load_file("increment"))

	assert_eq(story.continue_maximally(), "6\n5\n")

func test_literal_unary():
	var story = InkStory.new(load_file("literal_unary"))

	assert_eq(story.continue_maximally(), "-1\nfalse\ntrue\n")

# ############################################################################ #

func _prefix():
	return "runtime/evaluation/"
