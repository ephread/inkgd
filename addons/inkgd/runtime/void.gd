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
# GDScript extra methods
# ############################################################################ #

func is_class(type):
	return type == "Void" || .is_class(type)

func get_class():
	return "Void"

func to_string() -> String:
	return "Void"