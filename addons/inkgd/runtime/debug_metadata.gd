# warning-ignore-all:unused_class_variable
# ############################################################################ #
# Copyright © 2015-present inkle Ltd.
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://addons/inkgd/runtime/ink_base.gd"

# ############################################################################ #

var start_line_number = 0 # int
var end_line_number = 0 # int
var file_name = null # String
var source_name = null # String

# ############################################################################ #

# () -> String
func to_string():
    if file_name != null:
        return str("line ", start_line_number, " of ", file_name)
    else:
        return str("line ", start_line_number)

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type):
    return type == "DebugMetadata" || .is_class(type)

func get_class():
    return "DebugMetadata"
