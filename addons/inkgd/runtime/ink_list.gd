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

var InkListItem = load("res://addons/inkgd/runtime/ink_list_item.gd")
var KeyValuePair = load("res://addons/inkgd/runtime/extra/key_value_pair.gd")

# ############################################################################ #

func _init():
	pass

func _init_with_ink_list(other_list):
	_dictionary = other_list._dictionary.duplicate()
	_origin_names = other_list.origin_names
	if other_list.origins != null:
		self.origins = other_list.origins.duplicate()

func _init_with_single_item(single_item, single_value):
	set(single_item, single_value)

func _init_with_origin(single_origin_list_name, origin_story):
	set_initial_origin_name(single_origin_list_name)

	var def = origin_story.list_definitions.try_list_get_definition (single_origin_list_name)
	if def.exists:
		origins = [def.result]
	else:
		Utils.throw_exception("InkList origin could not be found in story when constructing new list: " + single_origin_list_name)

func _init_with_element(key, value):
	set(key, value)

# (string, Story) -> InkList
static func from_string(my_list_item, origin_story):
	var list_value = origin_story.list_definitions.find_single_item_list_with_name(my_list_item)
	if list_value:
		return InkList().new_with_ink_list(list_value.value)
	else:
		Utils().throw_exception("Could not find the InkListItem from the string '" + my_list_item + "' to create an InkList because it doesn't exist in the original list definition in ink.")

# (InkListItem) -> void
func add_item(item):
	if item.origin_name == null:
		add_item(item.item_name)
		return

	for origin in origins:
		if origin.name == item.origin_name:
			var int_val = origin.try_get_value_for_item(item)
			if int_val.exists:
				set(item, int_val.result)
				return
			else:
				Utils.throw_exception("Could not add the item " + item + " to this list because it doesn't exist in the original list definition in ink.")
				return

	Utils.throw_exception("Failed to add item to list because the item was from a new list definition that wasn't previously known to this list. Only items from previously known lists can be used, so that the int value can be found.")

func add_item_by_string(item_name):
	var found_list_def = null # ListDefinition

	for origin in origins:
		if origin.contains_item_with_name(item_name):
			if found_list_def != null:
				Utils.throw_exception("Could not add the item " + item_name + " to this list because it could come from either " + origin.name + " or " + found_list_def.name)
				return
			else:
				found_list_def = origin

	if found_list_def == null:
		Utils.throw_exception("Could not add the item " + item_name + " to this list because it isn't known to any list definitions previously associated with this list.")
		return

	var item = InkListItem.new_with_origin_name(found_list_def.name, item_name)
	var item_val = found_list_def.value_for_item(item)
	set(item, item_val)

# (String) -> Bool
func contains_item_named(item_name):
	for item_key in keys():
		if item_key.item_name == item_name:
			return true

	return false

var origins = null # Array<ListDefinition>
var origin_of_max_item setget , get_origin_of_max_item # ListDefinition
func get_origin_of_max_item():
	if origins == null: return null

	var max_origin_name = self.max_item.key.origin_name
	for origin in origins:
		if origin.name == max_origin_name:
			return origin

	return null

var origin_names setget , get_origin_names # Array<String>
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

# (String) -> void
func set_initial_origin_name(initial_origin_name):
	_origin_names = [ initial_origin_name ]

# (Array<String>) -> void
func set_initial_origin_names(initial_origin_names):
	if initial_origin_names == null:
		_origin_names = null
	else:
		_origin_names = initial_origin_names.duplicate()

var max_item setget , get_max_item # KeyValuePair<InkListItem, int>
func get_max_item():
	var _max_item = KeyValuePair.new_with_key_value(InkListItem.null(), 0)
	for k in keys():
		if (_max_item.key.is_null || get(k) > _max_item.value):
			_max_item = KeyValuePair.new_with_key_value(k, get(k))

	return _max_item

var min_item setget , get_min_item # KeyValuePair<InkListItem, int>
func get_min_item():
	var _min_item = KeyValuePair.new_with_key_value(InkListItem.null(), 0)
	for k in keys():
		if (_min_item.key.is_null || get(k) < _min_item.value):
			_min_item = KeyValuePair.new_with_key_value(k, get(k))

	return _min_item

var inverse setget , get_inverse # InkList
func get_inverse():
	var list = InkList().new()
	if origins != null:
		for origin in origins:
			for serialized_item_key in origin.items:
				if !_dictionary.has(serialized_item_key):
					list._dictionary[serialized_item_key] = origin.items[serialized_item_key]

	return list

var all setget , get_all # InkList
func get_all():
	var list = InkList().new()
	if origins != null:
		for origin in origins:
			for serialized_item_key in origin.items:
				list._dictionary[serialized_item_key] = origin.items[serialized_item_key]

	return list

# (InkList) -> InkList
func union(other_list):
	var union = InkList().new_with_ink_list(self)
	for key in other_list._dictionary:
		union._dictionary[key] = other_list._dictionary[key]
	return union

# (InkList) -> InkList
func intersection(other_list):
	var intersection = InkList().new()
	for key in other_list._dictionary:
		if self._dictionary.has(key):
			intersection._dictionary[key] = other_list._dictionary[key]
	return intersection

# (InkList) -> InkList
func without(list_to_remove):
	var result = InkList().new_with_ink_list(self)
	for key in list_to_remove._dictionary:
		result._dictionary.erase(key)
	return result

# (InkList) -> bool
func contains(other_list):
	for key in other_list._dictionary:
		if !_dictionary.has(key):
			return false

	return true

# (InkList) -> bool
func greater_than(other_list):
	if (size() == 0):
		return false
	if (other_list.size() == 0):
		return true

	return self.min_item.value > other_list.max_item.value

# (InkList) -> bool
func greater_than_or_equals(other_list):
	if (size() == 0):
		return false
	if (other_list.size() == 0):
		return true

	return (self.min_item.value >= other_list.min_item.value &&
			self.max_item.value >= other_list.max_item.value)

# (InkList) -> bool
func less_than(other_list):
	if (other_list.size() == 0):
		return false
	if (size() == 0):
		return true

	return self.max_item.value < other_list.min_item.value

# (InkList) -> bool
func less_than_or_equals(other_list):
	if (other_list.size() == 0):
		return false
	if (size() == 0):
		return true

	return (self.max_item.value <= other_list.max_item.value &&
			self.min_item.value <= other_list.min_item.value)

func max_as_list():
	if (size() > 0):
		var _max_item = self.max_item
		return InkList().new_with_single_item(_max_item.key, _max_item.value)
	else:
		return InkList().new()

func min_as_list():
	if (size() > 0):
		var _min_item = self.min_item
		return InkList().new_with_single_item(_min_item.key, _min_item.value)
	else:
		return InkList().new()

# (Variant, Variant) -> InkList
func list_with_sub_range(min_bound, max_bound):
	if (size() == 0):
		return InkList().new()

	var ordered = self.ordered_items

	var min_value = 0
	var max_value = 9223372036854775807

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
			sub_list.set(item.key, item.value)

	return sub_list

func equals(other):
	var other_raw_list = other
	# Simple test to make sure the object is of the right type.
	if !(other_raw_list is Object): return false
	if !(other_raw_list.is_class("InkList")): return false

	if other_raw_list.size() != self.size(): return false
	for key in keys():
		if (!other_raw_list.has(key)):
			return false

	return true

var ordered_items setget , get_ordered_items # Array<KeyValuePair<InkListItem, int>>
func get_ordered_items():
	var ordered = []
	for key in keys():
		ordered.append(KeyValuePair.new_with_key_value(key, get(key)))

	ordered.sort_custom(KeyValueInkListItemSorter, "sort")
	return ordered

func to_string():
	var ordered = self.ordered_items

	var description = ""
	var i = 0
	while (i < ordered.size()):
		if i > 0:
			description += ", "

		var item = ordered[i].key
		description += item.item_name
		i += 1

	return description

static func new_with_dictionary(other_dictionary):
	var ink_list = InkList().new()
	ink_list._init_with_dictionary(other_dictionary)
	return ink_list

static func new_with_ink_list(other_list):
	var ink_list = InkList().new()
	ink_list._init_with_ink_list(other_list)
	return ink_list

static func new_with_origin(single_origin_list_name, origin_story):
	var ink_list = InkList().new()
	ink_list._init_with_origin(single_origin_list_name, origin_story)
	return ink_list

static func new_with_single_item(single_item, single_value):
	var ink_list = InkList().new()
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
# GDScript. Instead, this class will encapsulate a dictionary and forward calls.
# ############################################################################ #

var _dictionary = {}

func clear():
	_dictionary.clear()

func duplicate(deep = false):
	return _dictionary.duplicate(deep)

func empty():
	return _dictionary.empty()

func erase(key):
	_dictionary.erase(key.serialized())

func get(key, default = null):
	return _dictionary.get(key.serialized(), default)

func has(key):
	return _dictionary.has(key.serialized())

func has_all(keys):
	var serialized_keys = []
	for key in keys:
		serialized_keys.append(key.serialized())

	return _dictionary.has_all(serialized_keys)

func hash():
	return _dictionary.hash()

func keys():
	var deserialized_keys = []
	for key in _dictionary.keys():
		deserialized_keys.append(InkListItem.from_serialized_key(key))

	return deserialized_keys

func size():
	return _dictionary.size()

func values():
	return _dictionary.value()

# ############################################################################ #
# Additional methods

func set(key, value):
	_dictionary[key.serialized()] = value

func set_raw(key, value):
	if OS.is_debug_build() && !(key is String):
		print("Warning: Expected serialized key in InkList.set_raw().")

	_dictionary[key] = value

func erase_raw(key):
	if OS.is_debug_build() && !(key is String):
		print("Warning: Expected serialized key in InkList.erase_raw().")

	_dictionary.erase(key)

func get_raw(key, default = null):
	if OS.is_debug_build() && !(key is String):
		print("Warning: Expected serialized key in InkList.get_raw().")

	return _dictionary.get(key, default)

func has_raw(key):
	if OS.is_debug_build() && !(key is String):
		print("Warning: Expected serialized key in InkList.has_raw().")

	return _dictionary.has(key)

func has_all_raw(keys):
	return _dictionary.has_all(keys)

func raw_keys():
	return _dictionary.keys()

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type):
	return type == "InkList" || .is_class(type)

func get_class():
	return "InkList"

static func InkList():
	return load("res://addons/inkgd/runtime/ink_list.gd")

static func Utils():
	return load("res://addons/inkgd/runtime/extra/utils.gd")
