# ############################################################################ #
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://test/integration/test_base.gd"

# ############################################################################ #

func test_newline_at_start_of_multiline_conditional():
	var story = Story.new(load_file("newline_at_start_of_multiline_conditional"))

	assert_eq(story.continue_maximally(), "X\nx\n")

func test_newline_consistency():
	var story = Story.new(load_file("newline_consistency_1"))
	assert_eq(story.continue_maximally(), "hello world\n")

	story = Story.new(load_file("newline_consistency_2"))
	story.continue()
	story.choose_choice_index(0)
	assert_eq(story.continue_maximally(), "hello world\n")

	story = Story.new(load_file("newline_consistency_3"))
	story.continue()
	story.choose_choice_index(0)
	assert_eq(story.continue_maximally(), "hello\nworld\n")

func test_newlines_trimming_with_func_external_fallback():
	var story = Story.new(load_file("newlines_trimming_with_func_external_fallback"))
	story.allow_external_function_fallbacks = true

	assert_eq(story.continue_maximally(), "Phrase 1\nPhrase 2\n")

func test_newlines_with_string_eval():
	var story = Story.new(load_file("newlines_with_string_eval"))

	assert_eq(story.continue_maximally(), "A\nB\nA\n3\nB\n")

# ############################################################################ #

func _prefix():
	return "newlines/"
