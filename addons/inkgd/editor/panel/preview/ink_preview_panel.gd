# ############################################################################ #
# Copyright © 2018-2022 Paul Joannon
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

tool
extends Control

# Hiding this type to prevent registration of "private" nodes.
# See https://github.com/godotengine/godot-proposals/issues/1047
# class_name InkPreviewPanel

# ############################################################################ #
# Imports
# ############################################################################ #

var InkPlayerFactory := preload("res://addons/inkgd/ink_player_factory.gd") as GDScript

# ############################################################################ #
# Enums
# ############################################################################ #

enum StoryOrigin {
	CONFIGURATION,
	FILE
}

# ############################################################################ #
# Constants
# ############################################################################ #

const NAME = "name"
const STORY_ORIGIN = "story_origin"
const FILE_PATH = "file_path"

# ############################################################################ #
# Public Properties
# ############################################################################ #

var editor_interface: InkEditorInterface
var configuration: InkConfiguration
var progress_texture: AnimatedTexture

# ############################################################################ #
# Private Properties
# ############################################################################ #

var _scrollbar_max_value = -1
var _current_story_index = -1

var _custom_stories: Array = []
var _available_stories: Array = []

var _file_dialog = EditorFileDialog.new()

var _ink_player = InkPlayerFactory.create()

# ############################################################################ #
# On Ready | Private Properties
# ############################################################################ #

onready var _play_icon = get_icon("Play", "EditorIcons")

# ############################################################################ #
# On Ready | Private Nodes
# ############################################################################

onready var _command_strip = find_node("CommandStripHBoxContainer")

onready var _pick_story_button = _command_strip.get_node("PickStoryOptionButton")
onready var _load_story_button = _command_strip.get_node("LoadStoryButton")
onready var _start_button = _command_strip.get_node("StartButton")
onready var _stop_button = _command_strip.get_node("StopButton")
onready var _clear_button = _command_strip.get_node("ClearButton")

onready var _scroll_container = find_node("ScrollContainer")
onready var _story_container = _scroll_container.get_node("MarginContainer/StoryVBoxContainer")

onready var _choice_area_container = find_node("ChoicesAreaVBoxContainer")
onready var _choices_container = _choice_area_container.get_node("ChoicesVBoxContainer")

# ############################################################################ #
# Overrides
# ############################################################################ #

func _ready():
	# FIXME: This needs investigating.
	# Sanity check. It seems the editor instantiates tools script on their
	# own, probably to add them to its tree. In that case, they won't have
	# their dependencies injected, so we're not doing anything.
	if editor_interface == null || configuration == null || progress_texture == null:
		print("[inkgd] [INFO] Ink Preview Tab: dependencies not met, ignoring.")
		return

	add_child(_ink_player)

	_connect_signals()
	_apply_configuration()
	_update_story_picker()

	var load_icon = get_icon("Load", "EditorIcons")
	var stop_icon = get_icon("Stop", "EditorIcons")
	var clear_icon = get_icon("Clear", "EditorIcons")

	_start_button.icon = _play_icon
	_load_story_button.icon = load_icon
	_stop_button.icon = stop_icon
	_clear_button.icon = clear_icon

	_stop_button.visible = false

	_choice_area_container.rect_min_size = Vector2(200, 0) * editor_interface.scale
	_choice_area_container.visible = false

	_file_dialog.connect("file_selected", self, "_on_file_selected")
	add_child(_file_dialog)

# ############################################################################ #
# Signal Receivers
# ############################################################################ #

func _start_button_pressed():
	var file_path = _get_current_story_file_path()
	if file_path == null:
		return

	print("[inkgd] [INFO] Previewing %s" % file_path)
	_clear_content()

	_ink_player.destroy()
	_ink_player.ink_file = load(file_path)

	_start_button.icon = progress_texture
	_disable_command_strip(true)

	_ink_player.create_story()


func _stop_button_pressed():
	_start_button.visible = true
	_stop_button.visible = false
	_choice_area_container.visible = false

	_ink_player.destroy()

	_clear_choices()
	_clear_content()


func _story_loaded(successfully: bool):
	_disable_command_strip(false)
	_start_button.icon = _play_icon

	if !successfully:
		return

	_start_button.visible = false
	_stop_button.visible = true

	_ink_player.allow_external_function_fallbacks = true
	_continue_story()

func _pick_story_button_selected(index):
	if _current_story_index != index:
		_stop_button_pressed()

	_current_story_index = index


func _load_story_button_pressed():
	_file_dialog.set_mode(FileDialog.MODE_OPEN_FILE)
	_file_dialog.set_access(FileDialog.ACCESS_RESOURCES)
	_file_dialog.add_filter("*.json;Compiled Ink story")
	_file_dialog.popup_centered(Vector2(1280, 800) * editor_interface.scale)


func _choice_button_pressed(index):
	_clear_choices()

	_ink_player.choose_choice_index(index)
	_continue_story()


func _on_file_selected(path: String):
	if _custom_stories.has(path):
		return

	for story_configuration in self.configuration.stories:
		var target_file_path = self.configuration.get_target_file_path(story_configuration)
		if target_file_path == path:
			return

	_custom_stories.append(path)
	_apply_configuration()
	_update_story_picker(path)


func _scrollbar_changed():
	var max_value = _scroll_container.get_v_scrollbar().max_value

	if _scrollbar_max_value == max_value && _scrollbar_max_value != -1:
		return

	_scrollbar_max_value = max_value
	_scroll_container.scroll_vertical = max_value


func _configuration_changed():
	# Cleaning everything on configuration change may end up being frustrating.
	# But for now, it's going to make everybody's life easier.
	_stop_button_pressed()
	_apply_configuration()
	_update_story_picker()


# ############################################################################ #
# Private Methods
# ############################################################################ #

func _apply_configuration():
	_available_stories.clear()

	_current_story_index = -1
	_pick_story_button.selected = _current_story_index

	var i = 0
	for story_configuration in self.configuration.stories:
		var target_file_path = self.configuration.get_target_file_path(story_configuration)
		if target_file_path != null && !target_file_path.empty():
			_available_stories.append({
				NAME: "Story %d - %s" % [i + 1, target_file_path.get_file()],
				FILE_PATH: target_file_path,
				STORY_ORIGIN: StoryOrigin.CONFIGURATION
			})
		i += 1

	var j = 0
	for custom_story_path in _custom_stories:
		if custom_story_path != null && !custom_story_path.empty():
			_available_stories.append({
				NAME: custom_story_path.get_file(),
				FILE_PATH: ProjectSettings.localize_path(custom_story_path),
				STORY_ORIGIN: StoryOrigin.FILE
			})
		j += 1


func _update_story_picker(selected_path = null):
	_pick_story_button.clear()

	var i = 0
	for story in _available_stories:
		_pick_story_button.add_item(story[NAME], i)
		if selected_path != null && story[FILE_PATH] == selected_path:
			_current_story_index = i
			_pick_story_button.selected = _current_story_index
		i += 1

	if _available_stories.size() > 0:
		if _current_story_index == -1:
			_current_story_index = 0
			_pick_story_button.selected = _current_story_index

		_pick_story_button.visible = true
	else:
		_current_story_index = -1
		_pick_story_button.selected = _current_story_index

		_pick_story_button.visible = false


func _continue_story():
	while _ink_player.can_continue:
		var text = _ink_player.continue_story()

		if text.right(text.length() - 1) == "\n":
			text.erase(text.length() - 1, 1)

		var text_label = Label.new()
		text_label.autowrap = true
		text_label.text = text

		_story_container.add_child(text_label)

		var tags = _ink_player.current_tags
		if !tags.empty():
			var tag_label = Label.new()
			tag_label.autowrap = true
			tag_label.align = Label.ALIGN_CENTER
			tag_label.text = "# " + PoolStringArray(tags).join(", ")
			tag_label.add_color_override("font_color", Color(1, 1, 1, 0.4))

			_story_container.add_child(tag_label)

	var separator = HSeparator.new()
	_story_container.add_child(separator)

	if _ink_player.current_choices.size() > 0:
		var i = 0
		for choice in _ink_player.current_choices:
			var button = Button.new()
			button.text = choice
			button.connect("pressed", self, "_choice_button_pressed", [i])

			_choices_container.add_child(button)
			i += 1

		_choice_area_container.visible = true
	else:
		var label = Label.new()
		label.text = "End of the story."
		label.align = Label.ALIGN_RIGHT

		_story_container.add_child(label)

		_choice_area_container.visible = false


func _get_current_story_file_path():
	if _current_story_index >= 0 && _current_story_index < _available_stories.size():
		return _available_stories[_current_story_index][FILE_PATH]
	else:
		return null


func _clear_content():
	for child in _story_container.get_children():
		_story_container.remove_child(child)
		child.queue_free()


func _clear_choices():
	for child in _choices_container.get_children():
		_choices_container.remove_child(child)
		child.queue_free()

func _disable_command_strip(disabled: bool):
	_pick_story_button.disabled = disabled
	_load_story_button.disabled = disabled
	_start_button.disabled = disabled
	_stop_button.disabled = disabled
	_clear_button.disabled = disabled

func _connect_signals():
	if configuration != null:
		var is_connected = configuration.is_connected(
				"story_configuration_changed",
				self,
				"_configuration_changed"
		)

		if !is_connected:
			configuration.connect(
					"story_configuration_changed",
					self,
					"_configuration_changed"
			)

	_ink_player.connect("loaded", self, "_story_loaded")
	_pick_story_button.connect("item_selected", self, "_pick_story_button_selected")
	_load_story_button.connect("pressed", self, "_load_story_button_pressed")
	_start_button.connect("pressed", self, "_start_button_pressed")
	_stop_button.connect("pressed", self, "_stop_button_pressed")
	_clear_button.connect("pressed", self, "_clear_content")

	_scroll_container.get_v_scrollbar().connect("changed", self, "_scrollbar_changed")
