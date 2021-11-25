# ############################################################################ #
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://test/integration/test_base.gd"

# ############################################################################ #

func test_implicit_inline_glue():
	var story = Story.new(load_file("implicit_inline_glue"))

	assert_eq(story.continue(), "I have five eggs.\n")

func test_implicit_inline_glue_b():
	var story = Story.new(load_file("implicit_inline_glue_b"))

	assert_eq(story.continue_maximally(), "A\nX\n")

func test_implicit_inline_glue_c():
	var story = Story.new(load_file("implicit_inline_glue_c"))

	assert_eq(story.continue_maximally(), "A\nC\n")

func test_left_right_glue_matching():
	var story = Story.new(load_file("left_right_glue_matching"))

	assert_eq(story.continue_maximally(), "A line.\nAnother line.\n")

func test_simple_glue():
	var story = Story.new(load_file("simple_glue"))

	assert_eq(story.continue(), "Some content with glue.\n")

# ############################################################################ #

func _prefix():
	return "glue/"
