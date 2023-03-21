# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://test/integration/runtime/test_base.gd"

# ############################################################################ #

func test_knot_do_not_gather():
	var story = InkStory.new(load_file("knot_do_not_gather"))

	assert_eq(story.continue_story(), "g\n")

func test_knot_stitch_gather_counts():
	var story = InkStory.new(load_file("knot_stitch_gather_counts"))

	assert_eq(story.continue_maximally(), "1 1\n2 2\n3 3\n1 1\n2 1\n3 1\n1 2\n2 2\n3 2\n1 1\n2 1\n3 1\n1 2\n2 2\n3 2\n")

func test_knot_thread_interaction():
	var story = InkStory.new(load_file("knot_thread_interaction"))

	assert_eq(story.continue_maximally(), "blah blah\n")

	assert_eq(story.current_choices.size(), 2)
	assert_true(story.current_choices[0].text.find("option") != -1)
	assert_true(story.current_choices[1].text.find("wigwag") != -1)

	story.choose_choice_index(1)
	assert_eq(story.continue_story(), "wigwag\n")
	assert_eq(story.continue_story(), "THE END\n")
	assert_false(story.has_error)  # Removed in ink 1.0.0 but kept here for now.

func test_knot_thread_interaction_2():
	var story = InkStory.new(load_file("knot_thread_interaction_2"))

	assert_eq(story.continue_maximally(), "I’m in a tunnel\nWhen should this get printed?\n")
	assert_eq(story.current_choices.size(), 1)
	assert_eq(story.current_choices[0].text, "I’m an option")

	story.choose_choice_index(0)
	assert_eq(story.continue_maximally(), "I’m an option\nFinishing thread.\n")
	assert_false(story.has_error) # Removed in ink 1.0.0 but kept here for now.

# ############################################################################ #

func _prefix():
	return "runtime/knots/"
