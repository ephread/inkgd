# ############################################################################ #
# Copyright © 2018-2022 Paul Joannon
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

extends EditorImportPlugin

class_name InkSourceImportPlugin

# ############################################################################ #
# Overrides
# ############################################################################ #

func get_importer_name():
	return "inkgd.ink";

func get_visible_name():
	return "Ink file";

func get_recognized_extensions():
	return ["ink"];

func get_save_extension():
	return "res";

func get_resource_type():
	return "Resource";

func get_import_options(preset):
	return []

func get_option_visibility(option, options):
	return true

func get_preset_count():
	return 0

func import(source_file, save_path, options, r_platform_variants, r_gen_files):
	return ResourceSaver.save(
			"%s.%s" % [save_path, get_save_extension()],
			Resource.new(),
			ResourceSaver.FLAG_COMPRESS
	)
