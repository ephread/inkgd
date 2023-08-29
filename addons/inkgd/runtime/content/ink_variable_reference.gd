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

class_name InkVariableReference

# ############################################################################ #

var name = null # String?

# InkPath
var path_for_count: InkPath = null

# Container?
var container_for_count: InkContainer:
	get: return self.resolve_path(path_for_count).container

# String?
var path_string_for_count:
	get:
		if path_for_count == null:
			return null

		return compact_path_string(path_for_count)

	set(value):
		if value == null:
			path_for_count = null
		else:
			path_for_count = InkPath.new_with_components_string(value)


# ############################################################################ #

@warning_ignore("shadowed_variable")
func _init(name = null):
	if name:
		self.name = name


# ############################################################################ #

func _to_string() -> String:
	if name != null:
		return "var(%s)" % name
	else:
		var path_str = self.path_string_for_count
		return "read_count(%s)" % path_str


# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_ink_class(type: String) -> bool:
	return type == "VariableReference" || super.is_ink_class(type)


func get_ink_class() -> String:
	return "VariableReference"
