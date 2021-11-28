# ############################################################################ #
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

tool
extends EditorPlugin

# ############################################################################ #
# Imports
# ############################################################################ #

var InkPanel = preload("res://addons/inkgd/editor/ink_panel.tscn")

var InkConfiguration = load("res://addons/inkgd/editor/ink_configuration.gd")
var InkCompiler = load("res://addons/inkgd/editor/ink_compiler.gd")

# ############################################################################ #
# Private Properties
# ############################################################################ #

var _configuration: InkConfiguration = null
var _panel: InkPanel = null

# ############################################################################ #
# Overrides
# ############################################################################ #

func _enter_tree():
	_configuration = InkConfiguration.new()
	_panel = InkPanel.instance()
	_panel.configuration = _configuration

	add_control_to_bottom_panel(_panel, "Ink")

	_add_autoloads()
	_add_templates()

func _exit_tree():
	remove_control_from_bottom_panel(_panel)

	_panel.free()
	_configuration.free()

	_remove_autoloads()
	_remove_templates()

func build():
	var configuration = InkCompiler.Configuration.new(_configuration, false)
	var compiler = InkCompiler.new(configuration)

	return compiler.compile_story()

# ############################################################################ #
# Private Helpers
# ############################################################################ #

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
