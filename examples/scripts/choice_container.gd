# ############################################################################ #
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

extends MarginContainer

# ############################################################################ #
# Imports
# ############################################################################ #

var ChoiceButton = load("res://examples/scenes/button.tscn")

# ############################################################################ #
# Nodes
# ############################################################################ #

onready var ChoiceVBoxContainer = get_node("ChoiceVBoxContainer")

# ############################################################################ #
# Signal
# ############################################################################ #

signal choice_selected(index)

# ############################################################################ #
# Private properties
# ############################################################################ #

var _buttons = []

# ############################################################################ #
# Public Methods
# ############################################################################ #

func create_choices(choices):
	for choice in choices:
		var button = ChoiceButton.instance()
		button.text = choice.text
		button.connect("pressed", self, "_button_pressed", [button])

		_buttons.append(button)
		ChoiceVBoxContainer.add_child(button)

# ############################################################################ #
# Private Methods
# ############################################################################ #

func _button_pressed(button):
	var index = _buttons.find(button)

	if index != -1:
		emit_signal("choice_selected", index)
