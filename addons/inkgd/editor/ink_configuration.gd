# ############################################################################ #
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

tool
extends Reference

class_name InkConfiguration

# ############################################################################ #
# Constants
# ############################################################################ #

const _ROOT_DIR = "res://"

const _COMPILER_CONFIG = _ROOT_DIR + ".inkgd_compiler.cfg"
const _INK_CONFIG = _ROOT_DIR + ".inkgd_ink.cfg"

# ############################################################################ #
# Properties
# ############################################################################ #

var use_mono: bool = false
var mono_path: String = ""
var inklecate_path: String = ""
var source_file_path: String = ""
var target_file_path: String = ""

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

# ############################################################################ #
# Private Methods
# ############################################################################ #

## Loads the content of the inklecate configuration file from disk.
func _retrieve_inklecate():
	var err = _compiler_config_file.load(_COMPILER_CONFIG)
	if err != OK:
		# Assuming it doesn't exist.
		mono_path = ""
		inklecate_path = ""
		return

	use_mono = _compiler_config_file.get_value("inkgd", "use_mono", false)
	mono_path = _compiler_config_file.get_value("inkgd", "mono_path", "")
	inklecate_path = _compiler_config_file.get_value("inkgd", "inklecate_path", "")

## Loads the content of the story configuration file from disk.
func _retrieve_ink():
	var err = _ink_config_file.load(_INK_CONFIG)
	if err != OK:
		# Assuming it doesn't exist.
		source_file_path = ""
		target_file_path = ""
		return

	source_file_path = _ink_config_file.get_value("inkgd", "source_file_path", "")
	target_file_path = _ink_config_file.get_value("inkgd", "target_file_path", "")


## Stores the content of the inklecate configuration to the disk.
func _persist_inklecate():
	_compiler_config_file.set_value("inkgd", "use_mono", use_mono)
	_compiler_config_file.set_value("inkgd", "mono_path", mono_path)
	_compiler_config_file.set_value("inkgd", "inklecate_path", inklecate_path)

	var err = _compiler_config_file.save(_COMPILER_CONFIG)
	if err != OK:
		printerr("Could not save: " + _COMPILER_CONFIG)

## Stores the content of the story configuration to the disk.
func _persist_ink():
	_ink_config_file.set_value("inkgd", "source_file_path", source_file_path)
	_ink_config_file.set_value("inkgd", "target_file_path", target_file_path)

	var err = _ink_config_file.save(_INK_CONFIG)
	if err != OK:
		printerr("Could not save: " + _INK_CONFIG)
