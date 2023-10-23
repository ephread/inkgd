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

class_name InkVariableAssignment

# ############################################################################ #

var variable_name = null # String?

var is_new_declaration: bool = false

var is_global: bool = false


func _init():
	_init_with(null, false)


# (String?, bool) -> InkVariableAssignment
@warning_ignore("shadowed_variable")
func _init_with(variable_name, is_new_declaration: bool):
	self.variable_name = variable_name
	self.is_new_declaration = is_new_declaration


func _to_string() -> String:
	return "VarAssign to %s" % variable_name


# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_ink_class(type: String) -> bool:
	return type == "VariableAssignment" || super.is_ink_class(type)


func get_ink_class() -> String:
	return "VariableAssignment"


# (String?, bool) -> InkVariableAssignment
@warning_ignore("shadowed_variable")
static func new_with(
		variable_name: String,
		is_new_declaration: bool
) -> InkVariableAssignment:
	var variable_assignment = InkVariableAssignment.new()
	variable_assignment._init_with(variable_name, is_new_declaration)
	return variable_assignment
