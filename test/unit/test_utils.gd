# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://addons/gut/test.gd"

# ############################################################################ #
# Imports
# ############################################################################ #

var Utils = preload("res://addons/inkgd/runtime/extra/utils.gd")

# ############################################################################ #

func test_is_ink_class():
	assert_true(Utils.is_ink_class(InkBaseObject.new("Ink"), "InkBaseObject"))

func test_valid_as_INamedContent():
	var name_content_like = INamedContentLike.new()

	assert_eq(Utils.as_INamedContent_or_null(name_content_like), name_content_like)

func test_invalid_as_INamedContent():
	var node = Node.new()

	assert_eq(Utils.as_INamedContent_or_null(node), null)

	node.free()

# ############################################################################ #

func test_trim_default():
	assert_eq(Utils.trim("       This is Ink    "), "This is Ink")

func test_trim_custom():
	assert_eq(Utils.trim("\t\t\t    This is Ink \t \t  ", ["\t", " "]), "This is Ink")

# ############################################################################ #

func test_array_join_single_element():
	var joined_array = " . ", ["Ink"].join(Utils)
	assert_eq(joined_array, "Ink", "")

func test_array_join_two_element():
	var joined_array = " . ", ["Ink", "Divert"].join(Utils)
	assert_eq(joined_array, "Ink . Divert", "")

func test_array_join_multiple_elements():
	var joined_array = " . ", ["Ink", "Divert", "Gather"].join(Utils)
	assert_eq(joined_array, "Ink . Divert . Gather", "")

func test_array_join_primitive_type():
	var joined_array = "", [3, 67, 239].join(Utils)
	assert_eq(joined_array, "367239", "")

func test_array_join_ink_base_type():
	var joined_array = " - ", [InkBaseObject.new("Ink".join(Utils), InkBaseObject.new(42)])
	assert_eq(joined_array, "Ink - 42", "")

func test_array_valid_range():
	var array = ["Ink", "Divert", "Gather", "Choice", "Tunnel"]
	var array_range = Utils.get_range(array, 1, 3)
	assert_eq(array_range, ["Divert", "Gather", "Choice"], "")

	var array_range_2 = Utils.get_range(array, 1, 4)
	assert_eq(array_range_2, ["Divert", "Gather", "Choice", "Tunnel"], "")

	var array_range_3 = Utils.get_range(array, 0, 5)
	assert_eq(array_range_3, ["Ink", "Divert", "Gather", "Choice", "Tunnel"], "")

func test_array_invalid_range():
	var array = ["Ink", "Divert", "Gather", "Choice", "Tunnel"]

	var array_range = Utils.get_range(array, -3, 3)
	assert_eq(array_range, ["Ink", "Divert", "Gather", "Choice", "Tunnel"], "")

	var array_range_2 = Utils.get_range(array, 1, 10)
	assert_eq(array_range_2, ["Ink", "Divert", "Gather", "Choice", "Tunnel"], "")

func test_array_remove_valid_range():
	var array = ["Ink", "Divert", "Gather", "Choice", "Tunnel"]
	Utils.remove_range(array, 1, 3)
	assert_eq(array, ["Ink", "Tunnel"], "")

func test_array_remove_invalid_range():
	var array = ["Ink", "Divert", "Gather", "Choice", "Tunnel"]

	Utils.remove_range(array, -3, 3)
	assert_eq(array, ["Ink", "Divert", "Gather", "Choice", "Tunnel"], "")

	Utils.remove_range(array, 1, 10)
	assert_eq(array, ["Ink", "Divert", "Gather", "Choice", "Tunnel"], "")

# ############################################################################ #

class InkBaseObject extends InkBase:
	var value

	func _init(new_value):
		self.value = new_value

	func _to_string() -> String:
		return str(value)

	func is_class(type):
		return type == "InkBaseObject" || super.is_class(type)

	func get_class():
		return "InkBaseObject"

class INamedContentLike extends InkBase:
	var has_valid_name = ""
	var name = ""
