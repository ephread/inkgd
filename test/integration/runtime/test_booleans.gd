# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://test/integration/runtime/test_base.gd"

# ############################################################################ #

func test_false_plus_false():
	var story = InkStory.new(load_file("false_plus_false"))
	assert_eq(story.continue_story(), "0\n")

func test_list_hasnt():
	var story = InkStory.new(load_file("list_hasnt"))
	assert_eq(story.continue_story(), "true\n")

func test_not_one():
	var story = InkStory.new(load_file("not_one"))
	assert_eq(story.continue_story(), "false\n")

func test_not_true():
	var story = InkStory.new(load_file("not_true"))
	assert_eq(story.continue_story(), "false\n")

func test_three_greater_than_one():
	var story = InkStory.new(load_file("three_greater_than_one"))
	assert_eq(story.continue_story(), "true\n")

func test_true_equals_one():
	var story = InkStory.new(load_file("true_equals_one"))
	assert_eq(story.continue_story(), "true\n")

func test_true_plus_one():
	var story = InkStory.new(load_file("true_plus_one"))
	assert_eq(story.continue_story(), "2\n")

func test_true_plus_true():
	var story = InkStory.new(load_file("true_plus_true"))
	assert_eq(story.continue_story(), "2\n")

func test_true():
	var story = InkStory.new(load_file("true"))
	assert_eq(story.continue_story(), "true\n")

func test_two_plus_true():
	var story = InkStory.new(load_file("two_plus_true"))
	assert_eq(story.continue_story(), "3\n")

# ############################################################################ #

func _prefix():
	return "runtime/booleans/"
