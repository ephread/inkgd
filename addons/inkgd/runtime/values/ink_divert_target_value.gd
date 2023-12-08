# warning-ignore-all:shadowed_variable
# warning-ignore-all:unused_class_variable
# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2023 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends InkValue

class_name InkDivertTargetValue

# ############################################################################ #

var target_path : get = get_target_path, set = set_target_path # InkPath
func get_target_path():
	return value
func set_target_path(value):
	self.value = value

func get_value_type():
	return Ink.ValueType.DIVERT_TARGET

func get_is_truthy():
	InkUtils.throw_exception("Shouldn't be checking the truthiness of a divert target")
	return false

func _init():
	value = null

# The method takes a `InkStoryErrorMetadata` object as a parameter that
# doesn't exist in upstream. The metadat are used in case an 'exception'
# is raised. For more information, see story.gd.
func cast(new_type, metadata = null):
	if new_type == self.value_type:
		return self

	InkUtils.throw_story_exception(bad_cast_exception_message(new_type), false, metadata)
	return null

func _to_string() -> String:
	return "DivertTargetValue(" + self.target_path._to_string() + ")"

# ######################################################################## #
# GDScript extra methods
# ######################################################################## #

func is_ink_class(type):
	return type == "DivertTargetValue" || super.is_ink_class(type)

func get_ink_class():
	return "DivertTargetValue"

static func new_with(val):
	var value = InkDivertTargetValue.new()
	value._init_with(val)
	return value
