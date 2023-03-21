# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends InkValue

class_name InkStringValue

# ############################################################################ #

func get_value_type():
	return ValueType.STRING

func get_is_truthy():
	return value.length() > 0

var is_newline # bool
var is_inline_whitespace # bool
var is_non_whitespace:
	get:
		return !is_newline && !is_inline_whitespace

func _init():
	value = ""
	_sanitize_value()

func _init_with(val):
	super._init_with(val)
	_sanitize_value()

# The method takes a `StoryErrorMetadata` object as a parameter that
# doesn't exist in upstream. The metadat are used in case an 'exception'
# is raised. For more information, see story.gd.
func cast(new_type, metadata = null):
	if new_type == value_type:
		return self

	if new_type == ValueType.INT:
		if value.is_valid_int():
			return InkIntValue.new_with(int(value))
		else:
			return null

	if new_type == ValueType.FLOAT:
		if value.is_valid_float():
			return InkFloatValue.new_with(float(value))
		else:
			return null

	InkUtils.throw_story_exception(bad_cast_exception_message(new_type), false, metadata)
	return null

# ######################################################################## #
# GDScript extra methods
# ######################################################################## #

func _sanitize_value():
	is_newline = (value == "\n")
	is_inline_whitespace = true

	for c in value:
		if c != ' ' && c != "\t":
			is_inline_whitespace = false
			break

static func new_with(val):
	var value = InkStringValue.new()
	value._init_with(val)
	return value
