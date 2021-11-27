# ############################################################################ #
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://test/integration/test_base.gd"

# ############################################################################ #

func test_string_constants():
	var story = Story.new(load_file("string_constants"))

	assert_eq(story.continue(), "hi\n")

func test_string_contains():
	var story = Story.new(load_file("string_contains"))

	assert_eq(story.continue_maximally(), "true\nfalse\ntrue\ntrue\n")

func test_string_type_coercion():
	var story = Story.new(load_file("string_type_coercion"))

	assert_eq(story.continue_maximally(), "same\ndifferent\n")

func test_string_in_choices():
	var story = Story.new(load_file("strings_in_choices"))

	story.continue_maximally()

	assert_eq(story.current_choices.size(), 1)
	assert_eq(story.current_choices[0].text, "test1 \"test2 test3\"")

	story.choose_choice_index(0)
	assert_eq(story.continue(), "test1 test4\n")

# ############################################################################ #

func _prefix():
	return "strings/"
