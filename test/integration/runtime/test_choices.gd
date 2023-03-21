# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://test/integration/runtime/test_base.gd"

# ############################################################################ #

func test_choice_count():
	var story = InkStory.new(load_file("choice_count"))
	assert_eq(story.continue_story(), "2\n")

func test_choice_diverts_to_done():
	var story = InkStory.new(load_file("choice_diverts_to_done"))
	story.continue_story()

	assert_eq(story.current_choices.size(), 1)
	story.choose_choice_index(0)

	assert_eq(story.continue_story(), "choice")
	assert_false(story.has_error) # Removed in ink 1.0.0 but kept here for now.

func test_choice_with_brackets_only():
	var story = InkStory.new(load_file("choice_with_brackets_only"))
	story.continue_story()

	assert_eq(story.current_choices.size(), 1)
	assert_eq(story.current_choices[0].text, "Option")
	story.choose_choice_index(0)

	assert_eq(story.continue_story(), "Text\n")

func test_choice_thread_forking():
	var story = InkStory.new(load_file("choice_thread_forking"))

	story.continue_story()
	var saved_state = story.state.to_json()

	story = InkStory.new(load_file("choice_thread_forking"))
	story.state.load_json(saved_state)

	story.choose_choice_index(0)
	story.continue_maximally()

	assert_false(story.has_warning)

func test_conditional_choices():
	var story = InkStory.new(load_file("conditional_choices"))
	story.continue_maximally()

	assert_eq(story.current_choices.size(), 4)
	assert_eq(story.current_choices[0].text, "one")
	assert_eq(story.current_choices[1].text, "two")
	assert_eq(story.current_choices[2].text, "three")
	assert_eq(story.current_choices[3].text, "four")

func test_default_choice():
	var story = InkStory.new(load_file("default_choices"))

	assert_eq(story.continue_story(), "")
	assert_eq(story.current_choices.size(), 2)

	story.choose_choice_index(0)
	assert_eq(story.continue_story(), "After choice\n")

	assert_eq(story.current_choices.size(), 1)

	story.choose_choice_index(0)
	assert_eq(story.continue_maximally(), "After choice\nThis is default.\n")

func test_default_simple_gather():
	var story = InkStory.new(load_file("default_simple_gather"))
	assert_eq(story.continue_story(), "x\n")

func test_fallback_choice_on_thread():
	var story = InkStory.new(load_file("fallback_choice_on_thread"))

	assert_eq(story.continue_story(), "Should be 1 not 0: 1.\n")

func test_gather_choice_same_line():
	var story = InkStory.new(load_file("gather_choice_same_line"))

	story.continue_story()
	assert_eq(story.current_choices[0].text, "hello")

	story.choose_choice_index(0)
	story.continue_story()

	assert_eq(story.current_choices[0].text, "world")

func test_has_read_on_choice():
	var story = InkStory.new(load_file("has_read_on_choice"))
	story.continue_maximally()

	assert_eq(story.current_choices.size(), 1)
	assert_eq(story.current_choices[0].text, "visible choice")

func test_logic_in_choices():
	var story = InkStory.new(load_file("logic_in_choices"))

	story.continue_maximally()

	assert_eq(story.current_choices[0].text, "'Hello Joe, your name is Joe.'")
	story.choose_choice_index(0)
	assert_eq(story.continue_maximally(), "'Hello Joe,' I said, knowing full well that his name was Joe.\n")

func test_non_text_in_choice_inner_content():
	var story = InkStory.new(load_file("non_text_in_choice_inner_content"))

	story.continue_story()
	story.choose_choice_index(0)

	assert_eq(story.continue_story(), "option text. Conditional bit. Next.\n")

func test_once_only_choices_can_link_back_to_self():
	var story = InkStory.new(load_file("once_only_choices_can_link_back_to_self"))

	story.continue_maximally()

	assert_eq(story.current_choices.size(), 1)
	assert_eq(story.current_choices[0].text, "First choice")

	story.choose_choice_index(0)
	story.continue_maximally()

	assert_eq(story.current_choices.size(), 1)
	assert_eq(story.current_choices[0].text, "Second choice")

	story.choose_choice_index(0)
	story.continue_maximally()

	assert_false(story.has_error) # Removed in ink 1.0.0 but kept here for now.

func test_once_only_choices_with_own_content():
	var story = InkStory.new(load_file("once_only_choices_with_own_content"))

	story.continue_maximally()

	assert_eq(story.current_choices.size(), 3)

	story.choose_choice_index(0)
	story.continue_maximally()

	assert_eq(story.current_choices.size(), 2)

	story.choose_choice_index(0)
	story.continue_maximally()

	assert_eq(story.current_choices.size(), 1)

	story.choose_choice_index(0)
	story.continue_maximally()

	assert_eq(story.current_choices.size(), 0)

func test_should_not_gather_due_to_choice():
	var story = InkStory.new(load_file("should_not_gather_due_to_choice"))

	story.continue_maximally()
	story.choose_choice_index(0)

	assert_eq(story.continue_maximally(), "opt\ntext\n")

func test_state_rollback_over_default_choice():
	var story = InkStory.new(load_file("state_rollback_over_default_choice"))

	assert_eq(story.continue_story(), "Text.\n");
	assert_eq(story.continue_story(), "5\n");

func test_sticky_choices_stay_sticky():
	var story = InkStory.new(load_file("sticky_choices_stay_sticky"))

	story.continue_maximally()
	assert_eq(story.current_choices.size(), 2)

	story.choose_choice_index(0)
	story.continue_maximally()
	assert_eq(story.current_choices.size(), 2)

func test_various_default_choices():
	var story = InkStory.new(load_file("various_default_choices"))

	assert_eq(story.continue_maximally(), "1\n2\n3\n")

# ############################################################################ #

func _prefix():
	return "runtime/choices/"
