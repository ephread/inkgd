# ############################################################################ #
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://test/integration/test_base.gd"

# ############################################################################ #

func test_callstack_evaluation():
	var story = Story.new(load_file("call_stack_evaluation"))
	assert_eq(story.continue(), "8\n")

func test_clean_callstack_reset_on_path_choice():
	var story = Story.new(load_file("clean_callstack_reset_on_path_choice"))

	assert_eq("The first line.\n", story.continue())

	story.choose_path_string("SomewhereElse")

	assert_eq("somewhere else\n", story.continue_maximally())

# ############################################################################ #

func _prefix():
	return "callstack/"
