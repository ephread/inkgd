# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends Reference

class_name InkUtils

# ############################################################################ #
# Imports
# ############################################################################ #

const ValueType = preload("res://addons/inkgd/runtime/values/value_type.gd").ValueType

# ############################################################################ #
# Exceptions
# ############################################################################ #

static func throw_exception(message: String) -> void:
	InkRuntime().handle_exception(message)

static func throw_story_exception(
		message: String,
		use_end_line_number = false,
		metadata = null
) -> void:
	InkRuntime().handle_story_exception(message, use_end_line_number, metadata)

static func throw_argument_exception(message: String) -> void:
	InkRuntime().handle_argument_exception(message)

# ############################################################################ #
# Assertions
# ############################################################################ #

static func __assert__(condition: bool, message = "") -> void:
	if !condition && message != "":
		printerr(message)

	assert(condition)

# ############################################################################ #
# Type Assertion
# ############################################################################ #

static func as_or_null(variant, name_of_class: String):
	if (
			is_ink_class(variant, name_of_class) ||
			name_of_class == "Dictionary" && variant is Dictionary ||
			name_of_class == "Array" && variant is Array
	):
		return variant
	else:
		return null

static func cast(variant, name_of_class: String):
	if is_ink_class(variant, name_of_class):
		return variant
	else:
		push_error(
				"Original implementation threw a RuntimeException here, because of a " +
				"cast issue. Undefined behaviors should be expected."
		)

		assert(false)
		return null

static func as_INamedContent_or_null(variant):
	var properties = variant.get_property_list()

	var has_has_valid_name = false
	var has_name = false

	for property in properties:
		if property["name"] == "has_valid_name":
			has_has_valid_name = true

			if has_has_valid_name && has_name:
				return variant
		elif property["name"] == "name":
			has_name = true

			if has_has_valid_name && has_name:
				return variant

	return null

static func is_ink_class(object: Object, name_of_class: String) -> bool:
	return (object is Object) && object.is_class(name_of_class)

static func are_of_same_type(object1: Object, object2: Object) -> bool:
	if (object1 is Object) && (object2 is Object):
		return object1.get_class() == object2.get_class()

	return typeof(object1) == typeof(object2)

static func value_type_name(value_type: int) -> String:
	match value_type:
		ValueType.BOOL: return "Boolean"

		ValueType.INT: return "Int"
		ValueType.FLOAT: return "Float"
		ValueType.LIST: return "List"
		ValueType.STRING: return "String"

		ValueType.DIVERT_TARGET: return "Divert Target"
		ValueType.VARIABLE_POINTER: return "Variable Pointer"

		_: return "unknown"

static func typename_of(variant) -> String:
	match typeof(variant):
		TYPE_NIL: return "null"
		TYPE_BOOL: return "bool"
		TYPE_INT: return "int"
		TYPE_REAL: return "float"
		TYPE_STRING: return "String"
		TYPE_VECTOR2: return "Vector2"
		TYPE_RECT2: return "Rect2"
		TYPE_VECTOR3: return "Vector3"
		TYPE_TRANSFORM2D: return "Transform2D"
		TYPE_PLANE: return "Plane"
		TYPE_QUAT: return "Quat"
		TYPE_AABB: return "AABB"
		TYPE_BASIS: return "Basis"
		TYPE_TRANSFORM: return "Transform"
		TYPE_COLOR: return "Color"
		TYPE_NODE_PATH: return "NodePath"
		TYPE_RID: return "RID"
		TYPE_OBJECT: return variant.get_class()
		TYPE_DICTIONARY: return "Dictionary"
		TYPE_ARRAY: return "Array"
		TYPE_RAW_ARRAY: return "PoolByteArray"
		TYPE_INT_ARRAY: return "PoolIntArray"
		TYPE_REAL_ARRAY: return "PoolRealArray"
		TYPE_STRING_ARRAY: return "PoolStringArray"
		TYPE_VECTOR2_ARRAY: return "PoolVector2Array"
		TYPE_VECTOR3_ARRAY: return "PoolVector3Array"
		TYPE_COLOR_ARRAY: return "PoolColorArray"
		_: return "unknown"

# ############################################################################ #
# String Utils
# ############################################################################ #

static func trim(string_to_trim: String, characters = []) -> String:
	if characters.empty():
		return string_to_trim.strip_edges()

	var length = string_to_trim.length()
	var beginning = 0
	var end = length

	var i = 0
	while i < string_to_trim.length():
		var character = string_to_trim[i]
		if characters.find(character) != -1:
			beginning += 1
		else:
			break

		i += 1

	i = string_to_trim.length() - 1
	while i >= 0:
		var character = string_to_trim[i]
		if characters.find(character) != -1:
			end -= 1
		else:
			break

		i -= 1

	if beginning == 0 && end == length:
		return string_to_trim

	return string_to_trim.substr(beginning, end - beginning)

# ############################################################################ #
# Array Utils
# ############################################################################ #

static func join(joiner: String, array: Array) -> String:
	var joined_string = ""

	var i = 0
	for element in array:
		var element_string
		if is_ink_class(element, "InkBase"):
			element_string = element._to_string()
		else:
			element_string = str(element)

		joined_string += element_string

		if i >= 0 && i < array.size() - 1:
			joined_string += joiner

		i += 1

	return joined_string

static func get_range(array: Array, index: int, count: int) -> Array:
	if !(index >= 0 && index < array.size()):
		printerr("get_range: index (%d) is out of bounds." % index)
		return array.duplicate()

	if index + count > array.size():
		printerr("get_range: [index (%d) + count (%d)] is out of bounds." % [index, count])
		return array.duplicate()

	var new_array = []
	var i = index
	var c = 0

	while (c < count):
		new_array.append(array[i + c])
		c += 1

	return new_array

static func remove_range(array: Array, index: int, count: int) -> void:
	if !(index >= 0 && index < array.size()):
		printerr("get_range: index (%d) is out of bounds." % index)
		return

	if index + count > array.size():
		printerr("get_range: [index (%d) + count (%d)] is out of bounds." % [index, count])
		return

	var i = index
	var c = 0

	while (c < count):
		array.remove(i)
		c += 1

static func array_equal(a1: Array, a2: Array, use_equals = false) -> bool:
	if a1.size() != a2.size():
		return false

	var i = 0
	while (i < a1.size()):
		var first_element = a1[i]
		var second_element = a2[i]

		if use_equals:
			if !first_element.equals(second_element):
				return false
			else:
				i += 1
				continue
		else:
			if first_element != second_element:
				return false
			else:
				i += 1
				continue

		i += 1

	return true

# ############################################################################ #

static func InkRuntime():
	return Engine.get_main_loop().root.get_node("__InkRuntime")
