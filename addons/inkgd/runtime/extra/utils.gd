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
# Exceptions
# ############################################################################ #

static func throw_exception(message):
	var exception_message = str("Story execution will stop: ", message)
	_schedule_story_for_interruption_with_error(exception_message)

static func throw_story_exception(message):
	var exception_message = str("Story execution will stop: ", message)
	_schedule_story_for_interruption_with_error(exception_message)

static func throw_argument_exception(message):
	var exception_message = str("Story execution will stop: ", message)
	_schedule_story_for_interruption_with_error(exception_message)

static func _schedule_story_for_interruption_with_error(message):
	var InkRuntime = InkRuntime()

	InkRuntime.should_interrupt = true

	if InkRuntime.should_pause_execution_on_runtime_error && OS.is_debug_build():
		assert(false, message)
	else:
		push_error(message)
		printerr(message)

	print_stack_trace()

static func print_stack_trace():
	print("Stacktrace:")
	var i = 1
	for stack_element in get_stack():
		if i <= 3:
			i += 1
			continue

		print(str(
			"    ", (i - 3), " ", stack_element["source"], ":",
			stack_element["line"], "  (", stack_element["function"] ,")"
		))

		i += 1

# ############################################################################ #
# Assertions
# ############################################################################ #

static func assert(condition, message = ""):
	if !condition && message != "":
		printerr(message)

	assert(condition)

# ############################################################################ #
# Type Assertion
# ############################################################################ #

static func as_or_null(variant, name_of_class):
	if (is_ink_class(variant, name_of_class) ||
		name_of_class == "Dictionary" && variant is Dictionary ||
		name_of_class == "Array" && variant is Array
	):
		return variant
	else:
		return null

static func cast(variant, name_of_class):
	if is_ink_class(variant, name_of_class):
		return variant
	else:
		push_error(str(
			"Original implementation threw a RuntimeException here, because of a ",
			"cast issue. Undefined behaviors should be expected."
		))

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

static func is_ink_class(object, name_of_class):
	return (object is Object) && object.is_class(name_of_class)

static func are_of_same_type(object1, object2):
	if (object1 is Object) && (object2 is Object):
		return object1.get_class() == object2.get_class()

	return typeof(object1) == typeof(object2)

static func typename_of(variant):
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

static func trim(string_to_trim, characters = null):
	if characters == null:
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

static func join(joiner, array):
	var joined_string = ""

	var i = 0
	for element in array:
		var element_string
		if is_ink_class(element, "InkBase"):
			element_string = element.to_string()
		else:
			element_string = str(element)

		joined_string += element_string

		if i >= 0 && i < array.size() - 1:
			joined_string += joiner

		i += 1

	return joined_string

static func get_range(array, index, count):
	if !(index >= 0 && index < array.size()):
		printerr("get_range: index (" + str(index) + ") is out of bounds.")
		return array.duplicate()

	if index + count > array.size():
		printerr("get_range: [index (" + str(index) + ") + count (" + str(count) + ")] is out of bounds.")
		return array.duplicate()

	var new_array = []
	var i = index
	var c = 0

	while (c < count):
		new_array.append(array[i + c])
		c += 1

	return new_array

static func remove_range(array, index, count):
	if !(index >= 0 && index < array.size()):
		printerr("get_range: index (" + str(index) + ") is out of bounds.")
		return

	if index + count > array.size():
		printerr("get_range: [index (" + str(index) + ") + count (" + str(count) + ")] is out of bounds.")
		return

	var i = index
	var c = 0

	while (c < count):
		array.remove(i)
		c += 1

static func array_equal(a1, a2, use_equals = false):
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
