# ############################################################################ #
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://test/integration/test_base.gd"

# ############################################################################ #

func test_empty_list_origin():
	var story = Story.new(load_file("empty_list_origin"))

	assert_eq(story.continue_maximally(), "a, b\n")

func test_empty_list_origin_after_assignment():
	var story = Story.new(load_file("empty_list_origin_after_assignment"))

	assert_eq(story.continue_maximally(), "a, b, c\n")

func test_list_basic_operations():
	var story = Story.new(load_file("list_basic_operations"))

	assert_eq(story.continue_maximally(), "b, d\na, b, c, e\nb, c\nfalse\ntrue\ntrue\n")

func test_list_mixed_items():
	var story = Story.new(load_file("list_mixed_items"))

	assert_eq(story.continue_maximally(), "a, y, c\n")

func test_list_random():
	var story = Story.new(load_file("list_random"))

	while story.can_continue:
		var result = story.continue()
		assert_true(result == "B\n" || result == "C\n" || result == "D\n")

func test_list_range():
	var story = Story.new(load_file("list_range"))

	assert_eq(story.continue_maximally(), "Pound, Pizza, Euro, Pasta, Dollar, Curry, Paella\nEuro, Pasta, Dollar, Curry\nTwo, Three, Four, Five, Six\nPizza, Pasta\n")

func test_list_save_load():
	var story = Story.new(load_file("list_save_load"))

	assert_eq(story.continue_maximally(), "a, x, c\n")

	var saved_state = story.state.to_json()

	story = Story.new(load_file("list_save_load"))

	story.state.load_json(saved_state)

	story.choose_path_string("elsewhere")
	assert_eq(story.continue_maximally(), "a, x, c, z\n")

func test_more_list_operations():
	var story = Story.new(load_file("more_list_operations"))

	assert_eq(story.continue_maximally(), "1\nl\nn\nl, m\nn\n")

# ############################################################################ #

func _prefix():
	return "lists/"
