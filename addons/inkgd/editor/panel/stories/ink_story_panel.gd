# ############################################################################ #
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

tool
extends Control

class_name InkStoryPanel

# ############################################################################ #
# Imports
# ############################################################################ #

var InkConfiguration = load("res://addons/inkgd/editor/common/ink_configuration.gd")

var InkCompilationConfiguration = load("res://addons/inkgd/editor/common/executors/structures/ink_compilation_configuration.gd")
var InkCompiler = load("res://addons/inkgd/editor/common/executors/ink_compiler.gd")

var InkRichDialog = load("res://addons/inkgd/editor/panel/common/ink_rich_dialog.tscn")
var InkStoryConfigurationScene = load("res://addons/inkgd/editor/panel/stories/ink_story_configuration.tscn")
var EmptyStateContainerScene = load("res://addons/inkgd/editor/panel/stories/empty_state_container.tscn")

# ############################################################################ #
# Enums
# ############################################################################ #

enum FileDialogSelection {
	UNKNOWN,
	SOURCE_FILE,
	TARGET_FILE,
	WATCHED_FOLDER
}

# ############################################################################ #
# Properties
# ############################################################################ #

var editor_interface: InkEditorInterface
var configuration: InkConfiguration
var progress_texture: AnimatedTexture

# ############################################################################ #
# Private Properties
# ############################################################################ #

var _compilers: Dictionary = {}

var _file_dialog = EditorFileDialog.new()

## Configuration item for which the FileDialog is currently shown.
##
## Unknown by default.
var _file_dialog_selection = FileDialogSelection.UNKNOWN

## The story index for which the FileDialog is currenlty shown.
##
## -1 by default or when the file dialog currently displayed doesn't
## concern the stories source/target files.
var _file_dialog_selection_story_index = -1

var _current_story_node = null

# ############################################################################ #
# Nodes
# ############################################################################ #

onready var _empty_state_container = EmptyStateContainerScene.instance()

onready var _build_all_button = find_node("BuildAllButton")
onready var _add_new_story_button = find_node("AddNewStoryButton")

onready var _story_configuration_container = find_node("StoryConfigurationVBoxContainer")

# ############################################################################ #
# Overrides
# ############################################################################ #

func _ready():
	# FIXME: This needs investigating.
	# Sanity check. It seems the editor instantiates tools script on their
	# own, probably to add them to its tree. In that case, they won't have
	# their dependencies injected, so we're not doing anything.
	if editor_interface == null || configuration == null || progress_texture == null:
		print("Ink Stories Tab: dependencies not met, ignoring.")
		return

	configuration.connect("compilation_mode_changed", self, "_compilation_mode_changed")

	var filesystem = editor_interface._editor_interface.get_resource_filesystem()
	filesystem.connect("resources_reimported", self, "_resources_reimported")

	_story_configuration_container.add_child(_empty_state_container)
	add_child(_file_dialog)

	var add_icon = get_icon("Add", "EditorIcons")
	_add_new_story_button.icon = add_icon

	_load_story_configurations()
	_connect_signals()

	_compilation_mode_changed(configuration.compilation_mode)

# ############################################################################ #
# Signal Receivers
# ############################################################################ #

func _resources_reimported(resources):
	call_deferred("_recompile_if_necessary", resources)

func _compilation_mode_changed(compilation_mode: int):
	var show_folder = (compilation_mode == InkConfiguration.BuildMode.AFTER_CHANGE)

	for child in _story_configuration_container.get_children():
		child.show_watched_folder(show_folder)

func _source_file_button_pressed(node: InkStoryConfiguration):
	_reset_file_dialog()

	_file_dialog_selection = FileDialogSelection.SOURCE_FILE
	_file_dialog_selection_story_index = _get_story_configuration_index(node)

	_file_dialog.set_mode(FileDialog.MODE_OPEN_FILE)
	_file_dialog.set_access(FileDialog.ACCESS_FILESYSTEM)
	_file_dialog.add_filter("*.ink;Ink source file")
	_file_dialog.popup_centered(Vector2(1280, 800) * editor_interface.scale)


func _target_file_button_pressed(node: InkStoryConfiguration):
	_reset_file_dialog()

	_file_dialog_selection = FileDialogSelection.TARGET_FILE
	_file_dialog_selection_story_index = _get_story_configuration_index(node)

	_file_dialog.set_mode(FileDialog.MODE_SAVE_FILE)
	_file_dialog.set_access(FileDialog.ACCESS_FILESYSTEM)
	_file_dialog.add_filter("*.json;Compiled Ink story")
	_file_dialog.popup_centered(Vector2(1280, 800) * editor_interface.scale)

func _watched_folder_button_pressed(node: InkStoryConfiguration):
	_reset_file_dialog()

	_file_dialog_selection = FileDialogSelection.WATCHED_FOLDER
	_file_dialog_selection_story_index = _get_story_configuration_index(node)

	_file_dialog.set_mode(FileDialog.MODE_OPEN_DIR)
	_file_dialog.set_access(FileDialog.ACCESS_FILESYSTEM)
	_file_dialog.popup_centered(Vector2(1280, 800) * editor_interface.scale)


func _build_all_button_pressed():
	_compile_all_stories()


func _add_new_story_button_pressed():
	_add_new_story_configuration()


func _configuration_changed(node):
	_persist_configuration()


func _remove_button_pressed(node):
	var index = _get_story_configuration_index(node)
	configuration.remove_story_configuration_at_index(index)

	# TODO: Rebuild from scratch instead.
	var parent = node.get_parent()
	if parent != null:
		parent.remove_child(node)
		node.queue_free()

	if _story_configuration_container.get_child_count() == 0:
		_story_configuration_container.add_child(_empty_state_container)
	else:
		var i = 0
		for child in _story_configuration_container.get_children():
			if child is InkStoryConfiguration:
				child.story_label.text = "Story %d" % (i + 1)
			i += 1

	_persist_configuration()


func _build_button_pressed(node):
	var index = _get_story_configuration_index(node)
	var story_configuration = configuration.get_story_configuration_at_index(index)

	if story_configuration == null:
		printerr("No configurations found for Story %d" % (index + 1))
		return

	_compile_story(story_configuration, node)


func _compile_story(story_configuration, node = null):
	var source_file_path = configuration.get_source_file_path(story_configuration)
	var target_file_path = configuration.get_target_file_path(story_configuration)

	if node != null:
		_current_story_node = node

		node.build_button.icon = progress_texture
		node.build_button.disabled = true

	var compiler_configuration = InkCompilationConfiguration.new(
			configuration,
			true,
			node != null,
			source_file_path,
			target_file_path
	)
	var compiler = InkCompiler.new(compiler_configuration)

	_compilers[compiler.identifier] = compiler
	compiler.connect("story_compiled", self, "_handle_compilation_result")
	compiler.compile_story()


func _compile_all_stories():
	# TODO: implement.
	pass


func _on_file_selected(path: String):
	var index = _file_dialog_selection_story_index

	match _file_dialog_selection:
		FileDialogSelection.SOURCE_FILE:
			var story_configuration = _get_story_configuration_at_index(index)
			if story_configuration == null:
				return

			var localized_path = ProjectSettings.localize_path(path)
			var source_line_edit = story_configuration.source_file_line_edit

			source_line_edit.text = localized_path
			source_line_edit.update()

			if story_configuration.target_file_line_edit.text.empty():
				var target_line_edit = story_configuration.target_file_line_edit
				target_line_edit.text = localized_path + ".json"
				target_line_edit.update()

			if story_configuration.watched_folder_line_edit.text.empty():
				var watched_folder_line_edit = story_configuration.watched_folder_line_edit
				watched_folder_line_edit.text = localized_path.get_base_dir()
				watched_folder_line_edit.update()

			_persist_configuration()

		FileDialogSelection.TARGET_FILE:
			var story_configuration = _get_story_configuration_at_index(index)
			if story_configuration == null:
				return

			var localized_path = ProjectSettings.localize_path(path)
			var line_edit = story_configuration.source_file_line_edit

			line_edit.text = localized_path
			line_edit.update()
			_persist_configuration()

		FileDialogSelection.WATCHED_FOLDER:
			var story_configuration = _get_story_configuration_at_index(index)
			if story_configuration == null:
				return

			var localized_path = ProjectSettings.localize_path(path)
			var line_edit = story_configuration.watched_folder_line_edit

			line_edit.text = localized_path
			line_edit.update()
			_persist_configuration()

		_:
			printerr("Unknown FileDialogSelection, failed to save FileDialog file.")

	_file_dialog_selection = FileDialogSelection.UNKNOWN

# ############################################################################ #
# Private helpers
# ############################################################################ #

func _reset_file_dialog():
	_file_dialog.current_file = ""
	_file_dialog.clear_filters()


func _persist_configuration():
	configuration.stories.clear()

	if _empty_state_container.get_parent() == null:
		configuration.stories.clear()
		for node in _story_configuration_container.get_children():
			if !(node is InkStoryConfiguration):
				continue

			configuration.append_new_story_configuration(
					node.source_file_line_edit.text,
					node.target_file_line_edit.text,
					node.watched_folder_line_edit.text
			)

	configuration.persist()


func _load_story_configurations():
	for story_configuration in configuration.stories:
		var node = _add_new_story_configuration()

		node.source_file_line_edit.text = configuration.get_source_file_path(story_configuration)
		node.target_file_line_edit.text = configuration.get_target_file_path(story_configuration)
		node.watched_folder_line_edit.text = configuration.get_watched_folder_path(story_configuration)


func _add_new_story_configuration() -> InkStoryConfiguration:
	var story_configuration = InkStoryConfigurationScene.instance()

	story_configuration.editor_interface = editor_interface

	story_configuration.connect("configuration_changed", self, "_configuration_changed")
	story_configuration.connect("remove_button_pressed", self, "_remove_button_pressed")
	story_configuration.connect("build_button_pressed", self, "_build_button_pressed")
	story_configuration.connect("source_file_button_pressed", self, "_source_file_button_pressed")
	story_configuration.connect("target_file_button_pressed", self, "_target_file_button_pressed")
	story_configuration.connect("watched_folder_button_pressed", self, "_watched_folder_button_pressed")

	if _empty_state_container.get_parent() != null:
		_story_configuration_container.remove_child(_empty_state_container)

	_story_configuration_container.add_child(story_configuration)

	var count = _story_configuration_container.get_child_count()
	story_configuration.story_label.text = "Story %d" % count

	return story_configuration


func _handle_compilation_result(result):
	if _current_story_node != null:
		var button = _current_story_node.build_button
		button.icon = null
		button.disabled = false
		_current_story_node = null

	if result.user_triggered:
		if result.success:
			if result.output && !result.output.empty():
				var dialog = InkRichDialog.instance()
				add_child(dialog)

				dialog.window_title = "Success!"
				dialog.message_text = "The story was successfully compiled."
				dialog.output_text = result.output

				dialog.popup_centered(Vector2(700, 400) * editor_interface.scale)
			else:
				var dialog = AcceptDialog.new()
				add_child(dialog)

				dialog.window_title = "Success!"
				dialog.dialog_text = "The story was successfully compiled."

				dialog.popup_centered()

			_reimport_compiled_stories()
		else:
			var dialog = InkRichDialog.instance()
			add_child(dialog)

			dialog.window_title = "Error"
			dialog.message_text = "The story could not be compiled. See inklecate's output below."
			dialog.output_text = result.output

			dialog.popup_centered(Vector2(700, 400) * editor_interface.scale)
	else:
		_reimport_compiled_stories()

	if _compilers.has(result.identifier):
		_compilers.erase(result.identifier)


func _reimport_compiled_stories():
	editor_interface.scan_file_system()


func _get_story_configuration_index(node: InkStoryConfiguration) -> int:
	return _story_configuration_container.get_children().find(node)


func _get_story_configuration_at_index(index: int) -> InkStoryConfiguration:
	if index >= 0 && _story_configuration_container.get_child_count():
		return _story_configuration_container.get_children()[index]

	return null

func _recompile_if_necessary(resources: PoolStringArray):
	yield(get_tree().create_timer(0.5), "timeout")

	for story_configuration in configuration.stories:
		var watched_folder_path: String = configuration.get_watched_folder_path(story_configuration)

		if watched_folder_path.empty():
			return

		for resource in resources:
			if resource.begins_with(watched_folder_path):
				_compile_story(story_configuration)
				break

func _connect_signals():
	_build_all_button.connect("pressed", self, "_build_all_button_pressed")
	_add_new_story_button.connect("pressed", self, "_add_new_story_button_pressed")

	_file_dialog.connect("file_selected", self, "_on_file_selected")
	_file_dialog.connect("dir_selected", self, "_on_file_selected")

