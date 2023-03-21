# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://test/integration/runtime/test_base.gd"

# ############################################################################ #

func test_floor_ceiling_and_casts():
	var story = InkStory.new(load_file("floor_ceiling_and_casts"))

	assert_eq(story.continue_maximally(), "1\n1\n2\n0.66666666666667\n0\n1\n")

func test_read_count_across_callstack():
	var story = InkStory.new(load_file("read_count_across_callstack"))

	assert_eq(story.continue_maximally(), "1) Seen first 1 times.\nIn second.\n2) Seen first 1 times.\n")

func test_read_count_across_threads():
	var story = InkStory.new(load_file("read_count_across_threads"))

	assert_eq(story.continue_maximally(), "1\n1\n")

func test_read_count_dot_separated_path():
	var story = InkStory.new(load_file("read_count_dot_separated_path"))

	assert_eq(story.continue_maximally(), "hi\nhi\nhi\n3\n")

func test_read_count_variable_target():
	var story = InkStory.new(load_file("read_count_variable_target"))

	assert_eq(story.continue_maximally(), "Count start: 0 0 0\n1\n2\n3\nCount end: 3 3 3\n")

func test_turns_since_nested():
	var story = InkStory.new(load_file("turns_since_nested"))

	assert_eq(story.continue_maximally(), "-1 = -1\n")

	assert_eq(story.current_choices.size(), 1)
	story.choose_choice_index(0)

	assert_eq(story.continue_maximally(), "stuff\n0 = 0\n")

	assert_eq(story.current_choices.size(), 1)
	story.choose_choice_index(0)

	assert_eq(story.continue_maximally(), "more stuff\n1 = 1\n")

func test_turns_since_with_variable_target():
	var story = InkStory.new(load_file("turns_since_with_variable_target"))

	assert_eq(story.continue_maximally(), "0\n0\n")

	story.choose_choice_index(0)
	assert_eq(story.continue_maximally(), "1\n")

func test_turns_since():
	var story = InkStory.new(load_file("turns_since"))

	assert_eq(story.continue_maximally(), "-1\n0\n")

	story.choose_choice_index(0)
	assert_eq(story.continue_maximally(), "1\n")

	story.choose_choice_index(0)
	assert_eq(story.continue_maximally(), "2\n")

func test_turns():
	var story = InkStory.new(load_file("turns"))

	var i = 0
	while i < 10:
		assert_eq(story.continue_story(), str(i, "\n"))
		story.choose_choice_index(0)

		i += 1

func test_visit_count_bug_due_to_nested_containers():
	var story = InkStory.new(load_file("visit_count_bug_due_to_nested_containers"))

	assert_eq(story.continue_story(), "1\n")

	story.choose_choice_index(0)
	assert_eq(story.continue_maximally(), "choice\n1\n")

func test_visit_counts_when_choosing():
	var story = InkStory.new(load_file("visit_counts_when_choosing"))

	assert_eq(story.state.visit_count_at_path_string("TestKnot"), 0)
	assert_eq(story.state.visit_count_at_path_string("TestKnot2"), 0)

	story.choose_path_string("TestKnot")

	assert_eq(story.state.visit_count_at_path_string("TestKnot"), 1)
	assert_eq(story.state.visit_count_at_path_string("TestKnot2"), 0)

	story.continue_story()

	assert_eq(story.state.visit_count_at_path_string("TestKnot"), 1)
	assert_eq(story.state.visit_count_at_path_string("TestKnot2"), 0)

	story.choose_choice_index(0)

	assert_eq(story.state.visit_count_at_path_string("TestKnot"), 1)
	assert_eq(story.state.visit_count_at_path_string("TestKnot2"), 0)

	story.continue_story()

	assert_eq(story.state.visit_count_at_path_string("TestKnot"), 1)
	assert_eq(story.state.visit_count_at_path_string("TestKnot2"), 1)

# ############################################################################ #

func _prefix():
	return "runtime/builtins/"
