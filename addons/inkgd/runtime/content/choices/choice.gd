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

class_name InkChoice

# ############################################################################ #
# Imports
# ############################################################################ #

var CallStack := load("res://addons/inkgd/runtime/callstack.gd") as GDScript

# ############################################################################ #

var text: String

var path_string_on_choice: String setget set_path_string_on_choice, get_path_string_on_choice
func get_path_string_on_choice() -> String:
	return target_path._to_string()

func set_path_string_on_choice(value: String):
	target_path = InkPath().new_with_components_string(value)

# String?
var source_path = null

var index: int = 0

# InkPath?
var target_path = null

# CallStack.InkThread?
var thread_at_generation = null

var original_thread_index: int = 0

var is_invisible_default: bool = false

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type):
	return type == "Choice" || .is_class(type)

func get_class():
	return "Choice"
