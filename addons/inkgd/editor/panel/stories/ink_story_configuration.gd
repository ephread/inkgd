# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

tool
extends VBoxContainer

# Hiding this type to prevent registration of "private" nodes.
# See https://github.com/godotengine/godot-proposals/issues/1047
# class_name InkStoryConfiguration

# ############################################################################ #
# Signals
# ############################################################################ #

signal configuration_changed(story_configuration)

signal remove_button_pressed(story_configuration)

signal build_button_pressed(story_configuration)

signal source_file_button_pressed(story_configuration)

signal target_file_button_pressed(story_configuration)

signal watched_folder_button_pressed(story_configuration)

# ############################################################################ #
# Properties
# ############################################################################ #

var editor_interface: InkEditorInterface = null

# ############################################################################ #
# Nodes
# ############################################################################ #

onready var story_label = find_node("StoryLabel")

onready var remove_button = find_node("RemoveButton")
onready var build_button = find_node("BuildButton")

onready var source_file_line_edit = find_node("SourceFileLineEdit")
onready var source_file_dialog_button = find_node("SourceFileDialogButton")

onready var target_file_line_edit = find_node("TargetFileLineEdit")
onready var target_file_dialog_button = find_node("TargetFileDialogButton")

onready var watched_folder_label = find_node("WatchedFolderLabel")
onready var watched_folder_container = find_node("WatchedFolderHBoxContainer")
onready var watched_folder_line_edit = find_node("WatchedFolderLineEdit")
onready var watched_folder_dialog_button = find_node("WatchedFolderDialogButton")

onready var background_color_rect = find_node("BackgroundColorRect")

# ############################################################################ #
# Overrides
# ############################################################################ #

func _ready():
	# FIXME: This needs investigating.
	# Sanity check. It seems the editor instantiates tools script on their
	# own, probably to add them to its tree. In that case, they won't have
	# their dependencies injected, so we're not doing anything.
	if editor_interface == null:
		return

	_apply_custom_header_color()
	_set_button_icons()
	_connect_signals()

	show_watched_folder(false)

# ############################################################################ #
# Signals
# ############################################################################ #

func _configuration_entered(new_text):
	_configuration_focus_exited()


func _configuration_focus_exited():
	emit_signal("configuration_changed", self)


func _remove_button_pressed():
	emit_signal("remove_button_pressed", self)


func _build_button_pressed():
	emit_signal("build_button_pressed", self)


func _source_file_button_pressed():
	emit_signal("source_file_button_pressed", self)


func _target_file_button_pressed():
	emit_signal("target_file_button_pressed", self)


func _watched_folder_button_pressed():
	emit_signal("watched_folder_button_pressed", self)

# ############################################################################ #
# Public Methods
# ############################################################################ #

func show_watched_folder(show: bool):
	watched_folder_label.visible = show
	watched_folder_container.visible = show

func disable_all_buttons(disable: bool):
	remove_button.disabled = disable
	build_button.disabled = disable


# ############################################################################ #
# Private Methods
# ############################################################################ #

func _apply_custom_header_color():
	var header_color = editor_interface.get_custom_header_color()
	if header_color != Color.transparent:
		background_color_rect.color = header_color


func _set_button_icons():
	var folder_icon = get_icon("Folder", "EditorIcons")
	source_file_dialog_button.icon = folder_icon
	target_file_dialog_button.icon = folder_icon
	watched_folder_dialog_button.icon = folder_icon

	var trash_icon = get_icon("Remove", "EditorIcons")
	remove_button.icon = trash_icon


func _connect_signals():
	source_file_line_edit.connect("text_entered", self, "_configuration_entered")
	source_file_line_edit.connect("focus_exited", self, "_configuration_focus_exited")

	target_file_line_edit.connect("text_entered", self, "_configuration_entered")
	target_file_line_edit.connect("focus_exited", self, "_configuration_focus_exited")

	source_file_dialog_button.connect("pressed", self, "_source_file_button_pressed")
	target_file_dialog_button.connect("pressed", self, "_target_file_button_pressed")
	watched_folder_dialog_button.connect("pressed", self, "_watched_folder_button_pressed")

	remove_button.connect("pressed", self, "_remove_button_pressed")
	build_button.connect("pressed", self, "_build_button_pressed")
