@tool
# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

extends Window

# A custom dialog showing a message and, optionally, a command output.

# Hiding this type to prevent registration of "private" nodes.
# See https://github.com/godotengine/godot-proposals/issues/1047
# class_name InkRichDialog

# ############################################################################ #
# Nodes
# ############################################################################ #

@onready var _margin_container = $MarginContainer
@onready var _vbox_container = $MarginContainer/VBoxContainer
@onready var _message_label = $MarginContainer/VBoxContainer/MessageLabel
@onready var _accept_button = $MarginContainer/VBoxContainer/AcceptButton
@onready var _output_panel = $MarginContainer/VBoxContainer/OutputPanel
@onready var _output_label = find_child("OutputLabel")

# ############################################################################ #
# Properties
# ############################################################################ #

## The message displayed in the dialog.
var message_text: String: get = get_message_text, set = set_message_text
func set_message_text(text: String):
	_message_label.text = text
func get_message_text() -> String:
	return _message_label.text

## An output, often the result of a command, than can optionally be displayed
## in the dialog.
##
## Setting this property to null hides the corresponding panel in the dialog.
var output_text: String: get = get_output_text, set = set_output_text
func set_output_text(text: String):
	_output_label.text = text
	_output_label.visible = !(text == null || text.length() == 0)
func get_output_text() -> String:
	return _output_label.text

# ############################################################################ #
# Overriden Methods
# ############################################################################ #

func _ready():
	_accept_button.connect("pressed", Callable(self, "_accept_button_pressed"))

	var font = _get_source_font()
	if font != null:
		_output_panel.add_theme_font_override("font", font)

# ############################################################################ #
# Methods
# ############################################################################ #

func update_layout(scale: float) -> void:
	_margin_container.add_theme_constant_override("offset_right", 10 * scale)
	_margin_container.add_theme_constant_override("offset_top", 10 * scale)
	_margin_container.add_theme_constant_override("offset_left", 10 * scale)
	_margin_container.add_theme_constant_override("offset_bottom", 10 * scale)
	_vbox_container.add_theme_constant_override("separation", 10 * scale)


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
	var base_theme = _retrieve_base_theme()
	if base_theme:
		return base_theme.get_font("output_source", "EditorFonts")
	else:
		return null

## Gets the theme currently used by the editor.
func _retrieve_base_theme():
	var parent = self

	while(parent != null && parent.theme == null):
		var older_parent = parent.get_parent()
		if older_parent is Control:
			parent = older_parent
		else:
			break

	return parent.theme
