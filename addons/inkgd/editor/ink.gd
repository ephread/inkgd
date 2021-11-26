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
	add_control_to_bottom_panel(dock, "Ink")

func _exit_tree():
	# Remove from docks (must be called so layout is updated and saved)
	remove_control_from_docks(dock)
	remove_control_from_bottom_panel(dock)
	# Remove the node
	dock.free()

func build():
	dock._compile_story(false)
	return true
