# ############################################################################ #
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

tool
extends Node

class_name InkRuntime

static func init(root_node, should_pause_on_error = true):
	if root_node.has_node("__InkRuntime"):
		return root_node.get_node("__InkRuntime")

	var InkRuntime = load("res://addons/inkgd/runtime/static/ink_runtime.gd")
	var _ink_runtime = InkRuntime.new()

	_ink_runtime.should_pause_execution_on_exception = should_pause_on_error
	_ink_runtime.should_pause_execution_on_error = should_pause_on_error

	root_node.add_child(_ink_runtime)

	return _ink_runtime

static func deinit(root_node):
	var _ink_runtime = root_node.get_node("__InkRuntime")
	root_node.remove_child(_ink_runtime)
	_ink_runtime.queue_free()
