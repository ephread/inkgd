# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://test/integration/runtime/test_base.gd"

# ############################################################################ #

func test_tags():
	var story = Story.new(load_file("tags"))

	var global_tags = ["author: Joe", "title: My Great Story"]
	var knot_tags = ["knot tag"]
	var knot_tag_when_continued_twice_tags = ["end of knot tag"]
	var stitch_tags = ["stitch tag"]

	assert_eq(story.global_tags, global_tags)
	assert_eq(story.continue(), "This is the content\n")
	assert_eq(story.current_tags, global_tags)

	assert_eq(story.tags_for_content_at_path("knot"), knot_tags)
	assert_eq(story.tags_for_content_at_path("knot.stitch"), stitch_tags)

	story.choose_path_string("knot")
	assert_eq(story.continue(), "Knot content\n")
	assert_eq(story.current_tags, knot_tags)
	assert_eq(story.continue(), "")
	assert_eq(story.current_tags, knot_tag_when_continued_twice_tags)


func test_tags_in_seq():
	var story = Story.new(load_file("tags_in_seq"))

	assert_eq(story.continue(), "A red sequence.\n")
	assert_eq(story.current_tags, ["red"])

	assert_eq(story.continue(), "A white sequence.\n")
	assert_eq(story.current_tags, ["white"])


func test_tags_in_choice():
	var story = Story.new(load_file("tags_in_choice"))

	story.continue()
	assert_eq(story.current_tags.size(), 0)
	assert_eq(story.current_choices.size(), 1)
	assert_eq(story.current_choices[0].tags, ["one", "two"])

	story.choose_choice_index(0)

	assert_eq(story.continue(), "one three")
	assert_eq(story.current_tags, ["one", "three"])


func test_tags_dynamic_content():
	var story = Story.new(load_file("tags_dynamic_content"))

	assert_eq(story.continue(), "tag\n")
	assert_eq(story.current_tags, ["pic8red.jpg"])


# ############################################################################ #

func _prefix():
	return "runtime/tags/"
