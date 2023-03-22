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

# Encapsulating container into a weak ref.
var container: InkContainer: get = get_container, set = set_container
func set_container(_value: InkContainer) -> void:
	@warning_ignore("assert_always_false")
	assert(false, "Pointer is immutable, cannot set container.")
func get_container() -> InkContainer:
	return _container.get_ref()
var _container: WeakRef = WeakRef.new()

var index: int: get = get_index, set = set_index
func set_index(_value: int):
	@warning_ignore("assert_always_false")
	assert(false, "Pointer is immutable, cannot set index.")
func get_index() -> int:
	return _index
var _index: int = 0 # int

# (InkContainer, int) -> InkPointer
func _init(container: InkContainer = null, index: int = 0):
	if container == null:
		_container = WeakRef.new()
	else:
		_container = weakref(container)

	_index = index

# () -> InkContainer
func resolve():
	if index < 0: return container
	if container == null: return null
	if container.content.size() == 0: return container
	if index >= container.content.size(): return null

	return container.content[index]

# ############################################################################ #

# () -> bool
var is_null: bool: get = get_is_null
func get_is_null() -> bool:
	return container == null

# ############################################################################ #

# TODO: Make inspectable
# () -> InkPath
var path: InkPath: get = get_path
func get_path() -> InkPath:
	if is_null:
		return null

	if index >= 0:
		return container.path.path_by_appending_component(
				InkPath.Component.new(index)
		)
	else:
		return container.path

 ############################################################################ #

func _to_string() -> String:
	if container == null:
		return "Ink Pointer (null)"

	return "Ink Pointer -> %s -- index %d" % [container.path._to_string(), index]

# (InkContainer) -> InkPointer
static func start_of(container: InkContainer) -> InkPointer:
	return InkPointer.new(container, 0)

# ############################################################################ #

# () -> InkPointer
static func new_null() -> InkPointer:
	return InkPointer.new(null, -1)

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func duplicate() -> InkPointer:
	return InkPointer.new(container, index)
