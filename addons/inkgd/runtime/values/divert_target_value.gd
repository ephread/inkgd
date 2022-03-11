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

extends InkValue

class_name InkDivertTargetValue

# ############################################################################ #

var target_path setget set_target_path, get_target_path # InkPath
func get_target_path():
	return value
func set_target_path(value):
	self.value = value

func get_value_type():
	return ValueType.DIVERT_TARGET

func get_is_truthy():
	Utils.throw_exception("Shouldn't be checking the truthiness of a divert target")
	return false

func _init():
	value = null

func cast(new_type):
	if new_type == self.value_type:
		return self

	Utils.throw_story_exception(bad_cast_exception_message(new_type))
	return null

func _to_string() -> String:
	return "DivertTargetValue(" + self.target_path._to_string() + ")"

# ######################################################################## #
# GDScript extra methods
# ######################################################################## #

func is_class(type):
	return type == "DivertTargetValue" || .is_class(type)

func get_class():
	return "DivertTargetValue"

static func new_with(val):
	var value = DivertTargetValue().new()
	value._init_with(val)
	return value
