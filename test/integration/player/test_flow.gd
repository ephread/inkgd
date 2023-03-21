# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://test/integration/player/test_base.gd"

# These tests should be run in both vanilla and mono environment.

# ############################################################################ #
# Methods
# ############################################################################ #

func test_continue() -> void:
	await _load_story("flow")

	assert_true(_ink_player.can_continue)
	assert_eq(_ink_player.continue_story(), "Hello\n")
	assert_eq(_ink_player.current_text, "Hello\n")

	_ink_player.continue_story_maximally()

	assert_false(_ink_player.can_continue)

	assert_eq(_exception_messages_raised.size(), 0)


func test_tags() -> void:
	await _load_story("flow")

	assert_eq_deep(_ink_player.global_tags, ["globalTag1", "globalTag2"])

	_ink_player.continue_story_maximally()

	assert_eq_deep(_ink_player.global_tags, ["globalTag1", "globalTag2"])
	assert_eq_deep(_ink_player.current_tags, ["globalTag1", "globalTag2", "startTag1", "helloTag1"])

	assert_eq(_exception_messages_raised.size(), 0)


func test_choices() -> void:
	await _load_story("flow")

	assert_false(_ink_player.has_choices)

	_ink_player.continue_story_maximally()

	assert_true(_ink_player.has_choices)
	assert_eq_deep(_ink_player.current_choices, ["Choice 1", "Choice 2", "Choice 3"])
	_ink_player.choose_choice_index(1)

	assert_true(_ink_player.can_continue)
	assert_eq(_ink_player.continue_story(), "Choice 2\n")
	assert_eq(_ink_player.continue_story(), "This is chapter 1\n")

	assert_eq(_exception_messages_raised.size(), 0)


func test_multi_flow() -> void:
	await _load_story("flow")

	_ink_player.switch_flow("new_flow")
	_ink_player.choose_path("prologue")
	_ink_player.continue_story_maximally()
	_ink_player.choose_choice_index(1)

	assert_eq(_ink_player.continue_story(), "Choice 2\n")
	assert_eq(_ink_player.current_flow_name, "new_flow")

	_ink_player.switch_to_default_flow()
	_ink_player.continue_story_maximally()
	_ink_player.choose_choice_index(0)

	assert_eq(_ink_player.continue_story(), "Choice 1\n")
	assert_eq(_ink_player.current_flow_name, "DEFAULT_FLOW")

	_ink_player.remove_flow("new_flow")

	assert_eq(_exception_messages_raised.size(), 0)
