# warning-ignore-all:return_value_discarded

# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

tool
extends Control

# Hiding this type to prevent registration of "private" nodes.
# See https://github.com/godotengine/godot-proposals/issues/1047
# class_name InkBottomPanel

# ############################################################################ #
# Imports
# ############################################################################ #

var InkStoryPanelScene = load("res://addons/inkgd/editor/panel/stories/ink_story_panel.tscn")
var InkPreviewPanelScene = load("res://addons/inkgd/editor/panel/preview/ink_preview_panel.tscn")
var InkConfigurationPanelScene = load("res://addons/inkgd/editor/panel/configuration/ink_configuration_panel.tscn")

# ############################################################################ #
# Properties
# ############################################################################ #

var editor_interface: InkEditorInterface = null
var configuration: InkConfiguration = null

# ############################################################################ #
# Private Properties
# ############################################################################ #

var _progress_texture: AnimatedTexture

# ############################################################################ #
# Hierarchy Nodes
# ############################################################################ #

onready var _tab_container: TabContainer = $TabContainer
onready var _beta_button: LinkButton = $MarginContainer/LinkButton

onready var _story_panel = InkStoryPanelScene.instance()
onready var _preview_panel = InkPreviewPanelScene.instance()
onready var _configuration_panel = InkConfigurationPanelScene.instance()

# ############################################################################ #
# Overrides
# ############################################################################ #

func _ready():
	# FIXME: This needs investigating.
	# Sanity check. It seems the editor instantiates tools script on their
	# own, probably to add them to its tree. In that case, they won't have
	# their dependencies injected, so we're not doing anything.
	if editor_interface == null || configuration == null:
		print("[inkgd] [INFO] Ink Bottom Panel: dependencies not met, ignoring.")
		return

	_progress_texture = _create_progress_texture()

	_story_panel.editor_interface = editor_interface
	_story_panel.configuration = configuration
	_story_panel.progress_texture = _progress_texture

	_preview_panel.editor_interface = editor_interface
	_preview_panel.configuration = configuration
	_preview_panel.progress_texture = _progress_texture

	_configuration_panel.editor_interface = editor_interface
	_configuration_panel.configuration = configuration

	_tab_container.add_child(_story_panel)
	_tab_container.add_child(_preview_panel)
	_tab_container.add_child(_configuration_panel)

	_beta_button.connect("pressed", self, "_open_github_issues")

	_set_minimum_panel_size()


# ############################################################################ #
# Signals Receivers
# ############################################################################ #

func _open_github_issues():
	OS.shell_open("https://github.com/ephread/inkgd/issues/new?assignees=&labels=&template=bug_report.md")

# ############################################################################ #
# Private helpers
# ############################################################################ #

func _create_progress_texture() -> AnimatedTexture:
	var animated_texture = AnimatedTexture.new()
	animated_texture.frames = 8

	for index in range(8):
		var texture = get_icon(str("Progress", (index + 1)), "EditorIcons")
		animated_texture.set_frame_texture(index, texture)

	return animated_texture

func _set_minimum_panel_size():
	# Adapting the minimum size of the panel to the scale of the editor.
	rect_min_size = Vector2(900, 245) * editor_interface.scale
