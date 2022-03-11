# warning-ignore-all:unused_class_variable
# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends InkObject

class_name InkList

# ############################################################################ #
# Imports
# ############################################################################ #

var InkListItem := preload("res://addons/inkgd/runtime/lists/structs/ink_list_item.gd") as GDScript
var InkKeyValuePair := preload("res://addons/inkgd/runtime/extra/key_value_pair.gd") as GDScript

static func InkList() -> GDScript:
	return load("res://addons/inkgd/runtime/lists/ink_list.gd") as GDScript

static func Utils() -> GDScript:
	return load("res://addons/inkgd/runtime/extra/utils.gd") as GDScript

# ############################################################################ #

# (Dictionary<InkItem, int>, Array<String>, Array<InkListDefinition>)
func _init_from_csharp(items: Dictionary, origin_names: Array, origins: Array):
	_dictionary = items
	_origin_names = origin_names
	self.origins = origins

# (InkList) -> InkList
func _init_with_ink_list(other_list: InkList):
	_dictionary = other_list._dictionary.duplicate()
	_origin_names = other_list.origin_names
	if other_list.origins != null:
		self.origins = other_list.origins.duplicate()

# (string, Story) -> InkList
func _init_with_origin(single_origin_list_name: String, origin_story):
	set_initial_origin_name(single_origin_list_name)

	var def: InkTryGetResult = origin_story.list_definitions.try_list_get_definition(single_origin_list_name)
	if def.exists:
		origins = [def.result]
	else:
		Utils.throw_exception(
				"InkList origin could not be found in story when constructing new list: %s" \
				% single_origin_list_name
		)

# (InkListItem, int) -> InkList
func _init_with_single_item(single_item: InkListItem, single_value: int):
	set_item(single_item, single_value)

# (string, Story) -> InkList
static func from_string(my_list_item: String, origin_story) -> InkList:
	var list_value: InkListValue = origin_story.list_definitions.find_single_item_list_with_name(my_list_item)
	if list_value:
		return InkList().new_with_ink_list(list_value.value)
	else:
		Utils().throw_exception(
				"Could not find the InkListItem from the string '%s' to create an InkList because " +
				"it doesn't exist in the original list definition in ink." % my_list_item
		)
		return null

func add_item(item: InkListItem) -> void:
	if item.origin_name == null:
		add_item(item.item_name)
		return

	for origin in origins:
		if origin.name == item.origin_name:
			var int_val: InkTryGetResult = origin.try_get_value_for_item(item)
			if int_val.exists:
				set_item(item, int_val.result)
				return
			else:
				Utils.throw_exception(
						"Could not add the item '%s' to this list because it doesn't exist in the " +
						"original list definition in ink." % item._to_string()
				)
				return

	Utils.throw_exception(
			"Failed to add item to list because the item was from a new list definition that " +
			"wasn't previously known to this list. Only items from previously known lists can " +
			"be used, so that the int value can be found."
	)

func add_item_by_string(item_name: String) -> void:
	var found_list_def: InkListDefinition = null

	for origin in origins:
		if origin.contains_item_with_name(item_name):
			if found_list_def != null:
				Utils.throw_exception(
						"Could not add the item " + item_name + " to this list because it could " +
						"come from either " + origin.name + " or " + found_list_def.name
				)
				return
			else:
				found_list_def = origin

	if found_list_def == null:
		Utils.throw_exception(
				"Could not add the item " + item_name + " to this list because it isn't known " +
				"to any list definitions previously associated with this list."
		)
		return

	var item = InkListItem.new_with_origin_name(found_list_def.name, item_name)
	var item_val: int = found_list_def.value_for_item(item)
	set_item(item, item_val)

func contains_item_named(item_name: String) -> bool:
	for item_key in keys():
		if item_key.item_name == item_name:
			return true

	return false

# Array<ListDefinition>
var origins = null
var origin_of_max_item: InkListDefinition setget , get_origin_of_max_item
func get_origin_of_max_item() -> InkListDefinition:
	if origins == null:
		return null

	var max_origin_name = self.max_item.key.origin_name
	for origin in origins:
		if origin.name == max_origin_name:
			return origin

	return null

# Array<String>
var origin_names setget , get_origin_names
func get_origin_names():
	if self.size() > 0:
		if _origin_names == null && self.size() > 0:
			_origin_names = []
		else:
			_origin_names.clear()

		for item_key in keys():
			_origin_names.append(item_key.origin_name)

	return _origin_names

var _origin_names = null # Array<String>

func set_initial_origin_name(initial_origin_name: String) -> void:
	_origin_names = [ initial_origin_name ]

# (Array<String>) -> void
func set_initial_origin_names(initial_origin_names) -> void:
	if initial_origin_names == null:
		_origin_names = null
	else:
		_origin_names = initial_origin_names.duplicate()

# TODO: Make inspectable
var max_item: InkKeyValuePair setget , get_max_item # InkKeyValuePair<InkListItem, int>
func get_max_item() -> InkKeyValuePair:
	var _max_item: InkKeyValuePair = InkKeyValuePair.new_with_key_value(InkListItem.null(), 0)
	for k in keys():
		if (_max_item.key.is_null || get_item(k) > _max_item.value):
			_max_item = InkKeyValuePair.new_with_key_value(k, get_item(k))

	return _max_item

# TODO: Make inspectable
var min_item: InkKeyValuePair setget , get_min_item # InkKeyValuePair<InkListItem, int>
func get_min_item() -> InkKeyValuePair:
	var _min_item: InkKeyValuePair = InkKeyValuePair.new_with_key_value(InkListItem.null(), 0)
	for k in keys():
		if (_min_item.key.is_null || get_item(k) < _min_item.value):
			_min_item = InkKeyValuePair.new_with_key_value(k, get_item(k))

	return _min_item

# TODO: Make inspectable
var inverse: InkList setget , get_inverse
func get_inverse() -> InkList:
	var list: InkList = InkList().new()
	if origins != null:
		for origin in origins:
			for serialized_item_key in origin.items:
				if !_dictionary.has(serialized_item_key):
					list._dictionary[serialized_item_key] = origin.items[serialized_item_key]

	return list

# TODO: Make inspectable
var all: InkList setget , get_all
func get_all() -> InkList:
	var list: InkList = InkList().new()
	if origins != null:
		for origin in origins:
			for serialized_item_key in origin.items:
				list._dictionary[serialized_item_key] = origin.items[serialized_item_key]

	return list

# TODO: Make inspectable
func union(other_list: InkList) -> InkList:
	var union: InkList = InkList().new_with_ink_list(self)
	for key in other_list._dictionary:
		union._dictionary[key] = other_list._dictionary[key]
	return union

# TODO: Make inspectable
func intersection(other_list: InkList) -> InkList:
	var intersection: InkList = InkList().new()
	for key in other_list._dictionary:
		if self._dictionary.has(key):
			intersection._dictionary[key] = other_list._dictionary[key]
	return intersection

# TODO: Make inspectable
func without(list_to_remove: InkList) -> InkList:
	var result = InkList().new_with_ink_list(self)
	for key in list_to_remove._dictionary:
		result._dictionary.erase(key)
	return result

func contains(other_list: InkList) -> bool:
	for key in other_list._dictionary:
		if !_dictionary.has(key):
			return false

	return true

func greater_than(other_list: InkList) -> bool:
	if size() == 0:
		return false
	if other_list.size() == 0:
		return true

	return self.min_item.value > other_list.max_item.value

func greater_than_or_equals(other_list: InkList) -> bool:
	if size() == 0:
		return false
	if other_list.size() == 0:
		return true

	return (
			self.min_item.value >= other_list.min_item.value &&
			self.max_item.value >= other_list.max_item.value
	)

func less_than(other_list: InkList) -> bool:
	if other_list.size() == 0:
		return false
	if size() == 0:
		return true

	return self.max_item.value < other_list.min_item.value

func less_than_or_equals(other_list: InkList) -> bool:
	if other_list.size() == 0:
		return false
	if size() == 0:
		return true

	return (
			self.max_item.value <= other_list.max_item.value &&
			self.min_item.value <= other_list.min_item.value
	)

func max_as_list() -> InkList:
	if size() > 0:
		var _max_item: InkKeyValuePair = self.max_item
		return InkList().new_with_single_item(_max_item.key, _max_item.value)
	else:
		return InkList().new()

func min_as_list() -> InkList:
	if size() > 0:
		var _min_item: InkKeyValuePair = self.min_item
		return InkList().new_with_single_item(_min_item.key, _min_item.value)
	else:
		return InkList().new()

# (Variant, Variant) -> InkList
func list_with_sub_range(min_bound, max_bound) -> InkList:
	if size() == 0:
		return InkList().new()

	var ordered: Array = self.ordered_items

	var min_value: int = 0
	var max_value: int = 9_223_372_036_854_775_807 # MAX_INT

	if min_bound is int:
		min_value = min_bound
	else:
		if min_bound.is_class("InkList") && min_bound.size() > 0:
			min_value = min_bound.min_item.value

	if max_bound is int:
		max_value = max_bound
	else:
		if min_bound.is_class("InkList") && min_bound.size() > 0:
			max_value = max_bound.max_item.value

	var sub_list = InkList().new()
	sub_list.set_initial_origin_names(self.origin_names)

	for item in ordered:
		if item.value >= min_value && item.value <= max_value:
			sub_list.set_item(item.key, item.value)

	return sub_list

func equals(other: InkList) -> bool:
	var other_raw_list: InkList = other
	# Simple test to make sure the object is of the right type.
	if !(other_raw_list is Object):
		return false
	if !(other_raw_list.is_class("InkList")):
		return false

	if other_raw_list.size() != self.size():
		return false

	for key in keys():
		if (!other_raw_list.has_item(key)):
			return false

	return true

var ordered_items: Array setget , get_ordered_items # Array<InkKeyValuePair<InkListItem, int>>
func get_ordered_items():
	var ordered: Array = []
	for key in keys():
		ordered.append(InkKeyValuePair.new_with_key_value(key, get_item(key)))

	ordered.sort_custom(KeyValueInkListItemSorter, "sort")
	return ordered

func _to_string() -> String:
	var ordered: Array = self.ordered_items

	var description: String = ""
	var i: int = 0
	while (i < ordered.size()):
		if i > 0:
			description += ", "

		var item = ordered[i].key
		description += item.item_name
		i += 1

	return description

static func new_with_dictionary(other_dictionary: Dictionary) -> InkList:
	var ink_list: InkList = InkList().new()
	ink_list._init_with_dictionary(other_dictionary)
	return ink_list

static func new_with_ink_list(other_list: InkList) -> InkList:
	var ink_list: InkList = InkList().new()
	ink_list._init_with_ink_list(other_list)
	return ink_list

static func new_with_origin(single_origin_list_name: String, origin_story) -> InkList:
	var ink_list: InkList = InkList().new()
	ink_list._init_with_origin(single_origin_list_name, origin_story)
	return ink_list

static func new_with_single_item(single_item: InkListItem, single_value: int) -> InkList:
	var ink_list: InkList = InkList().new()
	ink_list._init_with_single_item(single_item, single_value)
	return ink_list

class KeyValueInkListItemSorter:
	static func sort(a, b):
		if a.value == b.value:
			return a.key.origin_name.nocasecmp_to(b.key.origin_name) <= 0
		else:
			return a.value <= b.value

# ############################################################################ #
# Originally, this class would inherit Dictionary. This isn't possible in
# GDScript. Instead, this class will encapsulate a dictionary and forward
# needed calls.
# ############################################################################ #

var _dictionary: Dictionary = {}

# Name set_item instead of set to prevent shadowing 'Object.set'.
func set_item(key: InkListItem, value: int) -> void:
	_dictionary[key.serialized()] = value

# Name get_item instead of get to prevent shadowing 'Object.get'.
func get_item(key: InkListItem, default = null):
	return _dictionary.get(key.serialized(), default)

# Name has_item instead of has to prevent shadowing 'Object.get'.
func has_item(key: InkListItem) -> bool:
	return _dictionary.has(key.serialized())

func keys() -> Array:
	var deserialized_keys = []
	for key in _dictionary.keys():
		deserialized_keys.append(InkListItem.from_serialized_key(key))

	return deserialized_keys

func size() -> int:
	return _dictionary.size()

# ############################################################################ #
# Additional methods
# ############################################################################ #

func set_raw(key: String, value: int) -> void:
	if OS.is_debug_build() && !(key is String):
		print("Warning: Expected serialized key in InkList.set_raw().")

	_dictionary[key] = value

func erase_raw(key: String) -> bool:
	if OS.is_debug_build() && !(key is String):
		print("Warning: Expected serialized key in InkList.erase_raw().")

	return _dictionary.erase(key)

func get_raw(key: String, default = null):
	if OS.is_debug_build() && !(key is String):
		print("Warning: Expected serialized key in InkList.get_raw().")

	return _dictionary.get(key, default)

func has_raw(key: String) -> bool:
	if OS.is_debug_build() && !(key is String):
		print("Warning: Expected serialized key in InkList.has_raw().")

	return _dictionary.has(key)

func has_all_raw(keys: Array) -> bool:
	return _dictionary.has_all(keys)

func raw_keys() -> Array:
	return _dictionary.keys()

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type: String) -> bool:
	return type == "InkList" || .is_class(type)

func get_class() -> String:
	return "InkList"
