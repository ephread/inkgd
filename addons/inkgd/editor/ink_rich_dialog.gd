# warning-ignore-all:return_value_discarded

# ############################################################################ #
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

tool
extends WindowDialog

# ############################################################################ #
# Nodes
# ############################################################################ #

onready var MessageLabel = find_node("MessageLabel")
onready var OutputPanel = find_node("OutputPanel")
onready var OutputLabel = find_node("OutputLabel")
onready var AcceptButton = find_node("AcceptButton")

# ############################################################################ #
# Properties
# ############################################################################ #

var message_text setget set_message_text, get_message_text
func set_message_text(text: String):
	MessageLabel.text = text
func get_message_text() -> String:
	return MessageLabel.text

var output_text setget set_output_text, get_output_text
func set_output_text(text: String):
	OutputLabel.text = text
	OutputPanel.visible = !(text == null || text.length() == 0)
func get_output_text() -> String:
	return OutputLabel.text

# ############################################################################ #
# Overrides
# ############################################################################ #

func _ready():
	AcceptButton.connect("pressed", self, "_accept_button_pressed")
	OutputLabel.add_font_override("font", _get_source_font())

# ############################################################################ #
# Signal Receivers
# ############################################################################ #

func _accept_button_pressed():
	self.get_parent().remove_child(self)
	self.queue_free()

# ############################################################################ #
# Private helpers
# ############################################################################ #

func _retrieve_base_theme():
	var parent = self
	while(parent && parent.theme == null):
		parent = parent.get_parent()

	return parent.theme

func _get_source_font():
	return _retrieve_base_theme().get_font("output_source", "EditorFonts")
