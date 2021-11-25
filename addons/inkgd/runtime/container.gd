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

var InkSearchResult = load("res://addons/inkgd/runtime/search_result.gd")

# ############################################################################ #

var name = null # String

var content setget set_content, get_content # Array<InkObject>
func get_content():
	return self._content
func set_content(value):
	add_content(value)

var _content = null # Array<InkObject>

var named_content = null # Dictionary<string, INamedContent>

# Dictionary<string, InkObject>
var named_only_content setget set_named_only_content, get_named_only_content
func get_named_only_content():
	var named_only_content_dict = {} # Dictionary<string, InkObject>
	for key in self.named_content:
		named_only_content_dict[key] = self.named_content[key]

	for c in self.content:
		var named = Utils.as_INamedContent_or_null(c)
		if named != null && named.has_valid_name:
			named_only_content_dict.erase(named.name)

	if named_only_content_dict.size() == 0:
		named_only_content_dict = null

	return named_only_content_dict
func set_named_only_content(value):
	var existing_named_only = named_only_content
	if existing_named_only != null:
		for key in existing_named_only:
			self.named_content.erase(key)

	if value == null:
		return

	for key in value:
		var named = Utils.as_INamedContent_or_null(value[key])
		if named != null:
			add_to_named_content_only(named)


var visits_should_be_counted = false # bool
var turn_index_should_be_counted = false # bool
var counting_at_start_only = false # bool

enum CountFlags {
	VISITS = 1,
	TURNS = 2,
	COUNT_START_ONLY = 4
}

var count_flags setget set_count_flags, get_count_flags # CountFlags
func get_count_flags():
	var flags = 0

	if visits_should_be_counted:     flags |= CountFlags.VISITS
	if turn_index_should_be_counted: flags |= CountFlags.TURNS
	if counting_at_start_only:       flags |= CountFlags.COUNT_START_ONLY

	if flags == CountFlags.COUNT_START_ONLY:
		flags = 0

	return flags
func set_count_flags(value):
	var flag = value
	if (flag & CountFlags.VISITS) > 0:           visits_should_be_counted = true
	if (flag & CountFlags.TURNS) > 0:            turn_index_should_be_counted = true
	if (flag & CountFlags.COUNT_START_ONLY) > 0: counting_at_start_only = true

# () -> bool
var has_valid_name setget , get_has_valid_name
func get_has_valid_name():
	return self.name != null && self.name.length() > 0

# () -> InkPath
var path_to_first_leaf_content setget , get_path_to_first_leaf_content
func get_path_to_first_leaf_content():
	if self._path_to_first_leaf_content == null:
		self._path_to_first_leaf_content = self.path.path_by_appending_path(self.internal_path_to_first_leaf_content)

	return self._path_to_first_leaf_content

var _path_to_first_leaf_content # Path

# () -> InkPath
var internal_path_to_first_leaf_content setget , get_internal_path_to_first_leaf_content
func get_internal_path_to_first_leaf_content():
	var components = [] # Array<Path.Component>
	var container = self
	while container != null:
		if container.content.size() > 0:
			components.append(InkPath().Component.new(0))
			container = Utils.as_or_null(container.content[0], "InkContainer")

	return InkPath().new_with_components(components)

func _init():
	self._content = [] # List<InkObject>
	self.named_content = {} # Dictionary<string, INamedContent>

# (InkObject) -> void
func add_content(content_obj_or_content_list):
	if Utils.is_ink_class(content_obj_or_content_list, "InkObject"):
		var content_obj = content_obj_or_content_list
		self.content.append(content_obj)

		if content_obj.parent:
			Utils.throw_exception("content is already in " + content_obj.parent)
			return

		content_obj.parent = self

		try_add_named_content(content_obj)
	elif content_obj_or_content_list is Array:
		var content_list = content_obj_or_content_list
		for c in content_list:
			add_content(c)

# (InkObject, int) -> void
func insert_content(content_obj, index):
	self.content.insert(index, content_obj)

	if content_obj.parent:
		Utils.throw_exception("content is already in " + content_obj.parent)
		return

	content_obj.parent = self

	try_add_named_content(content_obj)

# (InkObject) -> void
func try_add_named_content(content_obj):
	var named_content_obj = Utils.as_INamedContent_or_null(content_obj)
	if (named_content_obj != null && named_content_obj.has_valid_name):
		add_to_named_content_only(named_content_obj)


# (INamedContent) -> void
func add_to_named_content_only(named_content_obj):
	Utils.assert(named_content_obj.is_class("InkObject"), "Can only add Runtime.Objects to a Runtime.Container")
	var runtime_obj = named_content_obj
	runtime_obj.parent = self

	named_content[named_content_obj.name] = named_content_obj

# (InkContainer) -> void
func add_contents_of_container(other_container):
	self.content = self.content + other_container.content
	for obj in other_container.content:
		obj.parent = self
		try_add_named_content(obj)

# (InkPath().Component) -> InkObject
func content_with_path_component(component):
	if component.is_index:
		if component.index >= 0 && component.index < self.content.size():
			return self.content[component.index]
		else:
			return null
	elif component.is_parent:
		return self.parent
	else:
		if named_content.has(component.name):
			var found_content = named_content[component.name]
			return found_content
		else:
			return null

# (InkPath, int, int) -> InkSearchResult
func content_at_path(path, partial_path_start = 0, partial_path_length = -1):
	if partial_path_length == -1:
		partial_path_length = path.length

	var result = InkSearchResult.new()
	result.approximate = false

	var current_container = self # Container
	var current_obj = self # InkObject

	var i = partial_path_start
	while (i < partial_path_length):
		var comp = path.get_component(i)

		if current_container == null:
			result.approximate = true
			break

		var found_obj = current_container.content_with_path_component(comp)

		if found_obj == null:
			result.approximate = true
			break

		current_obj = found_obj
		current_container = Utils.as_or_null(found_obj, "InkContainer")

		i += 1

	result.obj = current_obj

	return result

# (String, int, InkObject) -> string
func build_string_of_hierarchy(existing_hierarchy, indentation, pointed_obj):
	existing_hierarchy = _append_indentation(existing_hierarchy, indentation)
	existing_hierarchy += "["

	if self.has_valid_name:
		existing_hierarchy += str(" (", self.name, ") ")

	if self == pointed_obj:
		existing_hierarchy += "  <---"

	existing_hierarchy += "\n"

	indentation += 1

	var i = 0
	while i < self.content.size():
		var obj = self.content[i]

		if Utils.is_ink_class(obj, "InkContainer"):
			existing_hierarchy = obj.build_string_of_hierarchy(existing_hierarchy, indentation, pointed_obj)
		else:
			existing_hierarchy = _append_indentation(existing_hierarchy, indentation)
			if Utils.is_ink_class(obj, "StringValue"):
				existing_hierarchy += "\""
				existing_hierarchy += obj.to_string().replace("\n", "\\n")
				existing_hierarchy += "\""
			else:
				existing_hierarchy += obj.to_string()

		if i != self.content.size() - 1:
			existing_hierarchy += ","

		if !Utils.is_ink_class(obj, "InkContainer") && obj == pointed_obj:
			existing_hierarchy += "  <---"

		existing_hierarchy += "\n"
		i += 1

	var only_named = {} # Dictionary<String, INamedContent>

	for obj_key in self.named_content:
		var value = self.named_content[obj_key]
		if self.content.find(value) != -1:
			continue
		else:
			only_named[obj_key] = value

	if only_named.size() > 0:
		existing_hierarchy = _append_indentation(existing_hierarchy, indentation)
		existing_hierarchy += "-- named: --\n"

		for object_key in only_named:
			var value = only_named[object_key]
			Utils.assert(Utils.is_ink_class(value, "InkContainer"), "Can only print out named Containers")
			var container = value
			existing_hierarchy = container.build_string_of_hierarchy(existing_hierarchy, indentation, pointed_obj)
			existing_hierarchy += "\n"

	indentation -= 1

	existing_hierarchy = _append_indentation(existing_hierarchy, indentation)
	existing_hierarchy += "]"

	return existing_hierarchy

func build_full_string_of_hierarchy():
	return build_string_of_hierarchy("", 0, null)

func _append_indentation(string, indentation):
	var spaces_per_indent = 4
	var i = 0
	while(i < spaces_per_indent * indentation):
		string += " "
		i += 1

	return string


# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type):
	return type == "InkContainer" || .is_class(type)

func get_class():
	return "InkContainer"
