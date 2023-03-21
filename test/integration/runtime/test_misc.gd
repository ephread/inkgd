# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://test/integration/runtime/test_base.gd"

# ############################################################################ #

func test_empty():
	var story = InkStory.new(load_file("empty"))
	assert_eq(story.continue_maximally(), "")

func test_end_of_content():
	var story = InkStory.new(load_file("end_of_content"))

	story.continue_maximally()
	assert_false(story.has_error)  # Removed in ink 1.0.0 but kept here for now.

func test_end():
	var story = InkStory.new(load_file("end"))

	assert_eq(story.continue_maximally(), "hello\n")

func test_end2():
	var story = InkStory.new(load_file("end2"))

	assert_eq(story.continue_maximally(), "hello\n")

func test_escape_character():
	var story = InkStory.new(load_file("escape_character"))

	assert_eq(story.continue_maximally(), "this is a '|' character\n")

func test_hello_world():
	var story = InkStory.new(load_file("hello_world"))

	assert_eq(story.continue_story(), "Hello world\n")

func test_identifiers_can_start_with_number():
	var story = InkStory.new(load_file("identifiers_can_start_with_number"))

	assert_eq(story.continue_maximally(), "512x2 = 1024\n512x2p2 = 1026\n")

func test_include():
	var story = InkStory.new(load_file("include"))

	assert_eq(story.continue_maximally(), "This is include 1.\nThis is include 2.\nThis is the main file.\n")

func test_nested_include():
	var story = InkStory.new(load_file("nested_include"))

	assert_eq(story.continue_maximally(), "The value of a variable in test file 2 is 5.\nThis is the main file\nThe value when accessed from knot_in_2 is 5.\n")

func test_quote_character_significance():
	var story = InkStory.new(load_file("quote_character_significance"))

	assert_eq(story.continue_maximally(), "My name is \"Joe\"\n")

func test_whitespace():
	var story = InkStory.new(load_file("whitespace"))

	assert_eq(story.continue_maximally(), "Hello!\nWorld.\n")

# ############################################################################ #

func _prefix():
	return "runtime/misc/"
