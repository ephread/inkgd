# warning-ignore-all:unused_class_variable
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

var path_string_on_choice: String:
	get:
		# TODO: handle null case?
		return target_path._to_string()

	set(value):
		target_path = InkPath.new_with_components_string(value)


var source_path = null # String?


var index: int = 0


var target_path: InkPath = null


var thread_at_generation: InkCallStack.InkThread = null


var original_thread_index: int = 0


var is_invisible_default: bool = false


var tags = null # Array<String>?


# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_ink_class(type):
	return type == "Choice" || super.is_ink_class(type)


func get_ink_class():
	return "Choice"
