# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends InkObject

class_name InkChoice

# ############################################################################ #

var text: String

var path_string_on_choice: String: get = get_path_string_on_choice, set = set_path_string_on_choice
func get_path_string_on_choice() -> String:
	return target_path._to_string()

func set_path_string_on_choice(value: String):
	target_path = InkPath.new_with_components_string(value)

# String?
var source_path = null

var index: int = 0

var target_path: InkPath = null

var thread_at_generation: InkCallStack.InkThread = null

var original_thread_index: int = 0

var is_invisible_default: bool = false
