# warning-ignore-all:shadowed_variable
# warning-ignore-all:unused_class_variable
# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2023 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends InkObject

# This is a merge of the original Value class and its Value<T> subclass.
class_name InkValue

# ############################################################################ #

var value # Variant

# ValueType
var value_type: int: get = get_value_type
func get_value_type() -> int:
	return -1

var is_truthy: bool: get = get_is_truthy
func get_is_truthy() -> bool:
	return false

# ############################################################################ #

# (ValueType) -> ValueType
func cast(new_type: int) -> InkValue:
	return null

var value_object: # Variant
	get: return value

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
	elif InkUtils.is_ink_class(val, "InkPath"):
		return InkDivertTargetValue.new_with(val)
	elif InkUtils.is_ink_class(val, "InkList"):
		return InkListValue.new_with(val)

	return null

func copy() -> InkObject:
	return create(self.value_object)

# (Ink.ValueType) -> StoryException
func bad_cast_exception_message(target_ink_class) -> String:
	return str("Can't cast ", self.value_object, " from ", self.value_type, " to ", target_ink_class)

# () -> String
func _to_string() -> String:
	if value is int || value is float || value is String:
		return str(value)
	else:
		return value._to_string()

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_ink_class(type) -> bool:
	return type == "Value" || super.is_ink_class(type)

func get_ink_class() -> String:
	return "Value"

static func new_with(val) -> InkValue:
	var value = InkValue.new()
	value._init_with(val)
	return value
