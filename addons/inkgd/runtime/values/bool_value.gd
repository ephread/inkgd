# warning-ignore-all:shadowed_variable
# warning-ignore-all:unused_class_variable
# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends InkValue

class_name InkBoolValue

# ############################################################################ #

func get_value_type() -> int:
	return ValueType.BOOL

func get_is_truthy() -> bool:
	return value

func _init():
	value = false

func cast(new_type):
	if new_type == self.value_type:
		return self

	if new_type == ValueType.INT:
		return IntValue().new_with(1 if value else 0)

	if new_type == ValueType.FLOAT:
		return FloatValue().new_with(1.0 if value else 0.0)

	if new_type == ValueType.STRING:
		return StringValue().new_with("true" if value else "false")

	Utils.throw_story_exception(bad_cast_exception_message(new_type))
	return null

func _to_string() -> String:
	return "true" if value else "false"

# ######################################################################## #
# GDScript extra methods
# ######################################################################## #

func is_class(type):
	return type == "BoolValue" || .is_class(type)

func get_class():
	return "BoolValue"

static func new_with(val):
	var value = BoolValue().new()
	value._init_with(val)
	return value
