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
	var story = InkStory.new(load_file("tags"))

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

func test_tags_on_choice():
	var story = InkStory.new(load_file("tags_on_choice"))

	story.continue_story()
	story.choose_choice_index(0)

	var txt = story.continue_story()
	var tags = story.current_tags

	assert_eq(txt, "Hello")
	assert_eq(tags.size(), 1)
	assert_eq(tags[0], "hey")

# ############################################################################ #

func _prefix():
	return "runtime/tags/"
