# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends InkObject

# This is a merge of the original Value class and its Value<T> subclass.
class_name InkValue

# ############################################################################ #
# IMPORTS
# ############################################################################ #

const ValueType = preload("res://addons/inkgd/runtime/values/value_type.gd").ValueType

# ############################################################################ #

var value # Variant

# ValueType
var value_type: ValueType: get = get_value_type
func get_value_type() -> int:
	return -1

var is_truthy: bool: get = get_is_truthy
func get_is_truthy() -> bool:
	return false

# ############################################################################ #

# (ValueType) -> ValueType
func cast(_new_type: ValueType) -> InkValue:
	return null

var value_object: Variant:
	get:
		return value

# ############################################################################ #

# (Variant) -> Value
func _init_with(val):
	value = val

# (Variant) -> Value
static func create(val) -> InkValue:
	# Original code lost precision from double to float.
	# But it's not applicable here.

	if val is bool:
		return InkBoolValue.new_with(val)
	if val is int:
		return InkIntValue.new_with(val)
	elif val is float:
		return InkFloatValue.new_with(val)
	elif val is String:
		return InkStringValue.new_with(val)
	elif val is InkPath:
		return InkDivertTargetValue.new_with(val)
	elif val is InkList:
		return InkListValue.new_with(val)

	return null

func copy() -> InkValue:
	return InkValue.create(value_object)

# (Ink.ValueType) -> StoryException
func bad_cast_exception_message(target_class) -> String:
	return "Can't cast " + str(value_object) + " from " + str(value_type) + " to " + str(target_class)

# () -> String
func _to_string() -> String:
	if value is int || value is float || value is String:
		return str(value)
	else:
		return value._to_string()

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

static func new_with(val) -> InkValue:
	var value = InkValue.new()
	value._init_with(val)
	return value
