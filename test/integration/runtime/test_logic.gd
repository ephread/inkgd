# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://test/integration/runtime/test_base.gd"

# ############################################################################ #

func test_logic_lines_with_newlines():
	var story = InkStory.new(load_file("logic_lines_with_newlines"))

	assert_eq(story.continue_maximally(), "text1\ntext 2\ntext1\ntext 2\n")

func test_multiline_logic_with_glue():
	var story = InkStory.new(load_file("multiline_logic_with_glue"))

	assert_eq(story.continue_maximally(), "a b\na b\n")

func test_nested_pass_by_reference():
	var story = InkStory.new(load_file("nested_pass_by_reference"))

	assert_eq(story.continue_maximally(), "5\n625\n")

func test_print_num():
	var story = InkStory.new(load_file("print_num"))

	assert_eq(
		story.continue_maximally(),
		". four .\n. fifteen .\n. thirty-seven .\n. one hundred and one .\n. two hundred and twenty-two .\n. one thousand two hundred and thirty-four .\n"
	)

# ############################################################################ #

func _prefix():
	return "runtime/logic/"
