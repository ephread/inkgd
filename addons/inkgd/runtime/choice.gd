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
# Imports
# ############################################################################ #

var CallStack = load("res://addons/inkgd/runtime/callstack.gd")

# ############################################################################ #

var text # String

# () -> String
# (String) -> void
var path_string_on_choice setget set_path_string_on_choice, get_path_string_on_choice
func get_path_string_on_choice():
	return target_path.to_string()

func set_path_string_on_choice(value):
	target_path = InkPath().new_with_components_string(value)

var source_path = null # String
var index = 0 # index
var target_path = null # InkPath
var thread_at_generation = null # CallStack.InkThread
var original_thread_index = 0 # int
var is_invisible_default = false # bool

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type):
	return type == "Choice" || .is_class(type)

func get_class():
	return "Choice"
