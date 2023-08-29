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
# Private Properties
# ############################################################################ #

var _variable_changed := []
var _string_variable_observer_call_count := 0
var _default_variable_observers_call_count := 0


# ############################################################################ #
# Overrides
# ############################################################################ #

func after_each():
	_string_variable_observer_call_count = 0
	_default_variable_observers_call_count = 0

	_ink_player.allow_external_function_fallbacks = false
	_ink_player.do_not_save_default_values = true
	_variable_changed = []

	super.after_each()


# ############################################################################ #
# Methods
# ############################################################################ #

func test_dont_save_default_values() -> void:
	await _load_story("variables")

	_ink_player.continue_story_maximally()

	var state1 = JSON.parse_string(_ink_player.get_state())

	_ink_player.choose_choice_index(1)
	_ink_player.continue_story()
	_ink_player.continue_story()

	var state2 = JSON.parse_string(_ink_player.get_state())

	assert_eq(_exception_messages_raised.size(), 0)

	_ink_player.reset()
	_ink_player.continue_story_maximally()
	_ink_player.do_not_save_default_values = false

	var state3 = JSON.parse_string(_ink_player.get_state())

	_ink_player.choose_choice_index(1)
	_ink_player.continue_story()
	_ink_player.continue_story()

	var state4 = JSON.parse_string(_ink_player.get_state())

	assert_eq(state1["variablesState"].size(), 0)
	assert_eq(state2["variablesState"].size(), 5)
	assert_eq(state3["variablesState"].size(), 5)
	assert_eq(state4["variablesState"].size(), 5)


func test_set_get_variable() -> void:
	await _load_story("variables")

	assert_eq(_ink_player.get_variable("anInteger"), 3)

	_ink_player.set_variable("anInteger", 4)

	assert_eq(_ink_player.get_variable("anInteger"), 4)

	_ink_player.set_variable("anInteger", "Hello")

	assert_eq(_ink_player.get_variable("anInteger"), "Hello")


# The following tests behave differently depending on Godot's flavour.
#
# In the official Objective-C version, it's possible to add the same
# observer multiple times. As a result, an observer can be called
# numerous times for the same variable. In GDScript, this is not allowed;
# an observer can only be added once.

func test_observe_variables() -> void:
	await _load_story("variables")

	_ink_player.observe_variables(
			["aBoolean", "aString", "anInteger"],
			self,
			"_default_variable_observer"
	)

	_ink_player.observe_variable(
			"aBoolean",
			self,
			"_default_variable_observer"
	)

	_ink_player.observe_variable(
			"aString",
			self,
			"_string_variable_observer"
	)

	_ink_player.choose_path("otherKnot")
	_ink_player.continue_story_maximally()

	assert_eq(_variable_changed.size(), 4 if _can_run_mono() else 3)
	assert_true("aBoolean" in _variable_changed)
	assert_true("aString" in _variable_changed)
	assert_true("anInteger" in _variable_changed)

	assert_eq(_string_variable_observer_call_count, 1)
	assert_eq(_default_variable_observers_call_count, 4 if _can_run_mono() else 3)


func test_remove_observer() -> void:
	await _load_story("variables")

	_ink_player.observe_variables(
			["aBoolean", "aString", "anInteger"],
			self,
			"_default_variable_observer"
	)

	_ink_player.observe_variable(
			"aString",
			self,
			"_string_variable_observer"
	)

	_ink_player.choose_path("otherKnot")
	_ink_player.continue_story_maximally()

	_ink_player.remove_variable_observer(
			self,
			"_default_variable_observer",
			"aBoolean"
	)

	_ink_player.reset()
	_string_variable_observer_call_count = 0
	_default_variable_observers_call_count = 0
	_variable_changed = []

	_ink_player.choose_path("otherKnot")
	_ink_player.continue_story_maximally()

	assert_eq(_variable_changed.size(), 2)
	assert_false("aBoolean" in _variable_changed)
	assert_true("aString" in _variable_changed)
	assert_true("anInteger" in _variable_changed)
	assert_eq(_string_variable_observer_call_count, 1)
	assert_eq(_default_variable_observers_call_count, 2)


func test_remove_observer_for_all_variables() -> void:
	await _load_story("variables")

	_ink_player.observe_variables(
			["aBoolean", "aString", "anInteger"],
			self,
			"_default_variable_observer"
	)

	_ink_player.choose_path("otherKnot")
	_ink_player.continue_story_maximally()

	assert_eq(_variable_changed.size(), 3)
	assert_true("aBoolean" in _variable_changed)
	assert_true("aString" in _variable_changed)
	assert_true("anInteger" in _variable_changed)

	_ink_player.remove_variable_observer_for_all_variables(
			self,
			"_default_variable_observer"
	)

	_ink_player.reset()
	_default_variable_observers_call_count = 0
	_variable_changed = []

	_ink_player.choose_path("otherKnot")
	_ink_player.continue_story_maximally()

	assert_eq(_default_variable_observers_call_count, 0)
	assert_true(_variable_changed.is_empty())


func test_remove_all_variable_observers() -> void:
	await _load_story("variables")

	_ink_player.observe_variable(
			"aString",
			self,
			"_default_variable_observer"
	)

	_ink_player.observe_variable(
			"aString",
			self,
			"_string_variable_observer"
	)

	_ink_player.choose_path("otherKnot")
	_ink_player.continue_story_maximally()

	assert_eq(_default_variable_observers_call_count, 1)
	assert_eq(_string_variable_observer_call_count, 1)

	_ink_player.remove_all_variable_observers("aString")
	_ink_player.reset()
	_default_variable_observers_call_count = 0
	_string_variable_observer_call_count = 0

	_ink_player.choose_path("otherKnot")
	_ink_player.continue_story_maximally()

	assert_eq(_default_variable_observers_call_count, 0)
	assert_eq(_string_variable_observer_call_count, 0)


# ############################################################################ #
# Private Methods
# ############################################################################ #

func _default_variable_observer(variable, value) -> void:
	_variable_changed.append(variable)
	_default_variable_observers_call_count += 1


func _string_variable_observer(variable, value) -> void:
	_string_variable_observer_call_count += 1
