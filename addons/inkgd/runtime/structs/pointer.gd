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

tool
extends InkBase

class_name InkPointer

# ############################################################################ #
# Imports
# ############################################################################ #

var InkPath := preload("res://addons/inkgd/runtime/ink_path.gd") as GDScript

static func InkPointer() -> GDScript:
	return load("res://addons/inkgd/runtime/structs/pointer.gd") as GDScript

# ############################################################################ #

# InkContainer
# Encapsulating container into a weak ref.
var container: InkContainer setget set_container, get_container
func set_container(value: InkContainer) -> void:
	if value == null:
		self._container = WeakRef.new()
	else:
		self._container = weakref(value)
func get_container() -> InkContainer:
	return self._container.get_ref()

var _container: WeakRef

var index: int = 0 # int

# (InkContainer, int) -> InkPointer
func _init(container: InkContainer = null, index: int = 0):
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
var is_null: bool setget , get_is_null
func get_is_null() -> bool:
	return self.container == null

# ############################################################################ #

# () -> InkPath
var path: InkPath setget , get_path
func get_path() -> InkPath:
	if self.is_null:
		return null

	if index >= 0:
		return self.container.path.path_by_appending_component(InkPath.Component.new(index))
	else:
		return self.container.path

 ############################################################################ #

func to_string() -> String:
	if self.container == null:
		return "Ink Pointer (null)"

	return "Ink Pointer -> %s -- index %d" % [self.container.path.to_string(), index]

# (InkContainer) -> InkPointer
static func start_of(container: InkContainer) -> InkPointer:
	return InkPointer().new(container, 0)

# ############################################################################ #

# () -> InkPointer
static func null():
	return InkPointer().new(null, -1)

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type: String) -> bool:
	return type == "Pointer" || .is_class(type)

func get_class() -> String:
	return "Pointer"

func duplicate() -> InkPointer:
	return InkPointer().new(self.container, index)
