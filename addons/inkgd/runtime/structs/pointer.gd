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

# ############################################################################ #
# !! VALUE TYPE
# ############################################################################ #

# Pointers are passed around a lot, to prevent duplicating them all the time
# and confusing the inspector when the debugger is attached, they are
# immutable rather than being duplicated.

extends InkBase

class_name InkPointer

# ############################################################################ #

# InkContainer
# Encapsulating container into a weak ref.
var container: InkContainer:
	get:
		return self._container.get_ref()
	
	set(value):
		assert(false, "Pointer is immutable, cannot set container.")

var _container: WeakRef = WeakRef.new()

var index: int:
	get:
		return _index

	set(value):
		assert(false, "Pointer is immutable, cannot set index.")

var _index: int = 0 # int


# (InkContainer, int) -> InkPointer
func _init(container: InkContainer = null, index: int = 0):
	if container == null:
		self._container = WeakRef.new()
	else:
		self._container = weakref(container)

	self._index = index


# () -> InkContainer
func resolve():
	if self.index < 0: return self.container
	if self.container == null: return null
	if self.container.content.size() == 0: return self.container
	if self.index >= self.container.content.size(): return null

	return self.container.content[self.index]


# ############################################################################ #

# () -> bool
var is_null: bool: get = get_is_null
func get_is_null() -> bool:
	return self.container == null


# ############################################################################ #

# TODO: Make inspectable
# () -> InkPath
var path: InkPath:
	get:
		if self.is_null:
			return null

		if self.index >= 0:
			return self.container.path.path_by_appending_component(
					InkPath.Component.new(self.index)
			)
		else:
			return self.container.path


############################################################################# #

func _to_string() -> String:
	if self.container == null:
		return "Ink Pointer (null)"

	return "Ink Pointer -> %s -- index %d" % [self.container.path._to_string(), self.index]


# (InkContainer) -> InkPointer
static func start_of(container: InkContainer) -> InkPointer:
	return InkPointer.new(container, 0)

# ############################################################################ #

# () -> InkPointer
static var null_pointer: InkPointer:
	get: return InkPointer.new(null, -1)


# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_ink_class(type: String) -> bool:
	return type == "InkPointer" || super.is_ink_class(type)


func get_ink_class() -> String:
	return "InkPointer"


func duplicate() -> InkPointer:
	return InkPointer.new(self.container, self.index)
