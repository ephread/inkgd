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

class_name InkVariablePointerValue

# ############################################################################ #

var variable_name setget set_variable_name, get_variable_name # InkPath
func get_variable_name():
	return value
func set_variable_name(value):
	self.value = value

func get_value_type():
	return ValueType.VARIABLE_POINTER

func get_is_truthy():
	Utils.throw_exception("Shouldn't be checking the truthiness of a variable pointer")
	return false

var context_index = 0 # int

func _init_with_context(variable_name, context_index = -1):
	._init_with(variable_name)
	self.context_index = context_index

func _init():
	value = null

func cast(new_type):
	if new_type == self.value_type:
		return self

	Utils.throw_story_exception(bad_cast_exception_message(new_type))
	return null

func _to_string() -> String:
	return "VariablePointerValue(" + self.variable_name + ")"

func copy():
	return VariablePointerValue().new_with_context(self.variable_name, context_index)

# ######################################################################## #
# GDScript extra methods
# ######################################################################## #

func is_class(type):
	return type == "VariablePointerValue" || .is_class(type)

func get_class():
	return "VariablePointerValue"

static func new_with_context(variable_name, context_index = -1):
	var value = VariablePointerValue().new()
	value._init_with_context(variable_name, context_index)
	return value
