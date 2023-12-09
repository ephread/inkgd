# ############################################################################ #
# Copyright © 2019-2023 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends Node

class_name InkRuntimeManager

# ############################################################################ #

# Hiding this type to prevent registration of "private" nodes.
# See https://github.com/godotengine/godot-proposals/issues/1047
# class_name InkRuntime

static func init(root_node, stop_on_error = true):
	var _ink_runtime: Node = InkUtils.InkRuntime
	if _ink_runtime != null:
		_ink_runtime.stop_execution_on_exception = stop_on_error
		_ink_runtime.stop_execution_on_error = stop_on_error

		return _ink_runtime

	_ink_runtime = load("res://addons/inkgd/ink_runtime.gd").new()

	_ink_runtime.stop_execution_on_exception = stop_on_error
	_ink_runtime.stop_execution_on_error = stop_on_error

	root_node.add_child(_ink_runtime)

	return _ink_runtime

static func deinit(root_node):
	var _ink_runtime = InkUtils.InkRuntime
	root_node.remove_child(_ink_runtime)
	_ink_runtime.queue_free()
