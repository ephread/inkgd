# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

extends Reference

class_name InkEditorInterface

# ############################################################################ #
# Signals
# ############################################################################ #

## Emitted when 'Ink' resources (i. e. files with the '.ink' extension) were
## reimported by Godot.
signal ink_ressources_reimported(resources)

# ############################################################################ #
# Properties
# ############################################################################ #

## The pixel display scale of the editor.
var scale: float = 1.0

var editor_interface: EditorInterface
var editor_settings: EditorSettings
var editor_filesystem: EditorFileSystem

## `true` if the editor is running on Windows, `false` otherwise.
var is_running_on_windows: bool setget , get_is_running_on_windows
func get_is_running_on_windows() -> bool:
	var os_name = OS.get_name()
	return (os_name == "Windows" || os_name == "UWP")


# ############################################################################ #
# Overrides
# ############################################################################ #

func _init(editor_interface: EditorInterface):
	self.editor_interface = editor_interface
	self.editor_settings = editor_interface.get_editor_settings()
	self.editor_filesystem = editor_interface.get_resource_filesystem()

	scale = editor_interface.get_editor_scale()

	self.editor_filesystem.connect("resources_reimported", self, "_resources_reimported")

# ############################################################################ #
# Methods
# ############################################################################ #

## Tell Godot to scan for updated resources.
func scan_file_system():
	self.editor_filesystem.scan()

## Tell Godot to scan the given resource.
func update_file(path: String):
	self.editor_filesystem.update_file(path)

## Returns a custom header color based on the editor's base color.
##
## If the base color is not found, return 'Color.transparent'.
func get_custom_header_color() -> Color:
	var color = self.editor_settings.get_setting("interface/theme/base_color")
	if color != null:
		return Color.from_hsv(color.h * 0.99, color.s * 0.6, color.v * 1.1)
	else:
		return Color.transparent

# ############################################################################ #
# Signal Receivers
# ############################################################################ #

func _resources_reimported(resources):
	var ink_resources := PoolStringArray()

	for resource in resources:
		if resource.get_extension() == "ink":
			ink_resources.append(resource)

	emit_signal("ink_ressources_reimported", ink_resources)
