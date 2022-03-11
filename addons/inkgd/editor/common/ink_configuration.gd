# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

extends Reference

class_name InkConfiguration

# ############################################################################ #
# Enums
# ############################################################################ #

enum BuildMode {
	MANUAL = 0,
	DURING_BUILD,
	AFTER_CHANGE
}

# ############################################################################ #
# Constants
# ############################################################################ #

const ROOT_DIR = "res://"

const COMPILER_CONFIG = ROOT_DIR + ".inkgd_compiler.cfg"
const INK_CONFIG = ROOT_DIR + ".inkgd_ink.cfg"

const COMPILER_CONFIG_FORMAT_VERSION = 2
const INK_CONFIG_FORMAT_VERSION = 2

const FORMAT_SECTION = "format"
const VERSION = "version"

const INKGD_SECTION = "inkgd"
const USE_MONO = "use_mono"
const MONO_PATH = "mono_path"
const INKLECATE_PATH = "inklecate_path"
const COMPILATION_MODE = "compilation_mode"
const STORIES = "stories"
const SOURCE_FILE_PATH = "source_file_path"
const TARGET_FILE_PATH = "target_file_path"
const WATCHED_FOLDER_PATH = "watched_folder_path"

const DEFAULT_STORIES = [
	{
		SOURCE_FILE_PATH: "",
		TARGET_FILE_PATH: "",
		WATCHED_FOLDER_PATH: ""
	}
]

# ############################################################################ #
# Signals
# ############################################################################ #

signal story_configuration_changed()
signal compilation_mode_changed(compilation_mode)

# ############################################################################ #
# Properties
# ############################################################################ #

var use_mono: bool = false
var mono_path: String = ""
var inklecate_path: String = ""

var compilation_mode: int = BuildMode.MANUAL setget set_compilation_mode
func set_compilation_mode(new_value: int):
	compilation_mode = new_value
	emit_signal("compilation_mode_changed", compilation_mode)

var stories: Array = DEFAULT_STORIES

# ############################################################################ #
# Private Properties
# ############################################################################ #

var _compiler_config_file = ConfigFile.new()
var _ink_config_file = ConfigFile.new()

# ############################################################################ #
# Overrides
# ############################################################################ #

func _init():
	pass

# ############################################################################ #
# Public Methods
# ############################################################################ #

## Loads the content of the configuration files from disk.
func retrieve():
	_retrieve_inklecate()
	_retrieve_ink()

## Stores the content of the configuration to the disk.
func persist():
	_persist_inklecate()
	_persist_ink()

func append_new_story_configuration(
		source_file_path: String,
		target_file_path: String,
		wacthed_folder_path: String
):
	stories.append({
		SOURCE_FILE_PATH: source_file_path,
		TARGET_FILE_PATH: target_file_path,
		WATCHED_FOLDER_PATH: wacthed_folder_path
	})

	emit_signal("story_configuration_changed")

func remove_story_configuration_at_index(index: int):
	if index >= 0 && index < stories.size():
		stories.remove(index)

		emit_signal("story_configuration_changed")

func get_story_configuration_at_index(index):
	if index >= 0 && index < stories.size():
		return stories[index]
	else:
		return null

func get_source_file_path(story_configuration):
	return story_configuration[SOURCE_FILE_PATH]

func get_target_file_path(story_configuration):
	return story_configuration[TARGET_FILE_PATH]

func get_watched_folder_path(story_configuration):
	return story_configuration[WATCHED_FOLDER_PATH]

# ############################################################################ #
# Private Methods
# ############################################################################ #

## Loads the content of the inklecate configuration file from disk.
func _retrieve_inklecate():
	var err = _compiler_config_file.load(COMPILER_CONFIG)
	if err != OK:
		# Assuming it doesn't exist.
		return

	use_mono = _compiler_config_file.get_value(INKGD_SECTION, USE_MONO, false)
	mono_path = _compiler_config_file.get_value(INKGD_SECTION, MONO_PATH, "")
	inklecate_path = _compiler_config_file.get_value(INKGD_SECTION, INKLECATE_PATH, "")

	if _compiler_config_file.get_value(FORMAT_SECTION, VERSION, 0) >= 2:
		compilation_mode = _compiler_config_file.get_value(INKGD_SECTION, COMPILATION_MODE, 0)

## Loads the content of the story configuration file from disk.
func _retrieve_ink():
	var err = _ink_config_file.load(INK_CONFIG)
	if err != OK:
		# Assuming it doesn't exist.
		return

	if _ink_config_file.get_value(FORMAT_SECTION, VERSION, 0) >= 2:
		stories = _ink_config_file.get_value(INKGD_SECTION, STORIES, DEFAULT_STORIES)
	else:
		var source_file_path = _ink_config_file.get_value(INKGD_SECTION, SOURCE_FILE_PATH, "")
		var target_file_path = _ink_config_file.get_value(INKGD_SECTION, TARGET_FILE_PATH, "")
		var watched_folder_path = _ink_config_file.get_value(INKGD_SECTION, WATCHED_FOLDER_PATH, "")

		stories[0] = {
			SOURCE_FILE_PATH: source_file_path,
			TARGET_FILE_PATH: target_file_path,
			WATCHED_FOLDER_PATH: watched_folder_path
		}

## Stores the content of the inklecate configuration to the disk.
func _persist_inklecate():
	_compiler_config_file.set_value(FORMAT_SECTION, VERSION, COMPILER_CONFIG_FORMAT_VERSION)

	_compiler_config_file.set_value(INKGD_SECTION, USE_MONO, use_mono)
	_compiler_config_file.set_value(INKGD_SECTION, MONO_PATH, mono_path)
	_compiler_config_file.set_value(INKGD_SECTION, INKLECATE_PATH, inklecate_path)
	_compiler_config_file.set_value(INKGD_SECTION, COMPILATION_MODE, compilation_mode)

	var err = _compiler_config_file.save(COMPILER_CONFIG)
	if err != OK:
		printerr("[inkgd] [ERROR] Could not save: %s" % COMPILER_CONFIG)

## Stores the content of the story configuration to the disk.
func _persist_ink():
	# Clean up the file if it was created before version 2.
	if _ink_config_file.has_section_key(INKGD_SECTION, SOURCE_FILE_PATH):
		_ink_config_file.erase_section_key(INKGD_SECTION, SOURCE_FILE_PATH)

	if _ink_config_file.has_section_key(INKGD_SECTION, TARGET_FILE_PATH):
		_ink_config_file.erase_section_key(INKGD_SECTION, TARGET_FILE_PATH)

	# Write version 2 values.
	_ink_config_file.set_value(FORMAT_SECTION, VERSION, COMPILER_CONFIG_FORMAT_VERSION)
	_ink_config_file.set_value(INKGD_SECTION, STORIES, stories)

	var err = _ink_config_file.save(INK_CONFIG)
	if err != OK:
		printerr("[inkgd] [ERROR] Could not save: %s" % INK_CONFIG)
