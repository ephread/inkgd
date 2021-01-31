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

var name = null # String
var path_for_count = null # InkPath

var container_for_count setget , get_container_for_count # Container
func get_container_for_count():
	return self.resolve_path(path_for_count).container

var path_string_for_count setget set_path_string_for_count , get_path_string_for_count # String
func get_path_string_for_count():
	if path_for_count == null:
		return null

	return compact_path_string(path_for_count)
func set_path_string_for_count(value):
	if value == null:
		path_for_count = null
	else:
		path_for_count = InkPath().new_with_components_string(value)

func _init(name = null):
	if name:
		self.name = name

func to_string():
	if name != null:
		return str("var(", name, ")")
	else:
		var path_str = self.path_string_for_count
		return str("read_count(", path_str, ")")

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type):
	return type == "VariableReference" || .is_class(type)

func get_class():
	return "VariableReference"
