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

# ############################################################################ #
# !! VALUE TYPE
# ############################################################################ #

extends InkObject

class_name InkListItem

# ############################################################################ #

# Originally these were simple variables, but they are turned into properties to
# make the object "immutable". That way it can be passed around without being
# duplicated.

var origin_name:
	get: return _origin_name
var _origin_name = null # String

var item_name:
	get: return _item_name
var _item_name = null # String

# ############################################################################ #

# (string, string) -> InkListItem
@warning_ignore("shadowed_variable")
func _init_with_origin_name(origin_name, item_name):
	self._origin_name = origin_name
	self._item_name = item_name


# (string) -> InkListItem
@warning_ignore("shadowed_variable")
func _init_with_full_name(full_name):
	var name_parts = full_name.split(".")
	self._origin_name = name_parts[0]
	self._item_name = name_parts[1]


static var null_item: InkListItem:
	get: return InkListItem.new_with_origin_name(null, null)

# ############################################################################ #

var is_null: bool:
	get:
		return self.origin_name == null && self.item_name == null

# String
var full_name:
	get:
		# In C#, concatenating null produce nothing, in GDScript, it appends "Null".
		return (
				(self.origin_name if self.origin_name else "?") + "." +
				(self.item_name if self.item_name else "")
		)

# ############################################################################ #

# () -> String
func _to_string() -> String:
	return self.full_name


# (InkObject) -> bool
func equals(obj: InkBase) -> bool:
	if obj.is_ink_class("InkListItem"):
		var other_item = obj
		return (
			other_item.item_name == self.item_name &&
			self.other_item.origin_name == self.origin_name
		)

	return false


# ############################################################################ #

# (string, string) -> InkListItem
@warning_ignore("shadowed_variable")
static func new_with_origin_name(origin_name, item_name) -> InkListItem:
	var list_item = InkListItem.new()
	list_item._init_with_origin_name(origin_name, item_name)
	return list_item


# (string) -> InkListItem
@warning_ignore("shadowed_variable")
static func new_with_full_name(full_name) -> InkListItem:
	var list_item = InkListItem.new()
	list_item._init_with_full_name(full_name)
	return list_item


# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_ink_class(type: String) -> bool:
	return type == "InkListItem" || super.is_ink_class(type)


func get_ink_class() -> String:
	return "InkListItem"

# ############################################################################ #
# These methods did not exist in the original C# code. Their purpose is to
# make `InkListItem` mimic the value-type semantics of the original
# struct, as well as offering a serialization mechanism to use `InkListItem`
# as keys in dictionaries.

# Returns a `SerializedInkListItem` representing the current
# instance. The result is intended to be used as a key inside a Map.
func serialized() -> String:
	# We are simply using a JSON representation as a value-typed key.
	var json_print = JSON.stringify(
			{ "originName": self.origin_name, "itemName": self.item_name }
	)
	return json_print

# Reconstructs a `InkListItem` from the given SerializedInkListItem.
#
# (String) -> InkListItem
static func from_serialized_key(key: String) -> InkListItem:
	var obj = JSON.parse_string(key)
	if !InkListItem._is_like_ink_list_item(obj):
		return InkListItem.null_item

	return InkListItem.new_with_origin_name(obj["originName"], obj["itemName"])

# Determines whether the given item is sufficiently `InkListItem`-like
# to be used as a template when reconstructing the InkListItem.
#
# (Variant) -> bool
static func _is_like_ink_list_item(item) -> bool:
	if !(item is Dictionary):
		return false

	if !(item.has("originName") && item.has("itemName")):
		return false

	if !(item["originName"] is String):
		return false

	if !(item["itemName"] is String):
		return false

	return true
