# ############################################################################ #
# Copyright © 2018-2022 Paul Joannon
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

extends EditorImportPlugin

class_name InkJsonImportPlugin

# ############################################################################ #
# Imports
# ############################################################################ #

var InkConfiguration = load("res://addons/inkgd/editor/common/ink_configuration.gd")
var InkResource = load("res://addons/inkgd/editor/import_plugins/ink_resource.gd")

# ############################################################################ #
# Properties
# ############################################################################ #

var _configuration = InkConfiguration.new()

# ############################################################################ #
# Overrides
# ############################################################################ #

func get_importer_name():
	return "inkgd.ink.json";

func get_visible_name():
	return "Compiled ink story";

func get_recognized_extensions():
	return ["json"];

func get_save_extension():
	return "res";

func get_resource_type():
	return "Resource";

func get_import_options(preset):
	return [
		{
			"name": "compress",
			"default_value": true
		}
	]

func get_option_visibility(option, options):
	return true

func get_preset_count():
	return 0

func import(source_file, save_path, options, r_platform_variants, r_gen_files):
	_configuration.retrieve()

	var raw_json = _get_file_content(source_file)

	var json = parse_json(raw_json)
	if !json.has("inkVersion"):
		return ERR_FILE_UNRECOGNIZED

	var resource = InkResource.new()
	resource.json = raw_json

	var flags = ResourceSaver.FLAG_COMPRESS if options["compress"] else 0
	return ResourceSaver.save("%s.%s" % [save_path, get_save_extension()], resource, flags)

# ############################################################################ #
# Private Helpers
# ############################################################################ #

func _get_file_content(source_file):
	var file = File.new()
	var err = file.open(source_file, File.READ)
	if err != OK:
		return err

	var text_content = file.get_as_text()

	file.close()
	return text_content
