# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

tool
extends PopupDialog

# A custom dialog showing a progress bar.

# Hiding this type to prevent registration of "private" nodes.
# See https://github.com/godotengine/godot-proposals/issues/1047
# class_name InkProgressDialog

# ############################################################################ #
# Nodes
# ############################################################################ #

onready var _margin_container = $MarginContainer
onready var _vbox_container = $MarginContainer/VBoxContainer
onready var _title_label = $MarginContainer/VBoxContainer/TitleLabel
onready var _progress_bar = $MarginContainer/VBoxContainer/ProgressBar
onready var _current_step_label = $MarginContainer/VBoxContainer/CurrentStepLabel

# ############################################################################ #
# Properties
# ############################################################################ #

## The title of the progress.
var title: String setget set_title, get_title
func set_title(text: String):
	_title_label.text = text
func get_title() -> String:
	return _title_label.text

## The name of the current step.
var current_step_name: String setget set_current_step_name, get_current_step_name
func set_current_step_name(text: String):
	_current_step_label.text = text
func get_current_step_name() -> String:
	return _current_step_label.text

## The current progress.
var progress: float setget set_progress, get_progress
func set_progress(progress: float):
	_progress_bar.value = progress
func get_progress() -> float:
	return _progress_bar.value

func update_layout(scale: float) -> void:
	_margin_container.add_constant_override("margin_right", 10 * scale)
	_margin_container.add_constant_override("margin_top", 10 * scale)
	_margin_container.add_constant_override("margin_left", 10 * scale)
	_margin_container.add_constant_override("margin_bottom", 10 * scale)
	_vbox_container.add_constant_override("separation", 5 * scale)
