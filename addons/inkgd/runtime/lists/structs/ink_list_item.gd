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

var origin_name : get = get_origin_name
func get_origin_name():
	return _origin_name
var _origin_name = null # String

var item_name : get = get_item_name
func get_item_name():
	return _item_name
var _item_name = null # String

# ############################################################################ #

# (string, string) -> InkListItem
func _init_with_origin_name(origin_name, item_name):
	_origin_name = origin_name
	_item_name = item_name

# (string) -> InkListItem
func _init_with_full_name(full_name):
	var name_parts = full_name.split(".")
	_origin_name = name_parts[0]
	_item_name = name_parts[1]

static func new_null() -> InkListItem:
	return InkListItem.new_with_origin_name(null, null)

# ############################################################################ #

var is_null: bool: get = get_is_null
func get_is_null() -> bool:
	return origin_name == null && item_name == null

# String
var full_name : get = get_full_name
func get_full_name():
	# In C#, concatenating null produce nothing, in GDScript, it appends "Null".
	return (
			(origin_name if origin_name else "?") + "." +
			(item_name if item_name else "")
	)

# ############################################################################ #

# () -> String
func _to_string() -> String:
	return full_name

# (InkObject) -> bool
func equals(obj: InkObject) -> bool:
	if obj is InkListItem:
		var other_item = obj
		return (
			other_item.item_name == item_name &&
			other_item.origin_name == origin_name
		)

	return false

# ############################################################################ #

# (string, string) -> InkListItem
static func new_with_origin_name(origin_name, item_name) -> InkListItem:
	var list_item = InkListItem.new()
	list_item._init_with_origin_name(origin_name, item_name)
	return list_item

# (string) -> InkListItem
static func new_with_full_name(full_name) -> InkListItem:
	var list_item = InkListItem.new()
	list_item._init_with_full_name(full_name)
	return list_item

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
			{ "originName": origin_name, "itemName": item_name }
	)
	return json_print

# Reconstructs a `InkListItem` from the given SerializedInkListItem.
#
# (String) -> InkListItem
static func from_serialized_key(key: String) -> InkListItem:
	var obj = JSON.parse_string(key)
	if !InkListItem._is_like_ink_list_item(obj):
		return InkListItem.new_null()

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
