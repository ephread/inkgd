# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://test/integration/test_base.gd"

# ############################################################################ #
# Private Properties
# ############################################################################ #

var _ink_player
var _exception_messages_raised := []

# ############################################################################ #
# Overrides
# ############################################################################ #

func before_each():
	super.before_each()

	_ink_player = InkPlayerFactory.create()
	get_tree().root.add_child(_ink_player)
	_ink_player.exception_raised.connect(_exception_raised)


func after_each():
	_exception_messages_raised = []
	get_tree().root.remove_child(_ink_player)
	_ink_player.exception_raised.disconnect(_exception_raised)
	_ink_player = null

	super.after_each()


# ############################################################################ #
# Methods
# ############################################################################ #

func _prefix():
	return "player/"


# ############################################################################ #
# Private Methods
# ############################################################################ #

func _exception_raised(message, stack_trace):
	_exception_messages_raised.append(message)
	printerr(message)

	for line in stack_trace:
		printerr(line)


func _load_story(name):
	_ink_player.ink_file = load_resource(name)
	_ink_player.loads_in_background = true
	_ink_player.create_story()

	var successfully = await _ink_player.loaded

	assert_true(successfully, "The story did not load correctly.")

func _can_run_mono():
	return type_exists("_GodotSharp")
