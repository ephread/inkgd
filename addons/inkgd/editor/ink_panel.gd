# warning-ignore-all:return_value_discarded

# ############################################################################ #
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

tool
extends Control

class_name InkPanel

# ############################################################################ #
# Imports
# ############################################################################ #

var InkCompiler = load("res://addons/inkgd/editor/ink_compiler.gd")
var InkRichDialog = load("res://addons/inkgd/editor/ink_rich_dialog.tscn")

# ############################################################################ #
# Enums
# ############################################################################ #

enum FileDialogSelectionEnum {
	UNKNOWN,
	MONO,
	EXECUTABLE,
	SOURCE_FILE,
	TARGET_FILE
}

# ############################################################################ #
# Constants
# ############################################################################ #

const BOM = "\ufeff"

# ############################################################################ #
# Properties
# ############################################################################ #

var configuration = InkConfiguration.new()
var editor_scale: float

# ############################################################################ #
# Private Properties
# ############################################################################ #

var _editor_scale: float = 1.0
var _progress_texture: AnimatedTexture
var _compilers: Dictionary = {}

# ############################################################################ #
# Nodes
# ############################################################################ #

onready var InkFileDialog = EditorFileDialog.new()
onready var FileDialogSelection = FileDialogSelectionEnum.UNKNOWN

onready var TestButton = find_node("TestButton")
onready var BuildButton = find_node("BuildButton")

onready var UseMonoLabel = find_node("UseMonoLabel")
onready var UseMonoCheckBox = find_node("UseMonoCheckBox")

onready var MonoLabel = find_node("MonoLabel")
onready var MonoHBoxContainer = find_node("MonoHBoxContainer")
onready var MonoLineEdit = find_node("MonoLineEdit")
onready var MonoDialogButton = find_node("MonoDialogButton")

onready var ExecutableLineEdit = find_node("ExecutableLineEdit")
onready var ExecutableDialogButton = find_node("ExecutableDialogButton")

onready var SourceFileLineEdit = find_node("SourceFileLineEdit")
onready var SourceFileDialogButton = find_node("SourceFileDialogButton")

onready var TargetFileLineEdit = find_node("TargetFileLineEdit")
onready var TargetFileDialogButton = find_node("TargetFileDialogButton")

# ############################################################################ #
# Overrides
# ############################################################################ #

func _init():
	_retrieve_editor_scale()
	configuration.retrieve()

func _ready():
	UseMonoCheckBox.connect("toggled", self, "_use_mono_toggled")

	MonoLineEdit.connect("text_entered", self, "_configuration_entered")
	ExecutableLineEdit.connect("text_entered", self, "_configuration_entered")
	SourceFileLineEdit.connect("text_entered", self, "_configuration_entered")
	TargetFileLineEdit.connect("text_entered", self, "_configuration_entered")

	MonoLineEdit.connect("focus_exited", self, "_configuration_focus_exited")
	ExecutableLineEdit.connect("focus_exited", self, "_configuration_focus_exited")
	SourceFileLineEdit.connect("focus_exited", self, "_configuration_focus_exited")
	TargetFileLineEdit.connect("focus_exited", self, "_configuration_focus_exited")

	MonoDialogButton.connect("pressed", self, "_mono_button_pressed")
	MonoDialogButton.icon = get_icon("Folder", "EditorIcons")
	ExecutableDialogButton.connect("pressed", self, "_executable_button_pressed")
	ExecutableDialogButton.icon = get_icon("Folder", "EditorIcons")
	SourceFileDialogButton.connect("pressed", self, "_source_file_button_pressed")
	SourceFileDialogButton.icon = get_icon("Folder", "EditorIcons")
	TargetFileDialogButton.connect("pressed", self, "_target_file_button_pressed")
	TargetFileDialogButton.icon = get_icon("Folder", "EditorIcons")

	TestButton.connect("pressed", self, "_test_button_pressed")
	BuildButton.connect("pressed", self, "_build_button_pressed")
	InkFileDialog.connect("file_selected", self, "_on_file_selected")
	
	MonoLineEdit.text = configuration.mono_path
	ExecutableLineEdit.text = configuration.inklecate_path
	SourceFileLineEdit.text = configuration.source_file_path
	TargetFileLineEdit.text = configuration.target_file_path
	
	_progress_texture = _create_progress_texture()

	_update_mono_availability()
	_set_minimum_panel_size()

	add_child(InkFileDialog)

# ############################################################################ #
# Signal Receivers
# ############################################################################ #

func _use_mono_toggled(toggled: bool):
	configuration.use_mono = !configuration.use_mono
	configuration.persist()

	_update_mono_availability()

func _mono_button_pressed():
	_reset_file_dialog()

	FileDialogSelection = FileDialogSelectionEnum.MONO
	InkFileDialog.set_mode(FileDialog.MODE_OPEN_FILE)
	InkFileDialog.set_access(FileDialog.ACCESS_FILESYSTEM)
	InkFileDialog.popup_centered(Vector2(1280, 800) * _editor_scale)

func _executable_button_pressed():
	_reset_file_dialog()

	FileDialogSelection = FileDialogSelectionEnum.EXECUTABLE
	InkFileDialog.set_mode(FileDialog.MODE_OPEN_FILE)
	InkFileDialog.set_access(FileDialog.ACCESS_FILESYSTEM)
	InkFileDialog.popup_centered(Vector2(1280, 800) * _editor_scale)

func _source_file_button_pressed():
	_reset_file_dialog()

	FileDialogSelection = FileDialogSelectionEnum.SOURCE_FILE
	InkFileDialog.set_mode(FileDialog.MODE_OPEN_FILE)
	InkFileDialog.set_access(FileDialog.ACCESS_FILESYSTEM)
	InkFileDialog.add_filter("*.ink;Ink source file")
	InkFileDialog.popup_centered(Vector2(1280, 800) * _editor_scale)

func _target_file_button_pressed():
	_reset_file_dialog()

	FileDialogSelection = FileDialogSelectionEnum.TARGET_FILE
	InkFileDialog.set_mode(FileDialog.MODE_SAVE_FILE)
	InkFileDialog.set_access(FileDialog.ACCESS_FILESYSTEM)
	InkFileDialog.add_filter("*.json;Compiled Ink project")
	InkFileDialog.popup_centered(Vector2(1280, 800) * _editor_scale)

func _on_file_selected(path: String):
	match FileDialogSelection:
		FileDialogSelectionEnum.MONO:
			configuration.mono_path = ProjectSettings.globalize_path(path)
			_update_save_and_cleanup(configuration.mono_path, MonoLineEdit)
		FileDialogSelectionEnum.EXECUTABLE:
			configuration.inklecate_path = ProjectSettings.globalize_path(path)
			_update_save_and_cleanup(configuration.inklecate_path, ExecutableLineEdit)
		FileDialogSelectionEnum.SOURCE_FILE:
			configuration.source_file_path = ProjectSettings.localize_path(path)
			_update_save_and_cleanup(configuration.source_file_path, SourceFileLineEdit)
		FileDialogSelectionEnum.TARGET_FILE:
			configuration.target_file_path = ProjectSettings.localize_path(path)
			_update_save_and_cleanup(configuration.target_file_path, TargetFileLineEdit)
		_:
			printerr("Unknown FileDialogSelection, failed to save FileDialog file.")
	FileDialogSelection = FileDialogSelectionEnum.UNKNOWN

func _configuration_entered(new_text):
	_configuration_focus_exited()

func _configuration_focus_exited():
	configuration.mono_path = MonoLineEdit.text
	configuration.source_file_path = SourceFileLineEdit.text
	configuration.target_file_path = TargetFileLineEdit.text
	configuration.inklecate_path = ExecutableLineEdit.text

	configuration.persist()

func _test_button_pressed():
	var is_windows = _is_running_on_windows()
	var output = []
	var return_code

	if is_windows || !configuration.use_mono:
		return_code = OS.execute(configuration.inklecate_path, [], true, output, true)
	else:
		return_code = OS.execute(configuration.mono_path, [configuration.inklecate_path], true, output, true)

	var output_array = PoolStringArray(output)

	# NOTE: At the moment, inklecate doesn't support a subcommand that would just
	# exit with 0 so `_contains_inklecate_output_prefix` will always be executed.
	if return_code == 0 || _contains_inklecate_output_prefix(output_array):
		var dialog = AcceptDialog.new()
		add_child(dialog)

		dialog.window_title = "Success"
		dialog.dialog_text = "The configuration seems to be valid!"

		if output_array.size() > 0:
			print("inklecate was found and executed:")
			print(output_array.join("\n"))
		else:
			print("inklecate was found and executed.")

		dialog.popup_centered()
	else:
		var output_text = output_array.join("\n")
		var dialog = InkRichDialog.instance()
		add_child(dialog)

		printerr("Something went wrong while testing inklecate's setup.")
		printerr(output_text)

		dialog.window_title = "Error"
		dialog.message_text = "Something went wrong while testing inklecate's setup. Please see the output below."
		dialog.output_text = output_text

		dialog.popup_centered(Vector2(700, 400) * _editor_scale)

func _build_button_pressed():
	_compile_story()

func _compile_story():
	BuildButton.icon = _progress_texture
	BuildButton.disabled = true

	var compiler_configuration = InkCompiler.Configuration.new(configuration, true)
	var compiler = InkCompiler.new(compiler_configuration)

	_compilers[compiler.identifier] = compiler
	compiler.connect("did_compile", self, "_handle_compilation_result")
	compiler.compile_story()

# ############################################################################ #
# Private helpers
# ############################################################################ #

func _update_mono_availability():
	var is_running_on_windows = _is_running_on_windows()
	var is_visible = !is_running_on_windows && configuration.use_mono

	UseMonoLabel.visible = !is_running_on_windows
	UseMonoCheckBox.visible = !is_running_on_windows

	MonoLabel.visible = is_visible
	MonoHBoxContainer.visible = is_visible
	UseMonoCheckBox.set_pressed_no_signal(configuration.use_mono)

func _reset_file_dialog():
	InkFileDialog.current_file = ""
	InkFileDialog.clear_filters()

func _update_save_and_cleanup(value, line_edit):
	line_edit.text = value
	line_edit.update()

	configuration.persist()

func _is_running_on_windows():
	var os_name = OS.get_name()
	return (os_name == "Windows" || os_name == "UWP")

func _create_progress_texture() -> AnimatedTexture:
	var animated_texture = AnimatedTexture.new()
	animated_texture.frames = 8

	for index in range(8):
		var texture = get_icon(str("Progress", (index + 1)), "EditorIcons")
		animated_texture.set_frame_texture(index, texture)

	return animated_texture

## Guess whether the provided `output_array` looks like the usage inklecate
## outputs when run with no parameters.
func _contains_inklecate_output_prefix(output_array: PoolStringArray):
	# No valid output -> it's not inklecate.
	if output_array.size() == 0: return false

	# The first line of the output is cleaned up by removing the BOM and
	# any sort of whitespace/unprintable character.
	var cleaned_line = output_array[0].replace(BOM, "").strip_edges()
	
	# If the first line starts with the correct substring, it's likely
	# to be inklecate!
	return cleaned_line.find("Usage: inklecate2") == 0

func _handle_compilation_result(result):
	var compiler_identifier = result.compiler_identifier
	var use_threads = result.use_threads
	var success = result.success
	var output = result.output

	BuildButton.icon = null
	BuildButton.disabled = false

	if result.success:
		if output && !output.empty():
			var dialog = InkRichDialog.instance()
			add_child(dialog)

			dialog.window_title = "Success!"
			dialog.message_text = "The story was successfully compiled."
			dialog.output_text = output

			dialog.popup_centered(Vector2(700, 400) * _editor_scale)
		else:
			var dialog = AcceptDialog.new()
			add_child(dialog)

			dialog.window_title = "Success!"
			dialog.dialog_text = "The story was successfully compiled."

			dialog.popup_centered()
	else:
		var dialog = InkRichDialog.instance()
		add_child(dialog)

		dialog.window_title = "Error"
		dialog.message_text = "The story could not be compiled. See inklecate's output below."
		dialog.output_text = output

		dialog.popup_centered(Vector2(700, 400) * _editor_scale)

	if _compilers.has(compiler_identifier):
		_compilers.erase(compiler_identifier)

func _retrieve_editor_scale():
	# HACK: For some reason, it's not possible to pass data from the EditorPlugin
	# to this node, because InkPanel is somehow instantiated twice and the one shown
	# in the bottom panel isn't the one instantiated by the original EditorPlugin.
	#
	# Thus, we just create a dummy EditorPlugin to get the EditorInterface here.
	#
	# This needs more investigation.
	var editor_interface = EditorPlugin.new().get_editor_interface()
	if editor_interface != null:
		_editor_scale = editor_interface.get_editor_scale()

func _set_minimum_panel_size():
	# Adapting the minimum size of the panel to the scale of the editor.
	rect_min_size = Vector2(0, 245) * _editor_scale
