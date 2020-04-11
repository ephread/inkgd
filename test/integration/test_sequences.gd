# ############################################################################ #
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://test/integration/test_base.gd"

# ############################################################################ #

func test_blanks_in_inline_sequences():
    var story = Story.new(load_file("blanks_in_inline_sequences"))
    assert_eq(story.continue_maximally(), "1. a\n2.\n3. b\n4. b\n---\n1.\n2. a\n3. a\n---\n1. a\n2.\n3.\n---\n1.\n2.\n3.\n")

func test_empty_sequence_content():
    var story = Story.new(load_file("empty_sequence_content"))

    assert_eq(story.continue_maximally(), "Wait for it....\nSurprise!\nDone.\n")

func test_gather_read_count_with_initial_sequence():
    var story = Story.new(load_file("gather_read_count_with_initial_sequence"))

    assert_eq(story.continue(), "seen test\n")

func test_leading_newline_multiline_sequence():
    var story = Story.new(load_file("leading_newline_multiline_sequence"))

    assert_eq(story.continue(), "a line after an empty line\n")

func test_shuffle_stack_muddying():
    var story = Story.new(load_file("shuffle_stack_muddying"))

    story.continue()

    assert_eq(story.current_choices.size(), 2)

# ############################################################################ #

func _prefix():
    return "sequences/"
