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

extends InkBase

class_name InkObject

# ############################################################################ #
# Imports
# ############################################################################ #

static func InkPath() -> GDScript:
	return load("res://addons/inkgd/runtime/ink_path.gd") as GDScript

# ############################################################################ #

# () -> InkObject
# Encapsulating parent into a weak ref.
var parent: InkObject setget set_parent, get_parent
func set_parent(value: InkObject):
	self._parent = weakref(value)
func get_parent() -> InkObject:
	return self._parent.get_ref()

var _parent: WeakRef = WeakRef.new() # InkObject

# ############################################################################ #

# () -> InkDebugMetadata
var debug_metadata setget set_debug_metadata, get_debug_metadata
func get_debug_metadata():
	if _debug_metadata == null:
		if self.parent:
			return self.parent.debug_metadata

	return _debug_metadata

func set_debug_metadata(value):
	_debug_metadata = value

var _debug_metadata = null # InkDebugMetadata

# ############################################################################ #

# () -> InkDebugMetadata
var own_debug_metadata setget , get_own_debug_metadata
func get_own_debug_metadata():
	return _debug_metadata

# ############################################################################ #

# (InkPath) -> int?
func debug_line_number_of_path(path: InkPath):
	if path == null:
		return null

	var root = self.root_content_container
	if root != null:
		var target_content = root.content_at_path(path).obj
		if target_content:
			var dm = target_content.debug_metadata
			if dm != null:
				return dm.start_line_number

	return null

# TODO: Make inspectable
# InkPath
var path: InkPath setget , get_path
func get_path() -> InkPath:
	if _path == null:
		if self.parent == null:
			_path = InkPath().new()
		else:
			var comps: Array = [] # Stack<Path.Component>

			var child = self
			var container = Utils.as_or_null(child.parent, "InkContainer")

			while container:
				var named_child = Utils.as_INamedContent_or_null(child)
				if (named_child != null && named_child.has_valid_name):
					comps.push_front(InkPath().Component.new(named_child.name))
				else:
					comps.push_front(InkPath().Component.new(container.content.find(child)))

				child = container
				container = Utils.as_or_null(container.parent, "InkContainer")

			_path = InkPath().new_with_components(comps)

	return _path

var _path = null # InkPath

# (InkPath) -> SearchResult
func resolve_path(path: InkPath) -> InkSearchResult:
	if path.is_relative:
		var nearest_container = Utils.as_or_null(self, "InkContainer")
		if !nearest_container:
			Utils.__assert__(
					self.parent != null,
					"Can't resolve relative path because we don't have a parent"
			)

			nearest_container = Utils.as_or_null(self.parent, "InkContainer")

			Utils.__assert__(nearest_container != null, "Expected parent to be a container")
			Utils.__assert__(path.get_component(0).is_parent)

			path = path.tail

		return nearest_container.content_at_path(path)
	else:
		return self.root_content_container.content_at_path(path)

func convert_path_to_relative(global_path: InkPath) -> InkPath:
	var own_path = self.path

	var min_path_length = min(global_path.length, own_path.length)
	var last_shared_path_comp_index = -1

	var i = 0
	while i < min_path_length:
		var own_comp = own_path.get_component(i)
		var other_comp = global_path.get_component(i)

		if own_comp.equals(other_comp):
			last_shared_path_comp_index = i
		else:
			break

		i += 1

	if last_shared_path_comp_index == -1:
		return global_path

	var num_upwards_moves = (own_path.length - 1) - last_shared_path_comp_index

	var new_path_comps: Array = [] # Array<Path.Component>

	var up = 0
	while up < num_upwards_moves:
		new_path_comps.append(InkPath().Component.to_parent())
		up += 1

	var down = last_shared_path_comp_index + 1
	while down < global_path.length:
		new_path_comps.append(global_path.get_component(down))
		down += 1

	var relative_path = InkPath().new_with_components(new_path_comps, true)
	return relative_path

# (Path) -> String
func compact_path_string(other_path: InkPath) -> String:
	var global_path_str = null # String
	var relative_path_str = null # String

	if other_path.is_relative:
		relative_path_str = other_path.components_string
		global_path_str = self.path.path_by_appending_path(other_path).components_string
	else:
		var relative_path = convert_path_to_relative(other_path)
		relative_path_str = relative_path.components_string
		global_path_str = other_path.components_string

	if (relative_path_str.length() < global_path_str.length()):
		return relative_path_str
	else:
		return global_path_str

# () -> InkContainer
var root_content_container setget , get_root_content_container
func get_root_content_container():
	var ancestor = self
	while (ancestor.parent):
		ancestor = ancestor.parent

	return Utils.as_or_null(ancestor, "InkContainer")

# () -> InkObject
func copy():
	Utils.throw_exception("Not Implemented: Doesn't support copying")
	return null

# (InkObject, InkObject) -> void
func set_child(obj: InkObject, value: InkObject):
	if obj:
		obj.parent = null

	obj = value

	if obj:
		obj.parent = self

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type: String) -> bool:
	return type == "InkObject" || .is_class(type)

func get_class() -> String:
	return "InkObject"
