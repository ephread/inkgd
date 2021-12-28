# ############################################################################ #
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://test/integration/runtime/test_base.gd"

var ErrorType = preload("res://addons/inkgd/runtime/enums/error.gd").ErrorType

var _temp_not_found_last_error_type = -1
var _temp_not_found_error_count = 0

var _exception_raised_count = 0

# ############################################################################ #

func before_all():
	.before_all()
	ink_runtime.connect("exception_raised", self, "_exception_raised")

func after_all():
	ink_runtime.disconnect("exception_raised", self, "_exception_raised")
	.after_all()

func after_each():
	_temp_not_found_last_error_type = -1
	_temp_not_found_error_count = 0

	_exception_raised_count = 0

# ############################################################################ #

func test_const():
	var story = Story.new(load_file("const"))
	assert_eq(story.continue(), "5\n")

func test_multiple_constant_references():
	var story = Story.new(load_file("multiple_constant_references"))

	assert_eq(story.continue(), "success\n")

func test_set_non_existent_variable():
	var story = Story.new(load_file("set_non_existant_variable"))

	assert_eq(story.continue(), "Hello world.\n")

	story.variables_state.set("y", "earth")

	assert_eq(_exception_raised_count, 1)

func test_temp_global_conflict():
	var story = Story.new(load_file("temp_global_conflict"))

	assert_eq(story.continue(), "0\n")

func test_temp_not_found():
	var story = Story.new(load_file("temp_not_found"))
	story.connect("on_error", self, "_temp_not_found_on_error")

	assert_eq(story.continue_maximally(), "0\nhello\n")
	assert_true(_temp_not_found_had_warning()) # Changed in ink 1.0.0 but kept here for now.

func test_temp_usage_in_options():
	var story = Story.new(load_file("temp_usage_in_options"))

	story.continue()

	assert_eq(story.current_choices.size(), 1)
	assert_eq(story.current_choices[0].text, "1")
	story.choose_choice_index(0)

	assert_eq(story.continue_maximally(), "1\nEnd of choice\nthis another\n")

	assert_eq(story.current_choices.size(), 0)

func test_temporaries_at_global_scope():
	var story = Story.new(load_file("temporaries_at_global_scope"))

	assert_eq(story.continue(), "54\n")

func test_variable_declaration_in_conditional():
	var story = Story.new(load_file("variable_declaration_in_conditional"))

	assert_eq(story.continue(), "5\n")

func test_variable_divert_target():
	var story = Story.new(load_file("variable_divert_target"))

	assert_eq(story.continue(), "Here.\n")

func test_variable_get_set_api():
	var story = Story.new(load_file("variable_get_set_api"))

	assert_eq(story.continue_maximally(), "5\n")
	assert_eq(story.variables_state.get("x"), 5)

	story.variables_state.set("x", 10)
	story.choose_choice_index(0)
	assert_eq(story.continue_maximally(), "10\n")
	assert_eq(story.variables_state.get("x"), 10)

	story.variables_state.set("x", 8.5)
	story.choose_choice_index(0)
	assert_eq(story.continue_maximally(), "8.5\n")
	assert_eq(story.variables_state.get("x"), 8.5)

	story.variables_state.set("x", "a string")
	story.choose_choice_index(0)
	assert_eq(story.continue_maximally(), "a string\n")
	assert_eq(story.variables_state.get("x"), "a string")

	assert_eq(story.variables_state.get("z"), null)

	story.variables_state.set("x", [])
	assert_eq(_exception_raised_count, 1)

func test_variable_pointer_ref_from_knot():
	var story = Story.new(load_file("variable_pointer_ref_from_knot"))

	assert_eq(story.continue(), "6\n")

func test_variable_swap_recurse():
	var story = Story.new(load_file("variable_swap_recurse"))

	assert_eq(story.continue_maximally(), "1 2\n")

func test_variable_tunnel():
	var story = Story.new(load_file("variable_tunnel"))

	assert_eq(story.continue_maximally(), "STUFF\n")

# ############################################################################ #

func _temp_not_found_on_error(message, type):
	_temp_not_found_last_error_type = type
	_temp_not_found_error_count += 1

func _temp_not_found_had_warning():
	return (
		_temp_not_found_last_error_type == ErrorType.WARNING &&
		_temp_not_found_error_count == 1
	)

func _exception_raised(message):
	_exception_raised_count += 1
	printerr(message)

# ############################################################################ #

func _prefix():
	return "runtime/variables/"
