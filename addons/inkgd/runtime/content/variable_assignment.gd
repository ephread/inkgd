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

# String
var variable_name = null
var is_new_declaration: bool = false
var is_global: bool = false

func _init():
	_init_with(null, false)

# (String?, bool) -> InkVariableAssignment
func _init_with(variable_name, is_new_declaration: bool):
	self.variable_name = variable_name
	self.is_new_declaration = is_new_declaration

func _to_string() -> String:
	return "VarAssign to %s" % variable_name

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

# (String?, bool) -> InkVariableAssignment
static func new_with(
		variable_name: String,
		is_new_declaration: bool
) -> InkVariableAssignment:
	var variable_assignment = InkVariableAssignment.new()
	variable_assignment._init_with(variable_name, is_new_declaration)
	return variable_assignment
