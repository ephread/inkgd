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
var Ink = load("res://addons/inkgd/runtime/value.gd")
var InkListItem = load("res://addons/inkgd/runtime/ink_list_item.gd")

# ############################################################################ #

var lists setget , get_lists # Array<InkListDefinition>
func get_lists():
	var list_of_lists = [] # Array<InkListDefinition>
	for named_list_key in _lists:
		list_of_lists.append(_lists[named_list_key])

	return list_of_lists

# ############################################################################ #

# (Array<InkListDefinition>) -> InkListDefinitionOrigin
func _init(lists):
	_lists = {} # Dictionary<String, InkListDefinition>
	_all_unambiguous_list_value_cache = {} # Dictionary<String, Ink.ListValue>()

	for list in lists:
		_lists[list.name] = list

		for item_with_value_key in list.items:
			var item = InkListItem.from_serialized_key(item_with_value_key)
			var val = list.items[item_with_value_key]
			var list_value = Ink.ListValue.new_with_single_item(item, val)

			_all_unambiguous_list_value_cache[item.item_name] = list_value
			_all_unambiguous_list_value_cache[item.full_name] = list_value


# ############################################################################ #

# (String) -> { result: String, exists: bool }
func try_list_get_definition(name):
	if name == null:
		return TryGetResult.new(false, null)

	var definition = _lists.get(name)
	if !definition:
		return TryGetResult.new(false, null)

	return TryGetResult.new(true, definition)

# (String) -> Ink.ListValue
func find_single_item_list_with_name(name):
	if _all_unambiguous_list_value_cache.has(name):
		return _all_unambiguous_list_value_cache[name]

	return null

# ############################################################################ #

var _lists # Dictionary<String, InkListDefinition>
var _all_unambiguous_list_value_cache # Dictionary<String, Ink.ListValue>

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type):
	return type == "InkListDefinitionsOrigin" || .is_class(type)

func get_class():
	return "InkListDefinitionsOrigin"
