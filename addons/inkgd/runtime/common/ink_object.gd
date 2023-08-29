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

# Encapsulating parent into a weak ref.
var parent: InkObject:
	get:
		return self._parent.get_ref()

	set(value):
		self._parent = weakref(value)

var _parent: WeakRef = WeakRef.new() # InkObject


# ############################################################################ #

var debug_metadata: InkDebugMetadata:
	get:
		if _debug_metadata == null:
			if self.parent:
				return self.parent.debug_metadata
		return _debug_metadata

	set(value):
		_debug_metadata = value

var _debug_metadata: InkDebugMetadata = null


# ############################################################################ #

var own_debug_metadata: InkDebugMetadata:
	get: return _debug_metadata


# ############################################################################ #

# (InkPath) -> int?
func debug_line_number_of_path(path: InkPath):
	if path == null:
		return null

	var root = self.root_content_container
	if root != null:
		var target_content := root.content_at_path(path).obj
		if target_content:
			var dm = target_content.debug_metadata
			if dm != null:
				return dm.start_line_number

	return null


# TODO: Make inspectable
# InkPath
var path: InkPath:
	get:
		if _path == null:
			if self.parent == null:
				_path = InkPath.new()
			else:
				var comps: Array = [] # Stack<Path3D.Component>

				var child = self
				var container = InkUtils.as_or_null(child.parent, "InkContainer")

				while container:
					var named_child = InkUtils.as_INamedContent_or_null(child)
					if (named_child != null && named_child.has_valid_name):
						comps.push_front(InkPath.Component.new(named_child.name))
					else:
						comps.push_front(InkPath.Component.new(container.content.find(child)))

					child = container
					container = InkUtils.as_or_null(container.parent, "InkContainer")

				_path = InkPath.new_with_components(comps)

		return _path

var _path: InkPath = null


func resolve_path(path: InkPath) -> InkSearchResult:
	if path.is_relative:
		var nearest_container = InkUtils.as_or_null(self, "InkContainer")
		if !nearest_container:
			InkUtils.__assert__(
					self.parent != null,
					"Can't resolve relative path because we don't have a parent"
			)

			nearest_container = InkUtils.as_or_null(self.parent, "InkContainer")

			InkUtils.__assert__(nearest_container != null, "Expected parent to be a container")
			InkUtils.__assert__(path.get_component(0).is_parent)

			path = path.tail

		return nearest_container.content_at_path(path)
	else:
		return self.root_content_container.content_at_path(path)


func convert_path_to_relative(global_path: InkPath) -> InkPath:
	var own_path := self.path

	var min_path_length: int = min(global_path.length, own_path.length)
	var last_shared_path_comp_index: int = -1

	var i: int = 0
	while i < min_path_length:
		var own_comp: InkPath.Component = own_path.get_component(i)
		var other_comp: InkPath.Component = global_path.get_component(i)

		if own_comp.equals(other_comp):
			last_shared_path_comp_index = i
		else:
			break

		i += 1

	if last_shared_path_comp_index == -1:
		return global_path

	var num_upwards_moves: int = (own_path.length - 1) - last_shared_path_comp_index

	var new_path_comps: Array = [] # Array<InkPath.Component>

	var up = 0
	while up < num_upwards_moves:
		new_path_comps.append(InkPath.Component.to_parent())
		up += 1

	var down = last_shared_path_comp_index + 1
	while down < global_path.length:
		new_path_comps.append(global_path.get_component(down))
		down += 1

	var relative_path = InkPath.new_with_components(new_path_comps, true)
	return relative_path


func compact_path_string(other_path: InkPath) -> String:
	var global_path_str
	var relative_path_str

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
var root_content_container: InkContainer:
	get:
		var ancestor := self
		while (ancestor.parent):
			ancestor = ancestor.parent

		return InkUtils.as_or_null(ancestor, "InkContainer")


# () -> InkObject
func copy():
	InkUtils.throw_exception("Not Implemented: Doesn't support copying")
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

func is_ink_class(type: String) -> bool:
	return type == "InkObject" || super.is_ink_class(type)


func get_ink_class() -> String:
	return "InkObject"
