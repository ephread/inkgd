# warning-ignore-all:shadowed_variable
# warning-ignore-all:unused_class_variable
# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2023 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends InkObject

class_name InkListDefinitionsOrigin

# ############################################################################ #

# Array<InkListDefinition>
var lists: Array: get = get_lists
func get_lists() -> Array:
	var list_of_lists = []
	for named_list_key in _lists:
		list_of_lists.append(_lists[named_list_key])

	return list_of_lists

# ############################################################################ #

# (Array<InkListDefinition>) -> InkListDefinitionOrigin
func _init(lists: Array):
	_lists = {} # Dictionary<String, InkListDefinition>
	_all_unambiguous_list_value_cache = {} # Dictionary<String, InkListValue>()

	for list in lists:
		_lists[list.name] = list

		for item_with_value_key in list.items:
			var item = InkListItem.from_serialized_key(item_with_value_key)
			var val = list.items[item_with_value_key]
			var list_value = InkListValue.new_with_single_item(item, val)

			_all_unambiguous_list_value_cache[item.item_name] = list_value
			_all_unambiguous_list_value_cache[item.full_name] = list_value


# ############################################################################ #

# (String) -> { result: String, exists: bool }
func try_list_get_definition(name: String) -> InkTryGetResult:
	if name == null:
		return InkTryGetResult.new(false, null)

	var definition = _lists.get(name)
	if !definition:
		return InkTryGetResult.new(false, null)

	return InkTryGetResult.new(true, definition)

func find_single_item_list_with_name(name: String) -> InkListValue:
	if _all_unambiguous_list_value_cache.has(name):
		return _all_unambiguous_list_value_cache[name]

	return null

# ############################################################################ #

var _lists: Dictionary # Dictionary<String, InkListDefinition>
var _all_unambiguous_list_value_cache: Dictionary # Dictionary<String, InkListValue>

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_ink_class(type: String) -> bool:
	return type == "InkListDefinitionsOrigin" || super.is_ink_class(type)

func get_ink_class() -> String:
	return "InkListDefinitionsOrigin"
