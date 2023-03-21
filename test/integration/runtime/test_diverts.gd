# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://test/integration/runtime/test_base.gd"

# ############################################################################ #

func test_basic_tunnel():
	var story = InkStory.new(load_file("basic_tunnel"))

	assert_eq(story.continue_story(), "Hello world\n")

func test_compare_divert_targets():
	var story = InkStory.new(load_file("compare_divert_targets"))

	assert_eq(story.continue_maximally(), "different knot\nsame knot\nsame knot\ndifferent knot\nsame knot\nsame knot\n")

func test_complex_tunnels():
	var story = InkStory.new(load_file("complex_tunnels"))

	assert_eq(story.continue_maximally(), "one (1)\none and a half (1.5)\ntwo (2)\nthree (3)\n")

func test_divert_in_conditional():
	var story = InkStory.new(load_file("divert_in_conditional"))

	assert_eq(story.continue_maximally(), "")

func test_divert_targets_with_parameters():
	var story = InkStory.new(load_file("divert_targets_with_parameters"))

	assert_eq(story.continue_maximally(), "5\n")

func test_divert_to_weave_points():
	var story = InkStory.new(load_file("divert_to_weave_points"))

	assert_eq(story.continue_maximally(), "gather\ntest\nchoice content\ngather\nsecond time round\n")

func test_done_stops_thread():
	var story = InkStory.new(load_file("done_stops_thread"))

	assert_eq(story.continue_maximally(), "")

func test_path_to_self():
	var story = InkStory.new(load_file("path_to_self"))

	story.continue_story()
	story.choose_choice_index(0)

	story.continue_story()
	story.choose_choice_index(0)

	assert_true(story.can_continue)

func test_same_line_divert_is_inline():
	var story = InkStory.new(load_file("same_line_divert_is_inline"))

	assert_eq(story.continue_story(), "We hurried home to Savile Row as fast as we could.\n")

func test_tunnel_onwards_after_tunnel():
	var story = InkStory.new(load_file("tunnel_onwards_after_tunnel"))

	assert_eq(story.continue_maximally(), "Hello...\n...world.\nThe End.\n")

func test_tunnel_onwards_divert_after_with_arg():
	var story = InkStory.new(load_file("tunnel_onwards_divert_after_with_arg"))

	assert_eq(story.continue_maximally(), "8\n")

func test_tunnel_onwards_divert_override():
	var story = InkStory.new(load_file("tunnel_onwards_divert_override"))

	assert_eq(story.continue_maximally(), "This is A\nNow in B.\n")

func test_tunnel_onwards_with_param_default_choice():
	var story = InkStory.new(load_file("tunnel_onwards_with_param_default_choice"))

	assert_eq(story.continue_maximally(), "8\n")

func test_tunnel_vs_thread_behaviour():
	var story = InkStory.new(load_file("tunnel_vs_thread_behaviour"))

	assert_false(story.continue_maximally().find("Finished tunnel") != -1)
	assert_eq(story.current_choices.size(), 2)

	story.choose_choice_index(0)

	assert_true(story.continue_maximally().find("Finished tunnel") != -1)
	assert_eq(story.current_choices.size(), 3)

	story.choose_choice_index(2)

	assert_true(story.continue_maximally().find("Done.") != -1)

# ############################################################################ #

func _prefix():
	return "runtime/diverts/"
