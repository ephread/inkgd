# warning-ignore-all:unused_class_variable
# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

# ############################################################################ #
# !! VALUE TYPE
# ############################################################################ #

# Search results are never duplicated / passed around so they don't need to
# be either immutable or have a 'duplicate' method.

extends InkBase

class_name InkSearchResult

# ############################################################################ #
# Self-reference
# ############################################################################ #

static func SearchResult() -> GDScript:
	return load("res://addons/inkgd/runtime/search_result.gd") as GDScript

# ############################################################################ #

var obj = null # InkObject
var approximate = false # bool

var correct_obj setget , get_correct_obj # InkObject
func get_correct_obj():
	return null if approximate else obj

var container setget , get_container # Container
func get_container():
	return Utils.as_or_null(obj, "InkContainer")

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type: String) -> bool:
	return type == "SearchResult" || .is_class(type)

func get_class() -> String:
	return "SearchResult"
