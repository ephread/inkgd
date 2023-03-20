# ############################################################################ #
# Copyright © 2018-2022 Paul Joannon
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

extends EditorImportPlugin

class_name InkJsonImportPlugin

# ############################################################################ #
# Properties
# ############################################################################ #

var _configuration = InkConfiguration.new()

# ############################################################################ #
# Overrides
# ############################################################################ #

func _get_importer_name():
	return "inkgd.ink.json";

func _get_visible_name():
	return "Compiled ink story";

func _get_recognized_extensions():
	return ["json"];

func _get_save_extension():
	return "res";

func _get_resource_type():
	return "Resource";

func _get_import_options(path: String, preset_index: int) -> Array:
	return [
		{
			"name": "compress",
			"default_value": true
		}
	]

func _get_option_visibility(path: String, option_name: StringName, options: Dictionary) -> bool:
	return true

func _get_preset_count():
	return 0

func _get_import_order() -> int:
	return 0

func _import(source_file, save_path, options, r_platform_variants, r_gen_files):
	_configuration.retrieve()

	var raw_json = FileAccess.get_file_as_string(source_file)

	var test_json_conv = JSON.new()
	test_json_conv.parse(raw_json)
	var json = test_json_conv.get_data()
	if !json.has("inkVersion"):
		return ERR_FILE_UNRECOGNIZED

	var resource = InkResource.new()
	resource.json = raw_json

	var flags = ResourceSaver.FLAG_COMPRESS if options["compress"] else 0
	return ResourceSaver.save(resource, "%s.%s" % [save_path, _get_save_extension()], flags)
