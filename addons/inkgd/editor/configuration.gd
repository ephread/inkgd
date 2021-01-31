# ############################################################################ #
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

extends Object

const _ROOT_DIR = "res://"

const _COMPILER_CONFIG = _ROOT_DIR + ".inkgd_compiler.cfg"
const _INK_CONFIG = _ROOT_DIR + ".inkgd_ink.cfg"

# ############################################################################ #
# Properties
# ############################################################################ #

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
	retrieve()

# ############################################################################ #
# Public Methods
# ############################################################################ #

func retrieve():
	retrieve_inklecate()
	retrieve_ink()

func persist():
	persist_inklecate()
	persist_ink()

func retrieve_inklecate():
	var err = _compiler_config_file.load(_COMPILER_CONFIG)
	if err != OK:
		# Assuming it doesn't exist.
		mono_path = ""
		inklecate_path = ""
		return


	mono_path = _compiler_config_file.get_value("inkgd", "mono_path", "")
	inklecate_path = _compiler_config_file.get_value("inkgd", "inklecate_path", "")

func retrieve_ink():
	var err = _ink_config_file.load(_INK_CONFIG)
	if err != OK:
		# Assuming it doesn't exist.
		source_file_path = ""
		target_file_path = ""
		return

	source_file_path = _ink_config_file.get_value("inkgd", "source_file_path", "")
	target_file_path = _ink_config_file.get_value("inkgd", "target_file_path", "")


func persist_inklecate():
	_compiler_config_file.set_value("inkgd", "mono_path", mono_path)
	_compiler_config_file.set_value("inkgd", "inklecate_path", inklecate_path)

	var err = _compiler_config_file.save(_COMPILER_CONFIG)
	if err != OK:
		printerr("Could not save: " + _COMPILER_CONFIG)

func persist_ink():
	_ink_config_file.set_value("inkgd", "source_file_path", source_file_path)
	_ink_config_file.set_value("inkgd", "target_file_path", target_file_path)

	var err = _ink_config_file.save(_INK_CONFIG)
	if err != OK:
		printerr("Could not save: " + _INK_CONFIG)
