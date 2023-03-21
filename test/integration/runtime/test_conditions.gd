# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://test/integration/runtime/test_base.gd"

# ############################################################################ #

func test_all_switch_branches_fail_is_clean():
	var story = InkStory.new(load_file("all_switch_branches_fail_is_clean"))
	story.continue_story()

	assert_eq(story.state.evaluation_stack.size(), 0)

func test_conditionals():
	var story = InkStory.new(load_file("conditionals"))
	assert_eq(story.continue_maximally(), "true\ntrue\ntrue\ntrue\ntrue\ngreat\nright?\n")

func test_else_branches():
	var story = InkStory.new(load_file("else_branches"))
	assert_eq(story.continue_maximally(), "other\nother\nother\nother\n")

func test_empty_multiline_conditional_branch():
	var story = InkStory.new(load_file("empty_multiline_conditional_branch"))
	assert_eq(story.continue_story(), "")

func test_trivial_condition():
	var story = InkStory.new(load_file("trivial_condition"))
	story.continue_story()

	assert_false(story.has_error)  # Removed in ink 1.0.0 but kept here for now.

# ############################################################################ #

func _prefix():
	return "runtime/conditions/"
