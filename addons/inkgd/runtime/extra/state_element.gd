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

# ############################################################################ #
# !! VALUE TYPE
# ############################################################################ #

enum State {
	NONE,
	OBJECT,
	ARRAY,
	PROPERTY,
	PROPERTY_NAME,
	STRING,
}

var type = State.NONE # State
var child_count = 0 # int

func _init(type):
	self.type = type

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type):
	return type == "StateElement" || .is_class(type)

func get_class():
	return "StateElement"
