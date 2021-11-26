# warning-ignore-all:return_value_discarded

# ############################################################################ #
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

tool
extends Control

# ############################################################################ #
# Properties
# ############################################################################ #

enum FileDialogSelectionEnum {
	UNKNOWN,
	MONO,
	EXECUTABLE,
	SOURCE_FILE,
	TARGET_FILE
}

var configuration = preload("res://addons/inkgd/editor/configuration.gd").new()
var InkRichDialog = preload("res://addons/inkgd/editor/ink_rich_dialog.tscn")

var progress_texture: AnimatedTexture
var thread: Thread

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

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		configuration.free()

func _ready():
	configuration.retrieve()

	MonoLineEdit.text = configuration.mono_path
	ExecutableLineEdit.text = configuration.inklecate_path
	SourceFileLineEdit.text = configuration.source_file_path
	TargetFileLineEdit.text = configuration.target_file_path

	UseMonoCheckBox.connect("toggled", self, "_use_mono_toggled")

	MonoLineEdit.connect("text_entered", self, "_mono_selected")
	ExecutableLineEdit.connect("text_entered", self, "_executable_selected")
	SourceFileLineEdit.connect("text_entered", self, "_source_file_selected")
	TargetFileLineEdit.connect("text_entered", self, "_target_file_selected")

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
	
	progress_texture = _create_progress_texture()
	
	_update_mono_availability()

	add_child(InkFileDialog)

func _exit_tree():
	if thread != null && !thread.is_alive():
		thread.wait_to_finish()

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
	InkFileDialog.popup_centered(Vector2(1280, 800))

func _executable_button_pressed():
	_reset_file_dialog()

	FileDialogSelection = FileDialogSelectionEnum.EXECUTABLE
	InkFileDialog.set_mode(FileDialog.MODE_OPEN_FILE)
	InkFileDialog.set_access(FileDialog.ACCESS_FILESYSTEM)
	InkFileDialog.popup_centered(Vector2(1280, 800))

func _source_file_button_pressed():
	_reset_file_dialog()

	FileDialogSelection = FileDialogSelectionEnum.SOURCE_FILE
	InkFileDialog.set_mode(FileDialog.MODE_OPEN_FILE)
	InkFileDialog.set_access(FileDialog.ACCESS_FILESYSTEM)
	InkFileDialog.add_filter("*.ink;Ink source file")
	InkFileDialog.popup_centered(Vector2(1280, 800))

func _target_file_button_pressed():
	_reset_file_dialog()

	FileDialogSelection = FileDialogSelectionEnum.TARGET_FILE
	InkFileDialog.set_mode(FileDialog.MODE_SAVE_FILE)
	InkFileDialog.set_access(FileDialog.ACCESS_FILESYSTEM)
	InkFileDialog.add_filter("*.json;Compiled Ink project")
	InkFileDialog.popup_centered(Vector2(1280, 800))

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
	
	if return_code == 0 || output_array.size() > 0 && (output_array[0].find("Usage: inklecate2") == 0):
		var dialog = AcceptDialog.new()
		add_child(dialog)
		
		dialog.window_title = "Success"
		dialog.dialog_text = "inklecate was successfully executed!"
		
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
		
		print("Something went wrong while testing inklecate's setup.")
		print(output_text)

		dialog.window_title = "Error"
		dialog.message_text = "Something went wrong while testing inklecate's setup. Please see the output below."
		dialog.output_text = output_text

		dialog.popup_centered(Vector2(700, 400))

func _build_button_pressed():
	_compile_story()

func _compile_story(interactive = true):
	BuildButton.icon = progress_texture
	var is_windows = _is_running_on_windows()

	var should_use_mono = (is_windows || !configuration.use_mono)
	var compilation_config = CompilationConfiguration.new_with_configuration(
		configuration, should_use_mono, interactive
	)

	if thread != null && !thread.is_alive():
		thread.wait_to_finish()
	
	thread = Thread.new()
	thread.start(self, "_compile_story_in_thread", compilation_config, Thread.PRIORITY_HIGH)

# ############################################################################ #
# Private helpers
# ############################################################################ #

func _update_mono_availability():
	var is_visible = !_is_running_on_windows() && configuration.use_mono
	
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

func _compile_story_in_thread(config):
	var return_code = 0
	var output = []

	if config.should_use_mono:
		return_code = OS.execute(config.mono_path, [
			config.inklecate_path,
			'-o',
			config.target_file_path,
			config.source_file_path
		], true, output, true)
	else:
		return_code = OS.execute(config.inklecate_path, [
			'-o',
			config.target_file_path,
			config.source_file_path
		], true, output, true)
	
	var execution_result = ExecutionResult.new()
	execution_result.interactive = config.interactive
	execution_result.return_code = return_code
	execution_result.output = PoolStringArray(output)
	
	_handle_compilation_result(execution_result)
	
	# call_deferred("_handle_compilation_result", execution_result)

func _handle_compilation_result(execution_result: ExecutionResult):
	BuildButton.icon = null
	
	var interactive = execution_result.interactive
	var return_code = execution_result.return_code
	var output_array = execution_result.output

	if return_code == 0:
		var output_text = output_array.join("\n")
		if output_text.strip_edges().length() == 0:
			print(str("(",configuration.source_file_path, ") was successfully compiled."))
			if !interactive: return
			
			var dialog = AcceptDialog.new()
			add_child(dialog)
			
			dialog.window_title = "Success!"
			dialog.dialog_text = "The story was successfully compiled."
			
			dialog.popup_centered()
		else:
			print(str("(",configuration.source_file_path, ") was successfully compiled:"))
			push_warning(output_text)
			
			if !interactive: return
			var dialog = InkRichDialog.instance()
			add_child(dialog)

			dialog.window_title = "Success!"
			dialog.message_text = "The story was successfully compiled."
			dialog.output_text = output_text

			dialog.popup_centered(Vector2(700, 400))
	else:
		var output_text = output_array.join("\n")
		print(str("Could not compile (", configuration.source_file_path, "):"))
		print(output_text)
		
		if !interactive: return
		var dialog = InkRichDialog.instance()
		add_child(dialog)

		dialog.window_title = "Error"
		dialog.message_text = "The story could not be compiled. See inklecate's output below."
		dialog.output_text = output_text

		dialog.popup_centered(Vector2(700, 400))

class CompilationConfiguration:
	var should_use_mono: bool
	var interactive: bool
	
	var use_mono: bool = false
	var mono_path: String = ""
	var inklecate_path: String = ""
	var source_file_path: String = ""
	var target_file_path: String = ""
	
	static func new_with_configuration(
		config,
		should_use_mono,
		interactive
	):
		var new_config = CompilationConfiguration.new()
		
		new_config.should_use_mono = should_use_mono
		new_config.interactive = interactive
		
		new_config.use_mono = config.use_mono
		new_config.mono_path = config.mono_path
		new_config.inklecate_path = config.inklecate_path
		new_config.source_file_path = ProjectSettings.globalize_path(config.source_file_path)
		new_config.target_file_path = ProjectSettings.globalize_path(config.target_file_path)

class ExecutionResult:
	var interactive: bool
	
	var return_code: int
	var output: PoolStringArray
