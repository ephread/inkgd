# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://test/integration/runtime/test_base.gd"

# ############################################################################ #

func test_blanks_in_inline_sequences():
	var story = InkStory.new(load_file("blanks_in_inline_sequences"))
	assert_eq(story.continue_maximally(), "1. a\n2.\n3. b\n4. b\n---\n1.\n2. a\n3. a\n---\n1. a\n2.\n3.\n---\n1.\n2.\n3.\n")

func test_empty_sequence_content():
	var story = InkStory.new(load_file("empty_sequence_content"))

	assert_eq(story.continue_maximally(), "Wait for it....\nSurprise!\nDone.\n")

func test_gather_read_count_with_initial_sequence():
	var story = InkStory.new(load_file("gather_read_count_with_initial_sequence"))

	assert_eq(story.continue_story(), "seen test\n")

func test_leading_newline_multiline_sequence():
	var story = InkStory.new(load_file("leading_newline_multiline_sequence"))

	assert_eq(story.continue_story(), "a line after an empty line\n")

func test_shuffle_stack_muddying():
	var story = InkStory.new(load_file("shuffle_stack_muddying"))

	story.continue_story()

	assert_eq(story.current_choices.size(), 2)

func test_all_sequence_types():

	var story = InkStory.new(load_file("all_sequence_types"))

	var expected_story

	# The random number generator seems to behave differently between 3.1 and 3.2.
	if is_godot_3_1():
		expected_story = "Once: one two\nStopping: one two two two\nDefault: one two two two\nCycle: one two one two\nShuffle: one two two one\nShuffle stopping: one two final final\nShuffle once: one two\n"
	else:
		expected_story = "Once: one two\nStopping: one two two two\nDefault: one two two two\nCycle: one two one two\nShuffle: two one one two\nShuffle stopping: two one final final\nShuffle once: two one\n"

	assert_eq(story.continue_maximally(), expected_story)

# ############################################################################ #

func is_godot_3_1():
	var engine_version = Engine.get_version_info()
	return engine_version["major"] == 3 && engine_version["minor"] == 1

func _prefix():
	return "runtime/sequences/"
