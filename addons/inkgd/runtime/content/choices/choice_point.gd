# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends InkObject

class_name InkChoicePoint

# ############################################################################ #

# () -> InkPath
# (InkPath) -> void
var path_on_choice: InkPath: get = get_path_on_choice, set = set_path_on_choice
func get_path_on_choice() -> InkPath:
	if _path_on_choice != null && _path_on_choice.is_relative:
		var choice_target_obj = choice_target
		if choice_target_obj:
			_path_on_choice = choice_target_obj.path

	return _path_on_choice
func set_path_on_choice(value: InkPath):
	_path_on_choice = value

var _path_on_choice: InkPath = null

# ############################################################################ #

var choice_target: InkContainer: get = get_choice_target
func get_choice_target() -> InkContainer:
	var cont = resolve_path(_path_on_choice).container
	return cont

# ############################################################################ #

var path_string_on_choice: String:
	get:
		return compact_path_string(path_on_choice)
	set(value):
		path_on_choice = InkPath.new_with_components_string(value)

# ############################################################################ #

var has_condition: bool
var has_start_content: bool
var has_choice_only_content: bool
var once_only: bool
var is_invisible_default: bool

# ############################################################################ #

var flags: int: get = get_flags, set = set_flags
func get_flags() -> int:
	var flags: int = 0

	if has_condition:
		flags |= 1
	if has_start_content:
		flags |= 2
	if has_choice_only_content:
		flags |= 4
	if is_invisible_default:
		flags |= 8
	if once_only:
		flags |= 16

	return flags
func set_flags(value: int):
	has_condition = (value & 1) > 0
	has_start_content = (value & 2) > 0
	has_choice_only_content = (value & 4) > 0
	is_invisible_default = (value & 8) > 0
	once_only = (value & 16) > 0

# ############################################################################ #

func _init(once_only: bool = true):
	self.once_only = once_only

func _to_string() -> String:
	var target_line_num = debug_line_number_of_path(path_on_choice)
	var target_string = path_on_choice._to_string()

	if target_line_num != null:
		target_string = " line %d(%s)" % [target_line_num, target_string]

	return "Choice: -> %s" % target_string
