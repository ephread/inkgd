# ############################################################################ #
# Copyright © 2019-2023 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://test/integration/runtime/test_base.gd"

# ############################################################################ #

func test_tags():
	var story := InkStory.new(load_file("tags"))

	var global_tags = ["author: Joe", "title: My Great Story"]
	var knot_tags = ["knot tag"]
	var knot_tag_when_continued_twice_tags = ["end of knot tag"]
	var stitch_tags = ["stitch tag"]

	assert_eq(story.global_tags, global_tags)
	assert_eq(story.continue_story(), "This is the content\n")
	assert_eq(story.current_tags, global_tags)

	assert_eq(story.tags_for_content_at_path("knot"), knot_tags)
	assert_eq(story.tags_for_content_at_path("knot.stitch"), stitch_tags)

	story.choose_path_string("knot")
	assert_eq(story.continue_story(), "Knot content\n")
	assert_eq(story.current_tags, knot_tags)
	assert_eq(story.continue_story(), "")
	assert_eq(story.current_tags, knot_tag_when_continued_twice_tags)


func test_tags_in_seq():
	var story := InkStory.new(load_file("tags_in_seq"))

	assert_eq(story.continue_story(), "A red sequence.\n")
	assert_eq(story.current_tags, ["red"])

	assert_eq(story.continue_story(), "A white sequence.\n")
	assert_eq(story.current_tags, ["white"])


func test_tags_in_choice():
	var story := InkStory.new(load_file("tags_in_choice"))

	story.continue_story()
	assert_eq(story.current_tags.size(), 0)
	assert_eq(story.current_choices.size(), 1)
	assert_eq(story.current_choices[0].tags, ["one", "two"])

	story.choose_choice_index(0)

	assert_eq(story.continue_story(), "one three")
	assert_eq(story.current_tags, ["one", "three"])


func test_tags_dynamic_content():
	var story := InkStory.new(load_file("tags_dynamic_content"))

	assert_eq(story.continue_story(), "tag\n")
	assert_eq(story.current_tags, ["pic8red.jpg"])


# ############################################################################ #

func _prefix():
	return "runtime/tags/"
