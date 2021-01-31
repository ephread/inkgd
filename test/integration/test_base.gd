# ############################################################################ #
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://addons/gut/test.gd"

# ############################################################################ #
# Imports
# ############################################################################ #

var InkRuntime = load("res://addons/inkgd/runtime.gd")
var Story = load("res://addons/inkgd/runtime/story.gd")

# ############################################################################ #

var ink_runtime

func before_all():
	InkRuntime.init(get_tree().root, false)
	ink_runtime = get_tree().root.get_node("__InkRuntime")

func after_all():
	InkRuntime.deinit(get_tree().root)
	ink_runtime = null

func after_each():
	ink_runtime.should_interrupt = false

# ############################################################################ #

func load_file(file_name):
	var data_file = File.new()
	var path = "res://test/fixture/compiled/" + _prefix() + file_name + ".ink.json"
	if data_file.open(path, File.READ) != OK:
		return null

	var data_text = data_file.get_as_text()
	data_file.close()

	return data_text

func _prefix():
	return ""
