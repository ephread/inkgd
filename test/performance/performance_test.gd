# warning-ignore-all:return_value_discarded
# ############################################################################ #
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

# Use test/performance/ink/generate_ipsuminious.py to generate the story before
# running this test. This test profiles how long it takes to create a story.

extends Node

# ############################################################################ #
# Imports
# ############################################################################ #

var ErrorType = preload("res://addons/inkgd/runtime/error.gd").ErrorType
var Profiler = load("res://examples/scenes/common/profiler.gd")


# ############################################################################ #
# Private Properties
# ############################################################################ #

var _profiler: Profiler = Profiler.new()


# ############################################################################ #
# Node
# ############################################################################ #

onready var _created_label = $MarginContainer/CenterContainer/Label
onready var _loading_animation_player = $LoadingAnimationPlayer
onready var _ink_player = $InkPlayer


# ############################################################################ #
# Lifecycle
# ############################################################################ #

func _ready():
	_ink_player.connect("loaded", self, "_loaded")
	_profiler.start()
	_ink_player.create_story()


# ############################################################################ #
# Signal Receivers
# ############################################################################ #

func _loaded(successfully: bool):
	if !successfully:
		printerr("Could not create Ipsumimious.")
		return

	_profiler.stop()

	var text = "Created ipsumimious in %d ms." % _profiler.milliseconds_elaspsed
	print(text)

	_created_label.text = text
	_created_label.show()

	remove_child(_loading_animation_player)
	_loading_animation_player.queue_free()
	_loading_animation_player = null
