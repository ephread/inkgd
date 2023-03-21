# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://test/integration/runtime/test_base.gd"

# ############################################################################ #

func test_conditional_choice_in_weave():
	var story = InkStory.new(load_file("conditional_choice_in_weave"))

	assert_eq(story.continue_maximally(), "start\ngather should be seen\n")
	assert_eq(story.current_choices.size(), 1)
	assert_eq(story.current_choices[0].text, "go to a stitch")

	story.choose_choice_index(0)

	assert_eq(story.continue_maximally(), "result\n")

func test_conditional_choice_in_weave_2():
	var story = InkStory.new(load_file("conditional_choice_in_weave_2"))

	assert_eq(story.continue_story(), "first gather\n")
	assert_eq(story.current_choices.size(), 2)

	story.choose_choice_index(0)

	assert_eq(story.continue_maximally(), "the main gather\nbottom gather\n")
	assert_eq(story.current_choices.size(), 0)

func test_unbalanced_weave_indentation():
	var story = InkStory.new(load_file("unbalanced_weave_indentation"))

	story.continue_maximally()

	assert_eq(story.current_choices.size(), 1)
	assert_eq(story.current_choices[0].text, "First")

	story.choose_choice_index(0)
	assert_eq(story.continue_maximally(), "First\n")
	assert_eq(story.current_choices.size(), 1)
	assert_eq(story.current_choices[0].text, "Very indented")

	story.choose_choice_index(0)
	assert_eq(story.continue_maximally(), "Very indented\nEnd\n")
	assert_eq(story.current_choices.size(), 0)

func test_weave_gathers():
	var story = InkStory.new(load_file("weave_gathers"))

	story.continue_maximally()

	assert_eq(story.current_choices.size(), 2)
	assert_eq(story.current_choices[0].text, "one")
	assert_eq(story.current_choices[1].text, "four")

	story.choose_choice_index(0)
	story.continue_maximally()

	assert_eq(story.current_choices.size(), 1)
	assert_eq(story.current_choices[0].text, "two")

	story.choose_choice_index(0)
	assert_eq(story.continue_maximally(), "two\nthree\nsix\n")

func test_weave_options():
	var story = InkStory.new(load_file("weave_options"))

	story.continue_maximally()

	assert_eq(story.current_choices[0].text, "Hello.")

	story.choose_choice_index(0)
	assert_eq(story.continue_story(), "Hello, world.\n")

func test_weave_within_sequence():
	var story = InkStory.new(load_file("weave_within_sequence"))

	story.continue_story()

	assert_eq(story.current_choices.size(), 1)

	story.choose_choice_index(0)

	assert_eq(story.continue_maximally(), "choice\nnextline\n")

# ############################################################################ #

func _prefix():
	return "runtime/weaves/"
