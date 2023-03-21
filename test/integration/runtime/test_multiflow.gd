# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://test/integration/runtime/test_base.gd"

# ############################################################################ #

func test_multi_flow_basics():
	var story = InkStory.new(load_file("multi_flow_basics"))

	story.switch_flow("First")
	story.choose_path_string("knot1")
	assert_eq(story.continue_story(), "knot 1 line 1\n")

	story.switch_flow("Second")
	story.choose_path_string("knot2")
	assert_eq(story.continue_story(), "knot 2 line 1\n")

	story.switch_flow("First")
	assert_eq(story.continue_story(), "knot 1 line 2\n")

	story.switch_flow("Second")
	assert_eq(story.continue_story(), "knot 2 line 2\n")

func test_multi_flow_save_load_threads():
	var story = InkStory.new(load_file("multi_flow_save_load_threads"))

	assert_eq(story.continue_story(), "Default line 1\n")

	story.switch_flow("Blue Flow")
	story.choose_path_string("blue")
	assert_eq(story.continue_story(), "Hello I'm blue\n")

	story.switch_flow("Red Flow")
	story.choose_path_string("red")
	assert_eq(story.continue_story(), "Hello I'm red\n")

	story.switch_flow("Blue Flow")
	assert_eq("Hello I'm blue\n", story.current_text)
	assert_eq("Thread 1 blue choice", story.current_choices[0].text)

	story.switch_flow("Red Flow")
	assert_eq("Hello I'm red\n", story.current_text)
	assert_eq("Thread 1 red choice", story.current_choices[0].text)

	var saved = story.state.to_json()

	story.choose_choice_index(0)
	assert_eq("Thread 1 red choice\nAfter thread 1 choice (red)\n", story.continue_maximally())
	story.reset_state()

	story.state.load_json(saved)

	story.choose_choice_index(1)
	assert_eq("Thread 2 red choice\nAfter thread 2 choice (red)\n", story.continue_maximally())

	story.state.load_json(saved)
	story.switch_flow("Blue Flow")
	story.choose_choice_index(0)
	assert_eq("Thread 1 blue choice\nAfter thread 1 choice (blue)\n", story.continue_maximally())

	story.state.load_json(saved)
	story.switch_flow("Blue Flow")
	story.choose_choice_index(1)
	assert_eq("Thread 2 blue choice\nAfter thread 2 choice (blue)\n", story.continue_maximally())

	story.remove_flow("Blue Flow")
	assert_eq(story.continue_story(), "Default line 2\n")

# ############################################################################ #

func _prefix():
	return "runtime/multiflow/"
