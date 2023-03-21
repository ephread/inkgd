# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://test/integration/runtime/test_base.gd"

# ############################################################################ #

func test_implicit_inline_glue():
	var story = InkStory.new(load_file("implicit_inline_glue"))

	assert_eq(story.continue_story(), "I have five eggs.\n")

func test_implicit_inline_glue_b():
	var story = InkStory.new(load_file("implicit_inline_glue_b"))

	assert_eq(story.continue_maximally(), "A\nX\n")

func test_implicit_inline_glue_c():
	var story = InkStory.new(load_file("implicit_inline_glue_c"))

	assert_eq(story.continue_maximally(), "A\nC\n")

func test_left_right_glue_matching():
	var story = InkStory.new(load_file("left_right_glue_matching"))

	assert_eq(story.continue_maximally(), "A line.\nAnother line.\n")

func test_simple_glue():
	var story = InkStory.new(load_file("simple_glue"))

	assert_eq(story.continue_story(), "Some content with glue.\n")

# ############################################################################ #

func _prefix():
	return "runtime/glue/"
