# ############################################################################ #
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends Node

static func init(root_node):
	if root_node.has_node("__InkRuntime"):
		return

	var InkRuntime = load("res://addons/inkgd/runtime/static/ink_runtime.gd")
	root_node.add_child(InkRuntime.new())

static func deinit(root_node):
	var _ink_runtime = root_node.get_node("__InkRuntime")
	root_node.remove_child(_ink_runtime)
