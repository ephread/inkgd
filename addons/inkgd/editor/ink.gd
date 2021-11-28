# ############################################################################ #
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

tool
extends EditorPlugin

# ############################################################################ #
# Properties
# ############################################################################ #

var InkConfiguration = load("res://addons/inkgd/editor/ink_configuration.gd")
var InkCompiler = load("res://addons/inkgd/editor/ink_compiler.gd")

var _configuration = InkConfiguration.new()
var _panel = null

# ############################################################################ #
# Overriden Methods
# ############################################################################ #

func _enter_tree():
	_panel = preload("res://addons/inkgd/editor/ink_panel.tscn").instance()
	_panel.configuration = _configuration

	add_control_to_bottom_panel(_panel, "Ink")
	
	_add_autoloads()
	_add_templates()

func _exit_tree():
	remove_control_from_bottom_panel(_panel)
	_panel.free()

	_remove_autoloads()
	_remove_templates()

func build():
	var compiler_configuration = InkCompiler.Configuration.new(_configuration, false)
	var compiler = InkCompiler.new(compiler_configuration)
	
	return compiler.compile_story()

# ############################################################################ #
# Private Methods
# ############################################################################ #

func _add_autoloads():
	# Find the Ink runtime code and add it as a singleton.
	add_autoload_singleton("__InkRuntime", "res://addons/inkgd/runtime/static/ink_runtime.gd")

func _remove_autoloads():
	# Remove the Ink runtime code.
	remove_autoload_singleton("__InkRuntime")

func _add_templates():
	var dir = Directory.new()
	var names = _get_plugin_templates_names()

	# Setup the templates folder for the project
	var template_dir_path = ProjectSettings.get_setting("editor/script_templates_search_path")
	if not dir.dir_exists(template_dir_path):
		dir.make_dir(template_dir_path)

	for name in names:
		var template_file_path = template_dir_path + "/" + name
		dir.copy("res://addons/inkgd/editor/templates/"+name, template_file_path)

func _remove_templates():
	var dir = Directory.new()
	var names = _get_plugin_templates_names()
	var template_dir_path = ProjectSettings.get_setting("editor/script_templates_search_path")

	for name in names:
		var template_file_path = template_dir_path + "/" + name
		if dir.file_exists(template_file_path):
			dir.remove(template_file_path)

func _get_plugin_templates_names():
	# Get all the templates from the plugin
	var dir = Directory.new()
	var plugin_template_names = []

	dir.change_dir("res://addons/inkgd/editor/templates/")
	dir.list_dir_begin(true)

	var temp = dir.get_next()
	while temp != "":
		plugin_template_names.append(temp)
		temp = dir.get_next()

	return plugin_template_names
