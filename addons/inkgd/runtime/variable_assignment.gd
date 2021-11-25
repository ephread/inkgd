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
extends "res://addons/inkgd/runtime/ink_object.gd"

# ############################################################################ #
# Self-reference
# ############################################################################ #

static func VariableAssignment():
	return load("res://addons/inkgd/runtime/variable_assignment.gd")

# ############################################################################ #

var variable_name = null # String
var is_new_declaration = false # bool
var is_global = false # bool

func _init():
	_init_with(null, false)

func _init_with(variable_name, is_new_declaration):
	self.variable_name = variable_name
	self.is_new_declaration = is_new_declaration

func to_string():
	return "VarAssign to " + variable_name

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type):
	return type == "VariableAssignment" || .is_class(type)

func get_class():
	return "VariableAssignment"

static func new_with(variable_name, is_new_declaration):
	var variable_assignment = VariableAssignment().new()
	variable_assignment._init_with(variable_name, is_new_declaration)
	return variable_assignment
