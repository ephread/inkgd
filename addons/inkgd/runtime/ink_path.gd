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

class_name InkPath

# ############################################################################ #

const parent_id = "^"

# ############################################################################ #

class Component extends InkBase:
	var index = 0 # int
	var name = null # String

	var is_index setget , get_is_index # bool
	func get_is_index(): return index >= 0

	var is_parent setget , get_is_parent # bool
	func get_is_parent():
		return name == parent_id

	# ######################################################################## #

	func _init(index_or_name):
		if index_or_name is int:
			var index = index_or_name
			assert(index >= 0)
			self.index = index
			self.name = null
		elif index_or_name is String:
			var name = index_or_name
			assert(name != null && name.length() > 0)
			self.name = name
			self.index = -1

	# () -> Component
	static func to_parent():
		return Component.new(parent_id)

	# () -> String
	func _to_string() -> String:
		if self.is_index:
			return str(index)
		else:
			return name

	# (Component) -> bool
	func equals(other_comp):
		# Simple test to make sure the object is of the right type.
		if !(other_comp is Object && other_comp.is_class("InkPath.Component")): return false

		if other_comp.is_index == self.is_index:
			if self.is_index:
				return index == other_comp.index
			else:
				return name == other_comp.name

		return false

	# ######################################################################## #
	# GDScript extra methods
	# ######################################################################## #

	func is_class(type):
		return type == "InkPath.Component" || .is_class(type)

	func get_class():
		return "InkPath.Component"

# ############################################################################ #

# (int) -> Component
func get_component(index):
	return self._components[index]

var is_relative = false # bool

var head setget , get_head # Component
func get_head():
	if _components.size() > 0:
		return _components.front()
	else:
		return null

# TODO: Make inspectable
var tail setget , get_tail # InkPath
func get_tail():
	if _components.size() >= 2:
		var tail_comps = _components.duplicate()
		tail_comps.pop_front()

		return InkPath().new_with_components(tail_comps)
	else:
		return InkPath().self()

var length setget , get_length # int
func get_length():
	return _components.size()

var last_component setget , get_last_component # Component
func get_last_component():
	if _components.size() > 0:
		return _components.back()
	else:
		return null

var contains_named_component setget , get_contains_named_component # bool
func get_contains_named_component():
	for comp in _components:
		if !comp.is_index:
			return true

	return false

func _init():
	self._components = []

func _init_with_head_tail(head, tail):
	self._components = []
	self._components.append(head)
	self._components = self._components + self.tail._components

func _init_with_components(components, relative = false):
	self._components = []
	self._components = self._components + components
	self.is_relative = relative

func _init_with_components_string(components_string):
	self._components = []
	self.components_string = components_string

# () -> InkPath
static func self():
	var path = InkPath().new()
	path.is_relative = true
	return path

# (InkPath) -> InkPath
func path_by_appending_path(path_to_append):
	var p = InkPath().new()

	var upward_moves = 0

	var i = 0
	while(i < path_to_append._components.size()):
		if path_to_append._components[i].is_parent:
			upward_moves += 1
		else:
			break
		i += 1

	i = 0
	while(i < self._components.size() - upward_moves):
		p._components.append(self._components[i])
		i += 1

	i = upward_moves
	while(i < path_to_append._components.size()):
		p._components.append(path_to_append._components[i])
		i += 1

	return p

# (Component) -> InkPath
func path_by_appending_component(c):
	var p = InkPath().new()
	p._components = p._components + self._components
	p._components.append(c)
	return p

var components_string setget set_components_string, get_components_string # String
func get_components_string():
	if _components_string == null:
		_components_string = Utils.join(".", _components)
		if self.is_relative:
			_components_string = "." + _components_string

	return _components_string

func set_components_string(value):
	_components.clear()
	_components_string = value

	if (_components_string == null || _components_string.length() == 0):
		return

	if _components_string[0] == '.':
		self.is_relative = true
		_components_string = _components_string.substr(1, _components_string.length() - 1)
	else:
		self.is_relative = false

	var components_strings = _components_string.split(".")
	for _str in components_strings:
		if _str.is_valid_integer():
			_components.append(Component.new(int(_str)))
		else:
			_components.append(Component.new(_str))

var _components_string # String

func _to_string() -> String:
	return self.components_string

# (Component) -> bool
func equals(other_path):
	# Simple test to make sure the object is of the right type.
	if !(other_path is Object && other_path.is_class("InkPath")): return false

	if other_path._components.size() != self._components.size():
		return false

	if other_path.is_relative != self.is_relative:
		return false

	return Utils.array_equal(other_path._components, self._components, true)

var _components = null # Array<Component>

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

static func new_with_head_tail(head, tail):
	var path = InkPath().new()
	path._init_with_head_tail(head, tail)
	return path

static func new_with_components(components, relative = false):
	var path = InkPath().new()
	path._init_with_components(components, relative)
	return path

static func new_with_components_string(components_string):
	var path = InkPath().new()
	path._init_with_components_string(components_string)
	return path

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type):
	return type == "InkPath" || .is_class(type)

func get_class():
	return "InkPath"

static func InkPath():
	return load("res://addons/inkgd/runtime/ink_path.gd")
