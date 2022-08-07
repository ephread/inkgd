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

extends Reference

class_name InkBase

# ############################################################################ #
# Imports
# ############################################################################ #

var Utils := preload("res://addons/inkgd/runtime/extra/utils.gd") as GDScript

# ############################################################################ #

func equals(ink_base) -> bool:
	return false


# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type: String) -> bool:
	return type == "InkBase" || .is_class(type)

func get_class() -> String:
	return "InkBase"
