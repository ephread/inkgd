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

extends InkObject

class_name InkDivert

# ############################################################################ #
# Imports
# ############################################################################ #

const PushPopType = preload("res://addons/inkgd/runtime/enums/push_pop.gd").PushPopType
var InkPointer := load("res://addons/inkgd/runtime/structs/pointer.gd") as GDScript

# ############################################################################ #

var target_path: InkPath setget set_target_path, get_target_path
func get_target_path() -> InkPath:
	if self._target_path != null && self._target_path.is_relative:
		var target_obj: InkObject = self.target_pointer.resolve()
		if target_obj:
			self._target_path = target_obj.path

	return self._target_path

func set_target_path(value: InkPath):
	self._target_path = value
	self._target_pointer = InkPointer.null()

# InkPath
var _target_path = null

var target_pointer: InkPointer setget , get_target_pointer # InkPointer
func get_target_pointer() -> InkPointer:
	if self._target_pointer.is_null:
		var target_obj = resolve_path(self._target_path).obj

		if self._target_path.last_component.is_index:
			self._target_pointer = InkPointer.new(
				Utils.as_or_null(target_obj.parent, "InkContainer"),
				self._target_path.last_component.index
			)
		else:
			self._target_pointer = InkPointer.start_of(Utils.as_or_null(target_obj, "InkContainer"))

	return self._target_pointer

var _target_pointer: InkPointer = InkPointer.null()

# String?
var target_path_string setget set_target_path_string, get_target_path_string
func get_target_path_string():
	if self.target_path == null:
		return null

	return self.compact_path_string(self.target_path)

func set_target_path_string(value):
	if value == null:
		self.target_path = null
	else:
		self.target_path = InkPath().new_with_components_string(value)

# String
var variable_divert_name = null
var has_variable_target: bool setget , get_has_variable_target
func get_has_variable_target() -> bool:
	return self.variable_divert_name != null

var pushes_to_stack: bool = false

# PushPopType
var stack_push_type: int = 0

var is_external: bool = false
var external_args: int = 0

var is_conditional: bool = false


# (int?) -> InkDivert
func _init_with(stack_push_type = null):
	self.pushes_to_stack = false

	if stack_push_type != null:
		self.pushes_to_stack = true
		self.stack_push_type = stack_push_type

# (InkBase) -> bool
func equals(obj) -> bool:
	var other_divert: InkDivert = Utils.as_or_null(obj, "Divert")
	if other_divert:
		if self.has_variable_target == other_divert.has_variable_target:
			if self.has_variable_target:
				return self.variable_divert_name == other_divert.variable_divert_name
			else:
				return self.target_path.equals(other_divert.target_path)

	return false

func _to_string() -> String:
	if self.has_variable_target:
		return "Divert(variable: %s)" % self.variable_divert_name
	elif self.target_path == null:
		return "Divert(null)"
	else:
		var _string = ""

		var target_str: String = self.target_path._to_string()
		var target_line_num = debug_line_number_of_path(self.target_path)
		if target_line_num != null:
			target_str = "line " + target_line_num

		_string += "Divert"

		if self.is_conditional:
			_string += "?"

		if self.pushes_to_stack:
			if self.stack_push_type == PushPopType.FUNCTION:
				_string += " function"
			else:
				_string += " tunnel"

		_string += " -> "
		_string += self.target_path_string

		_string += " (%s)" % target_str

		return _string

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type: String) -> bool:
	return type == "Divert" || .is_class(type)

func get_class() -> String:
	return "Divert"
