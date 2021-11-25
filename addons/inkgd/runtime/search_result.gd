# warning-ignore-all:unused_class_variable
# ############################################################################ #
# Copyright © 2015-present inkle Ltd.
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

# ############################################################################ #
# !! VALUE TYPE
# ############################################################################ #

extends "res://addons/inkgd/runtime/ink_base.gd"

# ############################################################################ #
# Self-reference
# ############################################################################ #

var SearchResult setget , get_SearchResult
func get_SearchResult():
	return load("res://addons/inkgd/runtime/search_result.gd")

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

func is_class(type):
	return type == "SearchResult" || .is_class(type)

func get_class():
	return "SearchResult"

# () -> InkSearchResult
func duplicate():
	var search_result = self.SearchResult.new()
	search_result.obj = obj
	search_result.approximate = approximate

	return search_result
