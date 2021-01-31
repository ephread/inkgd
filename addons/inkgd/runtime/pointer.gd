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

# ############################################################################ #
# !! VALUE TYPE
# ############################################################################ #

extends "res://addons/inkgd/runtime/ink_base.gd"

# ############################################################################ #
# Imports
# ############################################################################ #

var InkPath = load("res://addons/inkgd/runtime/ink_path.gd")

# ############################################################################ #

# () -> InkContainer
# Encapsulating container into a weak ref.
var container setget set_container, get_container
func set_container(value):
	if value == null:
		self._container = WeakRef.new()
	else:
		self._container = weakref(value)
func get_container():
	return self._container.get_ref()

var _container = WeakRef.new() # InkContainer

var index = 0 # int

# (InkContainer, int) -> InkPointer
func _init(container = null, index = 0):
	self.container = container
	self.index = index

# () -> InkContainer
func resolve():
	if index < 0: return self.container
	if self.container == null: return null
	if self.container.content.size() == 0: return self.container
	if index >= self.container.content.size(): return null

	return self.container.content[index]

# ############################################################################ #

# () -> bool
var is_null setget , get_is_null
func get_is_null():
	return self.container == null

# ############################################################################ #

# () -> InkPath
var path setget , get_path
func get_path():
	if self.is_null: return null

	if index >= 0:
		return self.container.path.path_by_appending_component(InkPath.Component.new(index))
	else:
		return self.container.path

 ############################################################################ #

# () -> String
func to_string():
	if self.container == null:
		return "Ink Pointer (null)"

	return "Ink Pointer -> " + self.container.path.to_string() + " -- index " + index

# (InkContainer) -> InkPointer
static func start_of(container):
	return Pointer().new(container, 0)

# ############################################################################ #

# () -> InkPointer
static func null():
	return Pointer().new(null, -1)

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type):
	return type == "Pointer" || .is_class(type)

func get_class():
	return "Pointer"

# () -> Pointer
func duplicate():
	return Pointer().new(self.container, index)

static func Pointer():
	return load("res://addons/inkgd/runtime/pointer.gd")
