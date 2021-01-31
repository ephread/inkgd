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

extends "res://addons/inkgd/runtime/ink_object.gd"

# ############################################################################ #
# Imports
# ############################################################################ #

var TryGetResult = preload("res://addons/inkgd/runtime/extra/try_get_result.gd")
var InkListItem = load("res://addons/inkgd/runtime/ink_list_item.gd")

# ############################################################################ #

var name setget , get_name # String
func get_name():
	return _name

var items setget , get_items # Dictionary<InkListItem, int>
							 # Note: InkListItem should be serialized into a String.
func get_items():
	if _items == null:
		_items = {}
		for item_name_and_value_key in _item_name_to_values:
			var item = InkListItem.new_with_origin_name(self.name, item_name_and_value_key)
			_items[item.serialized()] = _item_name_to_values[item_name_and_value_key]

	return _items
var _items # Dictionary<InkListItem, int>
		   # Note: InkListItem should be serialized into a String.

# ############################################################################ #

# (InkListItem) -> int
func value_for_item(item):
	if (_item_name_to_values.has(item.item_name)):
		var intVal = _item_name_to_values[item.item_name]
		return intVal
	else:
		return 0

# (InkListItem) -> bool
func contains_item(item):
	if item.origin_name != self.name:
		return false

	return _item_name_to_values.has(item.item_name)

# (String) -> bool
func contains_item_with_name(item_name):
	return _item_name_to_values.has(item_name)

# (int) -> { result: InkListItem, exists: bool }
func try_get_item_with_value(val):
	for named_item_key in _item_name_to_values:
		if (_item_name_to_values[named_item_key] == val):
			return TryGetResult.new(true, InkListItem.new_with_origin_name(self.name, named_item_key))

	return TryGetResult.new(false, InkListItem.null())

# (int) -> { result: InkListItem, exists: bool }
func try_get_value_for_item(item):
	if !item.item_name:
		return TryGetResult.new(false, 0)

	var value = _item_name_to_values.get(item.item_name)

	if (!value):
		TryGetResult.new(false, 0)

	return TryGetResult.new(true, value)

# (String name, Dictionary<String, int>) -> InkListDefinition
func _init(name, items):
	_name = name
	_item_name_to_values = items

var _name # String
var _item_name_to_values # Dictionary<String, int>

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type):
	return type == "InkListDefinition" || .is_class(type)

func get_class():
	return "InkListDefinition"
