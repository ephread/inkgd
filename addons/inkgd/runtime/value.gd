# warning-ignore-all:shadowed_variable
# warning-ignore-all:unused_class_variable
# ############################################################################ #
# Copyright © 2015-present inkle Ltd.
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends Reference

# ############################################################################ #

enum ValueType {
	BOOL = -1,

	INT,
	FLOAT,
	LIST,
	STRING,

	DIVERT_TARGET,
	VARIABLE_POINTER
}

# ############################################################################ #

# This is a merge of the original Value class and its Value<T> subclass.
class Value extends "res://addons/inkgd/runtime/ink_object.gd":
	# ######################################################################## #
	# IMPORTS
	# ######################################################################## #

	var InkList = load("res://addons/inkgd/runtime/ink_list.gd")

	static func Utils():
		return load("res://addons/inkgd/runtime/extra/utils.gd")

	# ######################################################################## #

	var value # Variant

	var value_type setget , get_value_type # ValueType
	func get_value_type():
		return -1

	var is_truthy setget , get_is_truthy # bool
	func get_is_truthy():
		return false

	# ######################################################################### #

	# (ValueType) -> ValueType
	func cast(new_type):
		pass

	var value_object setget , get_value_object # Variant
	func get_value_object():
		return value

	# ######################################################################## #

	# (Variant) -> Value
	func _init_with(val):
		value = val

	# (Variant) -> Value
	static func create(val):
		# Original code lost precision from double to float.
		# But it's not applicable here.

		if val is bool:
			return BoolValue.new_with(val)
		if val is int:
			return IntValue.new_with(val)
		elif val is float:
			return FloatValue.new_with(val)
		elif val is String:
			return StringValue.new_with(val)
		elif Utils().is_ink_class(val, "InkPath"):
			return DivertTargetValue.new_with(val)
		elif Utils().is_ink_class(val, "InkList"):
			return ListValue.new_with(val)

		return null

	func copy():
		return create(self.value_object)

	# (Ink.ValueType) -> StoryException
	func bad_cast_exception_message(target_class):
		return "Can't cast " + self.value_object + " from " + self.value_type + " to " + target_class

	# () -> String
	func to_string():
		if value is int || value is float || value is String:
			return str(value)
		else:
			return value.to_string()

	# ######################################################################## #
	# GDScript extra methods
	# ######################################################################## #

	func is_class(type):
		return type == "Value" || .is_class(type)

	func get_class():
		return "Value"

	static func new_with(val):
		var value = Value.new()
		value._init_with(val)
		return value

class BoolValue extends Value:
	func get_value_type():
		return ValueType.BOOL

	func get_is_truthy():
		return value

	func _init():
		value = false

	func cast(new_type):
		if new_type == self.value_type:
			return self

		if new_type == ValueType.INT:
			return IntValue.new_with(1 if value else 0)

		if new_type == ValueType.FLOAT:
			return FloatValue.new_with(1.0 if value else 0.0)

		if new_type == ValueType.STRING:
			return StringValue.new_with("true" if value else "false")

		Utils.throw_story_exception(bad_cast_exception_message(new_type))
		return null

	func to_string():
		return "true" if value else "false"

	# ######################################################################## #
	# GDScript extra methods
	# ######################################################################## #

	func is_class(type):
		return type == "BoolValue" || .is_class(type)

	func get_class():
		return "BoolValue"

	static func new_with(val):
		var value = BoolValue.new()
		value._init_with(val)
		return value


class IntValue extends Value:
	func get_value_type():
		return ValueType.INT

	func get_is_truthy():
		return value != 0

	func _init():
		value = 0

	func cast(new_type):
		if new_type == self.value_type:
			return self

		if new_type == ValueType.BOOL:
			return BoolValue.new_with(false if value == 0 else 1)

		if new_type == ValueType.FLOAT:
			return FloatValue.new_with(float(value))

		if new_type == ValueType.STRING:
			return StringValue.new_with(str(value))

		Utils.throw_story_exception(bad_cast_exception_message(new_type))
		return null

	# ######################################################################## #
	# GDScript extra methods
	# ######################################################################## #

	func is_class(type):
		return type == "IntValue" || .is_class(type)

	func get_class():
		return "IntValue"

	static func new_with(val):
		var value = IntValue.new()
		value._init_with(val)
		return value

class FloatValue extends Value:
	func get_value_type():
		return ValueType.FLOAT

	func get_is_truthy():
		return value != 0.0

	func _init():
		value = 0.0

	func cast(new_type):
		if new_type == self.value_type:
			return self

		if new_type == ValueType.BOOL:
			return BoolValue.new_with(false if value == 0 else 1)

		if new_type == ValueType.INT:
			return IntValue.new_with(int(value))

		if new_type == ValueType.STRING:
			return StringValue.new_with(str(value)) # TODO: Check formating

		Utils.throw_story_exception(bad_cast_exception_message(new_type))
		return null

	# ######################################################################## #
	# GDScript extra methods
	# ######################################################################## #

	func is_class(type):
		return type == "FloatValue" || .is_class(type)

	func get_class():
		return "FloatValue"

	static func new_with(val):
		var value = FloatValue.new()
		value._init_with(val)
		return value

class StringValue extends Value:
	func get_value_type():
		return ValueType.STRING

	func get_is_truthy():
		return value.length() > 0

	var is_newline # bool
	var is_inline_whitespace # bool
	var is_non_whitespace setget , get_is_non_whitespace # bool
	func get_is_non_whitespace():
		return !is_newline && !is_inline_whitespace

	func _init():
		value = ""
		self._sanitize_value()

	func _init_with(val):
		._init_with(val)
		self._sanitize_value()

	func cast(new_type):
		if new_type == self.value_type:
			return self

		if new_type == ValueType.INT:
			if self.value_type.is_valid_integer():
				return IntValue.new_with(int(self.value_type))
			else:
				return null

		if new_type == ValueType.FLOAT:
			if self.value_type.is_valid_float():
				return FloatValue.new_with(float(self.value_type))
			else:
				return null

		Utils.throw_story_exception(bad_cast_exception_message(new_type))
		return null

	# ######################################################################## #
	# GDScript extra methods
	# ######################################################################## #

	func is_class(type):
		return type == "StringValue" || .is_class(type)

	func get_class():
		return "StringValue"

	func _sanitize_value():
		is_newline = (self.value == "\n")
		is_inline_whitespace = true

		for c in self.value:
			if c != ' ' && c != "\t":
				is_inline_whitespace = false
				break

	static func new_with(val):
		var value = StringValue.new()
		value._init_with(val)
		return value

class DivertTargetValue extends Value:
	var target_path setget set_target_path, get_target_path # InkPath
	func get_target_path():
		return value
	func set_target_path(value):
		self.value = value

	func get_value_type():
		return ValueType.DIVERT_TARGET

	func get_is_truthy():
		Utils.throw_exception("Shouldn't be checking the truthiness of a divert target")
		return false

	func _init():
		value = null

	func cast(new_type):
		if new_type == self.value_type:
			return self

		Utils.throw_story_exception(bad_cast_exception_message(new_type))
		return null

	func to_string():
		return "DivertTargetValue(" + self.target_path.to_string() + ")"

	# ######################################################################## #
	# GDScript extra methods
	# ######################################################################## #

	func is_class(type):
		return type == "DivertTargetValue" || .is_class(type)

	func get_class():
		return "DivertTargetValue"

	static func new_with(val):
		var value = DivertTargetValue.new()
		value._init_with(val)
		return value

class VariablePointerValue extends Value:
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

	func to_string():
		return "VariablePointerValue(" + self.variable_name + ")"

	func copy():
		return VariablePointerValue.new_with_context(self.variable_name, context_index)

	# ######################################################################## #
	# GDScript extra methods
	# ######################################################################## #

	func is_class(type):
		return type == "VariablePointerValue" || .is_class(type)

	func get_class():
		return "VariablePointerValue"

	static func new_with_context(variable_name, context_index = -1):
		var value = VariablePointerValue.new()
		value._init_with_context(variable_name, context_index)
		return value

class ListValue extends Value:
	func get_value_type():
		return ValueType.LIST

	func get_is_truthy():
		return value.size() > 0

	func cast(new_type):
		if new_type == ValueType.INT:
			var max_item = value.max_item
			if max_item.key.is_null:
				return IntValue.new_with(0)
			else:
				return IntValue.new_with(max_item.value)

		elif new_type == ValueType.FLOAT:
			var max_item = value.max_item
			if max_item.key.is_null:
				return FloatValue.new_with(0.0)
			else:
				return FloatValue.new_with(float(max_item.value))

		elif new_type == ValueType.STRING:
			var max_item = value.max_item
			if max_item.key.is_null:
				return StringValue.new_with("")
			else:
				return StringValue.new_with(max_item.key.to_string())

		if new_type == self.value_type:
			return self

		Utils.throw_story_exception(bad_cast_exception_message(new_type))
		return null

	func _init():
		value = InkList.new()

	func _init_with_list(list):
		value = InkList.new_with_ink_list(list)

	func _init_with_single_item(single_item, single_value):
		value = InkList.new_with_single_item(single_item, single_value)

	# (InkObject, InkObject) -> void
	static func retain_list_origins_for_assignment(old_value, new_value):
		var Utils = load("res://addons/inkgd/runtime/extra/utils.gd")

		var old_list = Utils.as_or_null(old_value, "ListValue")
		var new_list = Utils.as_or_null(new_value, "ListValue")

		if old_list && new_list && new_list.value.size() == 0:
			new_list.value.set_initial_origin_names(old_list.value.origin_names)

	# ######################################################################## #
	# GDScript extra methods
	# ######################################################################## #

	func is_class(type):
		return type == "ListValue" || .is_class(type)

	func get_class():
		return "ListValue"

	static func new_with(list):
		var value = ListValue.new()
		value._init_with_list(list)
		return value

	static func new_with_single_item(single_item, single_value):
		var value = ListValue.new()
		value._init_with_single_item(single_item, single_value)
		return value
