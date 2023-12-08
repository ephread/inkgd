# ############################################################################ #
# Copyright © 2018-2022 Paul Joannon
# Copyright © 2019-2023 Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

extends EditorImportPlugin

class_name InkSourceImportPlugin

# ############################################################################ #
# Overrides
# ############################################################################ #

func _get_importer_name():
	return "inkgd.ink";

func _get_visible_name():
	return "Ink file";

func _get_recognized_extensions():
	return ["ink"];

func _get_save_extension():
	return "res";

func _get_resource_type():
	return "Resource";

func _get_priority():
	return 1.0

func _get_import_options(_path, _preset):
	return []

func _get_import_order():
	return 0

func _get_option_visibility(_path, _option_name, _options):
	return true

func _get_preset_count():
	return 0

func _import(_source_file, save_path, _options, _platform_variants, _gen_files):
	return ResourceSaver.save(
			Resource.new(),
			"%s.%s" % [save_path, _get_save_extension()],
			ResourceSaver.FLAG_COMPRESS
	)
