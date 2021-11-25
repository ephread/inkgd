# ############################################################################ #
# Copyright © 2015-present inkle Ltd.
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://addons/inkgd/runtime/ink_object.gd"

var text # String

# (String) -> Tag
func _init(tag_text):
	text = tag_text

# () -> String
func to_string():
	return '# ' + text

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type):
	return type == "Tag" || .is_class(type)

func get_class():
	return "Tag"
