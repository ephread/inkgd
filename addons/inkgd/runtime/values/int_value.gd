# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends InkValue

class_name InkIntValue

# ############################################################################ #

func get_value_type():
	return ValueType.INT

func get_is_truthy():
	return value != 0

func _init():
	value = 0

# The method takes a `StoryErrorMetadata` object as a parameter that
# doesn't exist in upstream. The metadat are used in case an 'exception'
# is raised. For more information, see story.gd.
func cast(new_type, metadata = null):
	if new_type == value_type:
		return self

	if new_type == ValueType.BOOL:
		return InkBoolValue.new_with(false if value == 0 else true)

	if new_type == ValueType.FLOAT:
		return InkFloatValue.new_with(float(value))

	if new_type == ValueType.STRING:
		return InkStringValue.new_with(str(value))

	InkUtils.throw_story_exception(bad_cast_exception_message(new_type), false, metadata)
	return null

# ######################################################################## #
# GDScript extra methods
# ######################################################################## #

static func new_with(val):
	var value = InkIntValue.new()
	value._init_with(val)
	return value
