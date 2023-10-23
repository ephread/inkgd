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

extends InkObject

# This is a merge of the original Value class and its Value<T> subclass.
class_name InkValue

# ############################################################################ #
# IMPORTS
# ############################################################################ #

const ValueType = preload("res://addons/inkgd/runtime/values/value_type.gd").ValueType
var InkList = load("res://addons/inkgd/runtime/lists/ink_list.gd")

# ############################################################################ #
# STATIC REFERENCE
# ############################################################################ #

# TODO: Remove
#static func Utils():
#	return load("res://addons/inkgd/runtime/extra/InkUtils.gd")
#
#static func Value():
#	return load("res://addons/inkgd/runtime/values/value.gd")

static func BoolValue():
	return load("res://addons/inkgd/runtime/values/bool_value.gd")

static func IntValue():
	return load("res://addons/inkgd/runtime/values/int_value.gd")

static func FloatValue():
	return load("res://addons/inkgd/runtime/values/float_value.gd")

static func StringValue():
	return load("res://addons/inkgd/runtime/values/string_value.gd")

static func DivertTargetValue():
	return load("res://addons/inkgd/runtime/values/divert_target_value.gd")

static func VariablePointerValue():
	return load("res://addons/inkgd/runtime/values/variable_pointer_value.gd")

static func ListValue():
	return load("res://addons/inkgd/runtime/values/list_value.gd")

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
		return BoolValue().new_with(val)
	if val is int:
		return IntValue().new_with(val)
	elif val is float:
		return FloatValue().new_with(val)
	elif val is String:
		return StringValue().new_with(val)
	elif InkUtils.is_ink_class(val, "InkPath"):
		return DivertTargetValue().new_with(val)
	elif InkUtils.is_ink_class(val, "InkList"):
		return ListValue().new_with(val)

	return null

func copy() -> InkValue:
	return create(self.value_object)

# (Ink.ValueType) -> StoryException
func bad_cast_exception_message(target_ink_class) -> String:
	return "Can't cast " + self.value_object + " from " + self.value_type + " to " + target_ink_class

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
