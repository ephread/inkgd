# warning-ignore-all:shadowed_variable
# warning-ignore-all:unused_class_variable
# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2023 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends InkObject

class_name InkDivert

# ############################################################################ #

var target_path: InkPath:
	get:
		if self._target_path != null && self._target_path.is_relative:
			var target_obj: InkObject = self.target_pointer.resolve()
			if target_obj:
				self._target_path = target_obj.path

		return self._target_path

	set(value):
		self._target_path = value
		self._target_pointer = InkPointer.null_pointer()

var _target_path: InkPath = null


var target_pointer: InkPointer:
	get:
		if self._target_pointer.is_null:
			var target_obj = resolve_path(self._target_path).obj

			if self._target_path.last_component.is_index:
				self._target_pointer = InkPointer.new(
					InkUtils.as_or_null(target_obj.parent, "InkContainer"),
					self._target_path.last_component.index
				)
			else:
				self._target_pointer = InkPointer.start_of(InkUtils.as_or_null(target_obj, "InkContainer"))

		return self._target_pointer

var _target_pointer: InkPointer = InkPointer.null_pointer()


var target_path_string: # String?
	get:
		if self.target_path == null:
			return null

		return self.compact_path_string(self.target_path)

	set(value):
		if value == null:
			self.target_path = null
		else:
			self.target_path = InkPath.new_with_components_string(value)


var variable_divert_name = null # String?
var has_variable_target: bool:
	get: return self.variable_divert_name != null


var pushes_to_stack: bool = false

var stack_push_type: int = 0 # Ink.PushPopType

var is_external: bool = false

var external_args: int = 0

var is_conditional: bool = false


# (int?) -> InkDivert
@warning_ignore("shadowed_variable")
func _init_with(stack_push_type = null):
	self.pushes_to_stack = false

	if stack_push_type != null:
		self.pushes_to_stack = true
		self.stack_push_type = stack_push_type


func equals(obj: InkBase) -> bool:
	var other_divert: InkDivert = InkUtils.as_or_null(obj, "Divert")
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
			if self.stack_push_type == Ink.PushPopType.FUNCTION:
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

func is_ink_class(type: String) -> bool:
	return type == "Divert" || super.is_ink_class(type)


func get_ink_class() -> String:
	return "Divert"
