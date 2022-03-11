# warning-ignore-all:shadowed_variable
# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends Reference

class_name InkKeyValuePair

# ############################################################################ #
# Self-reference
# ############################################################################ #

static func InkKeyValuePair() -> GDScript:
	return load("res://addons/inkgd/runtime/extra/key_value_pair.gd") as GDScript

# ############################################################################ #

var key = null
var value = null

# ############################################################################ #

func _init():
	pass

func _init_with_key_value(key, value):
	self.key = key
	self.value = value

func _to_string():
	return ("[KeyValuePair (%s, %s)]" % [key, value])

# ############################################################################ #

static func new_with_key_value(key, value) -> InkKeyValuePair:
	var key_value_pair = InkKeyValuePair().new()
	key_value_pair._init_with_key_value(key, value)

	return key_value_pair
