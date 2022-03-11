# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

tool
extends EditorPlugin

# Hiding this type to prevent registration of "private" nodes.
# See https://github.com/godotengine/godot-proposals/issues/1047
# class_name InkEditorPlugin

# ############################################################################ #
# Imports
# ############################################################################ #

var InkJsonImportPlugin = preload("res://addons/inkgd/editor/import_plugins/ink_json_import_plugin.gd")
var InkSourceImportPlugin = preload("res://addons/inkgd/editor/import_plugins/ink_source_import_plugin.gd")

var InkBottomPanel = preload("res://addons/inkgd/editor/panel/ink_bottom_panel.tscn")

var InkCSharpValidator = preload("res://addons/inkgd/editor/common/ink_csharp_validator.gd")

var InkEditorInterface = load("res://addons/inkgd/editor/common/ink_editor_interface.gd")
var InkConfiguration = load("res://addons/inkgd/editor/common/ink_configuration.gd")

var InkCompilationConfiguration = load("res://addons/inkgd/editor/common/executors/structures/ink_compilation_configuration.gd")
var InkCompiler = load("res://addons/inkgd/editor/common/executors/ink_compiler.gd")

# ############################################################################ #
# Constant
# ############################################################################ #

const DO_NOT_USE_MONO_RUNTIME_SETTING = "inkgd/do_not_use_mono_runtime"


# ############################################################################ #
# Private Properties
# ############################################################################ #

var _editor_interface: InkEditorInterface = null
var _configuration: InkConfiguration = null
var _panel = null

var _ink_source_import_plugin: InkSourceImportPlugin = null
var _ink_json_import_plugin: InkJsonImportPlugin = null

var _tool_button: ToolButton = null


# ############################################################################ #
# Overrides
# ############################################################################ #

func _enter_tree():
	var ink_player_icon = load("res://addons/inkgd/editor/icons/ink_player.svg")
	if ink_player_icon == null:
		printerr(
			"[inkgd] [ERROR] The plugin could not be initialized because the required assets " +
			"haven't been imported by Godot yet. This can happen when cloning a fresh project or " +
			"after deleting the '.import' folder. Disabling and reenabling InkGD in " +
			"Project > Project setting… > Plugins or reloading the project should fix the problem."
		)
		return

	# Note: assets are not preloaded to prevent the script from failing
	# its interpretation phase if the resources have never been imported before.
	if _should_use_mono() && _validate_csproj():
		print("[inkgd] [INFO] Using the Mono runtime.")
		_register_custom_settings()
		add_custom_type(
				"InkPlayer",
				"Node",
				load("res://addons/inkgd/mono/InkPlayer.cs"),
				ink_player_icon
		)
	else:
		print("[inkgd] [INFO] Using the GDScript runtime.")
		add_custom_type(
				"InkPlayer",
				"Node",
				load("res://addons/inkgd/ink_player.gd"),
				ink_player_icon
		)

	_editor_interface = InkEditorInterface.new(get_editor_interface())

	_configuration = InkConfiguration.new()
	_configuration.retrieve()

	_add_bottom_panel()
	_add_import_plugin()

	_add_autoloads()
	_add_templates()


func _exit_tree():
	# The plugin hasn't been intialised properly, nothing to do.
	if _panel == null:
		return

	_remove_bottom_panel()
	_remove_import_plugin()

	_remove_autoloads()
	_remove_templates()

	remove_custom_type("InkPlayer")


func build():
	if _configuration.compilation_mode == InkConfiguration.BuildMode.DURING_BUILD:
		var previous_result = true
		for story_configuration in _configuration.stories:
			if !previous_result:
				break

			var source_file_path = _configuration.get_source_file_path(story_configuration)
			var target_file_path = _configuration.get_target_file_path(story_configuration)

			var compiler_configuration = InkCompilationConfiguration.new(
					_configuration,
					false,
					false,
					source_file_path,
					target_file_path
			)

			var compiler = InkCompiler.new(compiler_configuration)
			var current_result = compiler.compile_story()

			if current_result:
				_editor_interface.call_deferred("update_file", target_file_path)

			previous_result = previous_result && current_result

		return previous_result
	else:
		return true


# ############################################################################ #
# Private Helpers
# ############################################################################ #

func _add_import_plugin():
	_ink_source_import_plugin = InkSourceImportPlugin.new()
	_ink_json_import_plugin = InkJsonImportPlugin.new()
	add_import_plugin(_ink_source_import_plugin)
	add_import_plugin(_ink_json_import_plugin)


func _remove_import_plugin():
	remove_import_plugin(_ink_source_import_plugin)
	remove_import_plugin(_ink_json_import_plugin)
	_ink_source_import_plugin = null
	_ink_json_import_plugin = null


func _add_bottom_panel():
	_panel = InkBottomPanel.instance()
	_panel.editor_interface = _editor_interface
	_panel.configuration = _configuration

	_tool_button = add_control_to_bottom_panel(_panel, "Ink")


func _remove_bottom_panel():
	remove_control_from_bottom_panel(_panel)
	_panel.queue_free()


## Registers the Ink runtime node as an autoloaded singleton.
func _add_autoloads():
	add_autoload_singleton("__InkRuntime", "res://addons/inkgd/runtime/static/ink_runtime.gd")


## Unregisters the Ink runtime node from autoloaded singletons.
func _remove_autoloads():
	remove_autoload_singleton("__InkRuntime")


## Registers the script templates provided by the plugin.
func _add_templates():
	var dir = Directory.new()
	var names = _get_plugin_templates_names()

	# Setup the templates folder for the project
	var template_dir_path = ProjectSettings.get_setting("editor/script_templates_search_path")
	if !dir.dir_exists(template_dir_path):
		dir.make_dir(template_dir_path)

	for name in names:
		var template_file_path = template_dir_path + "/" + name
		dir.copy("res://addons/inkgd/editor/templates/" + name, template_file_path)


## Unregisters the script templates provided by the plugin.
func _remove_templates():
	var dir = Directory.new()
	var names = _get_plugin_templates_names()
	var template_dir_path = ProjectSettings.get_setting("editor/script_templates_search_path")

	for name in names:
		var template_file_path = template_dir_path + "/" + name
		if dir.file_exists(template_file_path):
			dir.remove(template_file_path)


## Get all the script templates provided by the plugin.
func _get_plugin_templates_names() -> Array:
	var dir = Directory.new()
	var plugin_template_names = []

	dir.change_dir("res://addons/inkgd/editor/templates/")
	dir.list_dir_begin(true)

	var temp = dir.get_next()
	while temp != "":
		plugin_template_names.append(temp)
		temp = dir.get_next()

	return plugin_template_names


func _register_custom_settings():
	if !ProjectSettings.has_setting(DO_NOT_USE_MONO_RUNTIME_SETTING):
		ProjectSettings.set_setting(DO_NOT_USE_MONO_RUNTIME_SETTING, false)

	var property_info = {
		"name": DO_NOT_USE_MONO_RUNTIME_SETTING,
		"type": TYPE_BOOL,
		"hint_string": "Enable this setting to always use the GDScript runtime.",
		"default": false
	}

	ProjectSettings.add_property_info(property_info)


func _validate_csproj() -> bool:
	var project_name = ProjectSettings.get_setting("application/config/name")
	if project_name.empty():
		printerr("[inkgd] [ERROR] The project is missing a name.")
		return false

	var validator = InkCSharpValidator.new()
	return validator.validate_csharp_project_files(project_name)


func _should_use_mono():
	if ProjectSettings.has_setting(DO_NOT_USE_MONO_RUNTIME_SETTING):
		var do_not_use_mono = ProjectSettings.get_setting(DO_NOT_USE_MONO_RUNTIME_SETTING)
		if do_not_use_mono == null:
			do_not_use_mono = false

		return _can_run_mono() && !do_not_use_mono
	else:
		return _can_run_mono()


func _can_run_mono():
	return type_exists("_GodotSharp")
