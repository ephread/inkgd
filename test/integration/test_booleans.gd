# ############################################################################ #
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://test/integration/test_base.gd"

# ############################################################################ #

func test_false_plus_false():
	var story = Story.new(load_file("false_plus_false"))
	assert_eq(story.continue(), "0\n")

func test_list_hasnt():
	var story = Story.new(load_file("list_hasnt"))
	assert_eq(story.continue(), "true\n")

func test_not_one():
	var story = Story.new(load_file("not_one"))
	assert_eq(story.continue(), "false\n")

func test_not_true():
	var story = Story.new(load_file("not_true"))
	assert_eq(story.continue(), "false\n")

func test_three_greater_than_one():
	var story = Story.new(load_file("three_greater_than_one"))
	assert_eq(story.continue(), "true\n")

func test_true_equals_one():
	var story = Story.new(load_file("true_equals_one"))
	assert_eq(story.continue(), "true\n")

func test_true_plus_one():
	var story = Story.new(load_file("true_plus_one"))
	assert_eq(story.continue(), "2\n")

func test_true_plus_true():
	var story = Story.new(load_file("true_plus_true"))
	assert_eq(story.continue(), "2\n")

func test_true():
	var story = Story.new(load_file("true"))
	assert_eq(story.continue(), "true\n")

func test_two_plus_true():
	var story = Story.new(load_file("two_plus_true"))
	assert_eq(story.continue(), "3\n")

# ############################################################################ #

func _prefix():
	return "booleans/"
