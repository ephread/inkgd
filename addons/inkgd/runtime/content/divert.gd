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

# ############################################################################ #

var target_path: InkPath: get = get_target_path, set = set_target_path
func get_target_path() -> InkPath:
	if _target_path != null && _target_path.is_relative:
		var target_obj: InkObject = target_pointer.resolve()
		if target_obj:
			_target_path = target_obj.path

	return _target_path

func set_target_path(value: InkPath):
	_target_path = value
	_target_pointer = InkPointer.new_null()

var _target_path: InkPath = null

var target_pointer: InkPointer:
	get = get_target_pointer
func get_target_pointer() -> InkPointer:
	if _target_pointer.is_null:
		var target_obj = resolve_path(_target_path).obj

		if _target_path.last_component.is_index:
			_target_pointer = InkPointer.new(
				target_obj.parent as InkContainer,
				_target_path.last_component.index
			)
		else:
			_target_pointer = InkPointer.start_of(target_obj as InkContainer)

	return _target_pointer

var _target_pointer: InkPointer = InkPointer.new_null()

# String?
var target_path_string : get = get_target_path_string, set = set_target_path_string
func get_target_path_string():
	if target_path == null:
		return null

	return compact_path_string(target_path)

func set_target_path_string(value):
	if value == null:
		target_path = null
	else:
		target_path = InkPath.new_with_components_string(value)

# String
var variable_divert_name = null
var has_variable_target: bool: get = get_has_variable_target
func get_has_variable_target() -> bool:
	return variable_divert_name != null

var pushes_to_stack: bool = false

# PushPopType
var stack_push_type: int = 0

var is_external: bool = false
var external_args: int = 0

var is_conditional: bool = false


# (int?) -> InkDivert
func _init_with(stack_push_type = null):
	pushes_to_stack = false

	if stack_push_type != null:
		pushes_to_stack = true
		self.stack_push_type = stack_push_type

# (InkBase) -> bool
func equals(obj) -> bool:
	var other_divert: InkDivert = obj as InkDivert
	if other_divert:
		if has_variable_target == other_divert.has_variable_target:
			if has_variable_target:
				return variable_divert_name == other_divert.variable_divert_name
			else:
				return target_path.equals(other_divert.target_path)

	return false

func _to_string() -> String:
	if has_variable_target:
		return "Divert(variable: %s)" % variable_divert_name
	elif target_path == null:
		return "Divert(null)"
	else:
		var _string = ""

		var target_str: String = target_path._to_string()
		var target_line_num = debug_line_number_of_path(target_path)
		if target_line_num != null:
			target_str = "line " + target_line_num

		_string += "Divert"

		if is_conditional:
			_string += "?"

		if pushes_to_stack:
			if stack_push_type == PushPopType.FUNCTION:
				_string += " function"
			else:
				_string += " tunnel"

		_string += " -> "
		_string += target_path_string

		_string += " (%s)" % target_str

		return _string
