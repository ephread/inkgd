# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://test/integration/runtime/test_base.gd"

# ############################################################################ #

func test_multi_thread():
	var story = InkStory.new(load_file("multi_thread"))

	assert_eq(story.continue_maximally(), "This is place 1.\nThis is place 2.\n")
	story.choose_choice_index(0)
	assert_eq(story.continue_maximally(), "choice in place 1\nThe end\n")
	assert_false(story.has_error) # Removed in ink 1.0.0 but kept here for now.

func test_thread_done():
	var story = InkStory.new(load_file("thread_done"))

	assert_eq(story.continue_maximally(), "This is a thread example\nHello.\nThe example is now complete.\n")

func test_thread_in_logic():
	var story = InkStory.new(load_file("thread_in_logic"))

	assert_eq(story.continue_story(), "Content\n")

func test_top_flow_terminator_should_not_kill_thread_choices():
	var story = InkStory.new(load_file("top_flow_terminator_should_not_kill_thread_choices"))

	assert_eq(story.continue_story(), "Limes\n")
	assert_eq(story.current_choices.size(), 1)

# ############################################################################ #

func _prefix():
	return "runtime/threads/"
