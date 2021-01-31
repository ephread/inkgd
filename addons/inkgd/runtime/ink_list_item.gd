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

# ############################################################################ #
# !! VALUE TYPE
# ############################################################################ #

extends "res://addons/inkgd/runtime/ink_object.gd"

# ############################################################################ #
# Self-reference
# ############################################################################ #

static func InkListItem():
	return load("res://addons/inkgd/runtime/ink_list_item.gd")

# ############################################################################ #

var origin_name = null # String
var item_name = null # String

# ############################################################################ #

# (string, string) -> InkListItem
func _init_with_origin_name(origin_name, item_name):
	self.origin_name = origin_name
	self.item_name = item_name

# (string) -> InkListItem
func _init_with_full_name(full_name):
	var name_parts = full_name.split(".")
	self.origin_name = name_parts[0]
	self.item_name = name_parts[1]

# () -> InkListItem
static func null():
	return InkListItem().new_with_origin_name(null, null)

# ############################################################################ #

var is_null setget , get_is_null # bool
func get_is_null():
	return self.origin_name == null && self.item_name == null

var full_name setget , get_full_name # String
func get_full_name():
	# In C#, concatenating null produce nothing, in GDScript, it appends "Null".
	return (self.origin_name if self.origin_name else "?") + "." + str(self.item_name if self.item_name else "")

# ############################################################################ #

# () -> String
func to_string():
	return self.full_name

# (InkObject) -> bool
func equals(obj):
	if obj.is_class("InkListItem"):
		var other_item = obj
		return other_item.item_name == self.item_name && self.other_item.origin_name == self.origin_name

	return false

# ############################################################################ #

# (string, string) -> InkListItem
static func new_with_origin_name(origin_name, item_name):
	var list_item = InkListItem().new()
	list_item._init_with_origin_name(origin_name, item_name)
	return list_item

# (string) -> InkListItem
static func new_with_full_name(full_name):
	var list_item = InkListItem().new()
	list_item._init_with_full_name(full_name)
	return list_item

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type):
	return type == "InkListItem" || .is_class(type)

func get_class():
	return "InkListItem"

# ############################################################################ #
# These methods did not exist in the original C# code. Their purpose is to
# make `InkListItem` mimic the value-type semantics of the original
# struct, as well as offering a serialization mechanism to use `InkListItem`
# as keys in dictionaries.

# Create a shallow copy of the InkListItem (use it when assigning to mimic
# a value-type).
#
# () -> InkListItem
func duplicate():
	return InkListItem().init_with_origin_name(origin_name, item_name)

# Returns a `SerializedInkListItem` representing the current
# instance. The result is intended to be used as a key inside a Map.
#
# () -> String
func serialized():
	# We are simply using a JSON representation as a value-typed key.
	var json_print = JSON.print({"originName": origin_name, "itemName": item_name})
	return json_print

# Reconstructs a `InkListItem` from the given SerializedInkListItem.
#
# (String) -> InkListItem
static func from_serialized_key(key):
	var obj = JSON.parse(key).result
	if !InkListItem()._is_like_ink_list_item(obj):
		return InkListItem().null()

	return InkListItem().new_with_origin_name(obj["originName"], obj["itemName"])

# Determines whether the given item is sufficiently `InkListItem`-like
# to be used as a template when reconstructing the InkListItem.
#
# (Variant) -> bool
static func _is_like_ink_list_item(item):
	if !(item is Dictionary):
		return false

	if !(item.has("originName") && item.has("itemName")):
		return false

	if !(item["originName"] is String):
		return false

	if !(item["itemName"] is String):
		return false

	return true
