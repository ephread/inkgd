# warning-ignore-all:shadowed_variable
# ############################################################################ #
# Copyright © 2015-present inkle Ltd.
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends Reference

# ############################################################################ #
# Self-reference
# ############################################################################ #

static func KeyValuePair():
	return load("res://addons/inkgd/runtime/extra/key_value_pair.gd")

# ############################################################################ #

var key = null
var value = null

# ############################################################################ #

func _init():
	pass

func _init_with_key_value(key, value):
	self.key = key
	self.value = value

# ############################################################################ #

static func new_with_key_value(key, value):
	var key_value_pair = KeyValuePair().new()
	key_value_pair._init_with_key_value(key, value)

	return key_value_pair
