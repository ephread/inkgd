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

func _get_import_options(path: String, preset_index: int) -> Array:
	return []

func _get_option_visibility(path: String, option_name: StringName, options: Dictionary) -> bool:
	return true

func _get_preset_count():
	return 0

func _get_import_order() -> int:
	return 0

func _import(source_file, save_path, options, r_platform_variants, r_gen_files):
	return ResourceSaver.save(
			Resource.new(),
			"%s.%s" % [save_path, _get_save_extension()],
			ResourceSaver.FLAG_COMPRESS
	)
