# ############################################################################ #
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

tool
extends EditorPlugin

var dock = null

func _enter_tree():
	dock = preload("res://addons/inkgd/editor/ink_dock.tscn").instance()
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)
	add_autoloads()
	add_templates()

func _exit_tree():
	# Remove from docks (must be called so layout is updated and saved)
	remove_control_from_docks(dock)
	# Remove the node
	dock.queue_free()
	remove_autoloads()
	remove_templates()

func build():
	dock._build_button_pressed()
	return true

func add_autoloads():
	# Find the Ink runtime code and add it as a singleton.
	add_autoload_singleton("__InkRuntime", "res://addons/inkgd/runtime/static/ink_runtime.gd")

func remove_autoloads():
	# Remove the Ink runtime code.
	remove_autoload_singleton("__InkRuntime")

func add_templates():
	var dir = Directory.new()
	var names = get_plugin_templates_names()

	# Setup the templates folder for the project
	var template_dir_path = ProjectSettings.get_setting("editor/script_templates_search_path")
	if not dir.dir_exists(template_dir_path):
		dir.make_dir(template_dir_path)

	for name in names:
		var template_file_path = template_dir_path + "/" + name
		dir.copy("res://addons/inkgd/editor/templates/"+name, template_file_path)

func remove_templates():
	var dir = Directory.new()
	var names = get_plugin_templates_names()
	var template_dir_path = ProjectSettings.get_setting("editor/script_templates_search_path")

	for name in names:
		var template_file_path = template_dir_path + "/" + name
		if dir.file_exists(template_file_path):
			dir.remove(template_file_path)

func get_plugin_templates_names():
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
