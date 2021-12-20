# ############################################################################ #
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

tool
extends WindowDialog

# A custom dialog showing a message and, optionally, a command output.
class_name InkRichDialog

# ############################################################################ #
# Nodes
# ############################################################################ #

onready var MessageLabel = $MarginContainer/VBoxContainer/MessageLabel
onready var AcceptButton = $MarginContainer/VBoxContainer/AcceptButton
onready var OutputPanel = $MarginContainer/VBoxContainer/OutputPanel
onready var OutputLabel = find_node("OutputLabel")

# ############################################################################ #
# Properties
# ############################################################################ #

## The message displayed in the dialog.
var message_text: String setget set_message_text, get_message_text
func set_message_text(text: String):
	MessageLabel.text = text
func get_message_text() -> String:
	return MessageLabel.text

## An output, often the result of a command, than can optionally be displayed
## in the dialog.
##
## Setting this property to null hides the corresponding panel in the dialog.
var output_text: String setget set_output_text, get_output_text
func set_output_text(text: String):
	OutputLabel.text = text
	OutputPanel.visible = !(text == null || text.length() == 0)
func get_output_text() -> String:
	return OutputLabel.text

# ############################################################################ #
# Overriden Methods
# ############################################################################ #

func _ready():
	AcceptButton.connect("pressed", self, "_accept_button_pressed")
	
	var font = _get_source_font()
	if font != null:
		OutputLabel.add_font_override("font", font)

# ############################################################################ #
# Signal Receivers
# ############################################################################ #

func _accept_button_pressed():
	self.get_parent().remove_child(self)
	self.queue_free()

# ############################################################################ #
# Private helpers
# ############################################################################ #

## Gets the monospaced font used by the editor.
func _get_source_font():
	var theme = _retrieve_base_theme()
	if theme:
		return theme.get_font("output_source", "EditorFonts")
	else:
		return null

## Gets the theme currently used by the editor.
func _retrieve_base_theme():
	var parent: Control = self

	while(parent != null && parent.theme == null):
		var older_parent = parent.get_parent()
		if older_parent is Control:
			parent = older_parent
		else:
			break
	
	return parent.theme
