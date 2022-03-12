# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

tool
extends Control

# Hiding this type to prevent registration of "private" nodes.
# See https://github.com/godotengine/godot-proposals/issues/1047
# class_name InkConfigurationPanel

# ############################################################################ #
# Imports
# ############################################################################ #

var InkExecutionConfiguration = load("res://addons/inkgd/editor/common/executors/structures/ink_execution_configuration.gd")
var InkConfigurationTester = load("res://addons/inkgd/editor/common/executors/ink_configuration_tester.gd")

var InkCSharpValidator = preload("res://addons/inkgd/editor/common/ink_csharp_validator.gd")

var InkRichDialog = load("res://addons/inkgd/editor/panel/common/ink_rich_dialog.tscn")


# ############################################################################ #
# Enums
# ############################################################################ #

## Represents which configuration setting triggered the file dialog.
enum FileDialogSelection {
	UNKNOWN,
	MONO_EXECUTABLE,
	INKLECATE_EXECUTABLE
}


# ############################################################################ #
# Constants
# ############################################################################ #

const BOM = "\ufeff"


# ############################################################################ #
# Properties
# ############################################################################ #

var editor_interface: InkEditorInterface = null
var configuration: InkConfiguration = null


# ############################################################################ #
# Private Properties
# ############################################################################ #

var _file_dialog = EditorFileDialog.new()

## Configuration item for which the FileDialog is currently shown.
##
## Unknown by default.
var _file_dialog_selection = FileDialogSelection.UNKNOWN


# ############################################################################ #
# Nodes
# ############################################################################ #

onready var _test_button = find_node("TestButton")

onready var _use_mono_label = find_node("UseMonoLabel")
onready var _use_mono_checkbox = find_node("UseMonoCheckBox")

onready var _mono_label = find_node("MonoLabel")
onready var _mono_container = find_node("MonoH")
onready var _mono_line_edit = find_node("MonoLineEdit")
onready var _mono_dialog_button = find_node("MonoDialogButton")

onready var _executable_line_edit = find_node("ExecutableLineEdit")
onready var _executable_dialog_button = find_node("ExecutableDialogButton")

onready var _recompilation_mode_button = find_node("RecompilationModeOptionButton")

onready var _mono_support_container = find_node("MonoSupportV")
onready var _mono_support_documentation_button = find_node("DocumentationButton")
onready var _mono_support_presence_label = _mono_support_container.find_node("PresenceLabel")
onready var _mono_support_refresh_button = _mono_support_container.find_node("RefreshButton")


# ############################################################################ #
# Overrides
# ############################################################################ #

func _ready():
	# FIXME: This needs investigating.
	# Sanity check. It seems the editor instantiates tools script on their
	# own, probably to add them to its tree. In that case, they won't have
	# their dependencies injected, so we're not doing anything.
	if editor_interface == null || configuration == null:
		print("[inkgd] [INFO] Ink Configuration Tab: dependencies not met, ignoring.")
		return

	_set_button_icons()
	_apply_configuration()
	_connect_signals()
	_check_runtime_presence()

	_mono_support_container.visible = _can_run_mono()

	add_child(_file_dialog)


# ############################################################################ #
# Signal Receivers
# ############################################################################ #

func _configuration_entered(new_text):
	_configuration_focus_exited()


func _configuration_focus_exited():
	configuration.mono_path = _mono_line_edit.text
	configuration.inklecate_path = _executable_line_edit.text

	configuration.persist()


func _use_mono_toggled(toggled: bool):
	configuration.use_mono = !configuration.use_mono
	configuration.persist()

	_update_mono_availability(false)


func _mono_button_pressed():
	_reset_file_dialog()

	_file_dialog_selection = FileDialogSelection.MONO_EXECUTABLE
	_file_dialog.current_path = configuration.mono_path
	_file_dialog.current_dir = configuration.mono_path.get_base_dir()
	_file_dialog.current_file = configuration.mono_path.get_file()
	_file_dialog.set_mode(FileDialog.MODE_OPEN_FILE)
	_file_dialog.set_access(FileDialog.ACCESS_FILESYSTEM)
	_file_dialog.popup_centered(Vector2(1280, 800) * editor_interface.scale)


func _executable_button_pressed():
	_reset_file_dialog()

	_file_dialog_selection = FileDialogSelection.INKLECATE_EXECUTABLE
	_file_dialog.current_file = configuration.inklecate_path
	_file_dialog.current_dir = configuration.inklecate_path.get_base_dir()
	_file_dialog.current_file = configuration.inklecate_path.get_file()
	_file_dialog.set_mode(FileDialog.MODE_OPEN_FILE)
	_file_dialog.set_access(FileDialog.ACCESS_FILESYSTEM)
	_file_dialog.popup_centered(Vector2(1280, 800) * editor_interface.scale)


func _recompilation_mode_button_selected(index):
	configuration.compilation_mode = index
	configuration.persist()


func _test_button_pressed():
	var test_configuration = InkExecutionConfiguration.new(configuration, false, true)
	var tester = InkConfigurationTester.new(test_configuration)

	var result = tester.test_availability()

	# NOTE: At the moment, inklecate doesn't support a subcommand that would just
	# exit with 0 so `_contains_inklecate_output_prefix` will always be executed.
	if result.success:
		var dialog = AcceptDialog.new()
		add_child(dialog)

		dialog.window_title = "Success"
		dialog.dialog_text = "The configuration seems to be valid!"

		dialog.popup_centered()
	else:
		var dialog = InkRichDialog.instance()
		add_child(dialog)


		dialog.window_title = "Error"
		dialog.message_text = "Something went wrong while testing inklecate's setup. Please see the output below."
		dialog.output_text = result.output
		dialog.update_layout(editor_interface.scale)

		dialog.popup_centered(Vector2(700, 400) * editor_interface.scale)


func _on_file_selected(path: String):
	match _file_dialog_selection:
		FileDialogSelection.MONO_EXECUTABLE:
			configuration.mono_path = ProjectSettings.globalize_path(path)
			_update_save_and_cleanup(configuration.mono_path, _mono_line_edit)

		FileDialogSelection.INKLECATE_EXECUTABLE:
			configuration.inklecate_path = ProjectSettings.globalize_path(path)
			_update_save_and_cleanup(configuration.inklecate_path, _executable_line_edit)

		_:
			printerr("[inkgd] [ERROR] Unknown FileDialogSelection, failed to save FileDialog file.")

	_file_dialog_selection = FileDialogSelection.UNKNOWN


func _check_runtime_presence():
	var ink_engine_runtime = InkCSharpValidator.new().get_runtime_path()
	var is_present = !ink_engine_runtime.empty()

	if is_present:
		_mono_support_presence_label.add_color_override("font_color", Color.green)
		_mono_support_presence_label.text = "PRESENT"
	else:
		_mono_support_presence_label.add_color_override("font_color", Color.red)
		_mono_support_presence_label.text = "MISSING"


func _mono_support_documentation_pressed():
	OS.shell_open("https://inkgd.readthedocs.io/en/latest/advanced/migrating_to_godot_mono.html")


# ############################################################################ #
# Private helpers
# ############################################################################ #

func _reset_file_dialog():
	_file_dialog.current_file = ""
	_file_dialog.clear_filters()


func _update_save_and_cleanup(value, line_edit):
	line_edit.text = value
	line_edit.update()

	configuration.persist()


func _apply_configuration():
	var compilation_mode = configuration.compilation_mode
	var item_count = _recompilation_mode_button.get_item_count()

	if compilation_mode >= 0 && compilation_mode < item_count:
		_recompilation_mode_button.select(configuration.compilation_mode)
	else:
		_recompilation_mode_button.select(0)

	_mono_line_edit.text = configuration.mono_path
	_executable_line_edit.text = configuration.inklecate_path

	_update_mono_availability(true)


func _update_mono_availability(updates_checkbox = false):
	var is_running_on_windows = editor_interface.is_running_on_windows
	var is_visible = !is_running_on_windows && configuration.use_mono

	_use_mono_label.visible = !is_running_on_windows
	_use_mono_checkbox.visible = !is_running_on_windows

	_mono_label.visible = is_visible
	_mono_container.visible = is_visible

	if updates_checkbox:
		_use_mono_checkbox.set_pressed(configuration.use_mono)


func _set_button_icons():
	var folder_icon = get_icon("Folder", "EditorIcons")
	var reload_icon = get_icon("Reload", "EditorIcons")
	var instance_icon = get_icon("Instance", "EditorIcons")

	_mono_dialog_button.icon = folder_icon
	_executable_dialog_button.icon = folder_icon

	_mono_support_documentation_button.icon = instance_icon
	_mono_support_refresh_button.icon = reload_icon


func _connect_signals():
	editor_interface.editor_filesystem.connect("filesystem_changed", self, "_check_runtime_presence")

	_test_button.connect("pressed", self, "_test_button_pressed")
	_use_mono_checkbox.connect("toggled", self, "_use_mono_toggled")

	_mono_line_edit.connect("text_entered", self, "_configuration_entered")
	_executable_line_edit.connect("text_entered", self, "_configuration_entered")

	_mono_line_edit.connect("focus_exited", self, "_configuration_focus_exited")
	_executable_line_edit.connect("focus_exited", self, "_configuration_focus_exited")

	_mono_dialog_button.connect("pressed", self, "_mono_button_pressed")
	_executable_dialog_button.connect("pressed", self, "_executable_button_pressed")

	_recompilation_mode_button.connect("item_selected", self, "_recompilation_mode_button_selected")

	_mono_support_documentation_button.connect("pressed", self, "_mono_support_documentation_pressed")
	_mono_support_refresh_button.connect("pressed", self, "_check_runtime_presence")

	_file_dialog.connect("file_selected", self, "_on_file_selected")


func _can_run_mono():
	return type_exists("_GodotSharp")
