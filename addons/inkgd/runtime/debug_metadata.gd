# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends InkBase

class_name InkDebugMetadata

# ############################################################################ #

var start_line_number: int = 0
var end_line_number: int = 0
var start_character_number: int = 0
var end_character_number: int = 0
# String?
var file_name = null
# String?
var source_name = null

# ############################################################################ #

func merge(dm: InkDebugMetadata) -> InkDebugMetadata:
	var new_debug_metadata = InkDebugMetadata.new()

	new_debug_metadata.file_name = file_name
	new_debug_metadata.source_name = source_name

	if start_line_number < dm.start_line_number:
		new_debug_metadata.start_line_number = start_line_number
		new_debug_metadata.start_character_number = start_character_number
	elif start_line_number > dm.start_line_number:
		new_debug_metadata.start_line_number = dm.start_line_number
		new_debug_metadata.start_character_number = dm.start_character_number
	else:
		var min_scn = min(start_character_number, dm.start_character_number)
		new_debug_metadata.start_line_number = start_line_number
		new_debug_metadata.start_character_number = min_scn

	if end_line_number > dm.end_line_number:
		new_debug_metadata.end_line_number = end_line_number
		new_debug_metadata.end_character_number = end_character_number
	elif end_line_number < dm.end_line_number:
		new_debug_metadata.end_line_number = dm.end_line_number
		new_debug_metadata.end_character_number = dm.end_character_number
	else:
		var max_scn = min(end_character_number, dm.end_character_number)
		new_debug_metadata.end_line_number = end_line_number
		new_debug_metadata.end_character_number = max_scn

	return new_debug_metadata

# () -> String
func _to_string() -> String:
	if file_name != null:
		return str("line ", start_line_number, " of ", file_name)
	else:
		return str("line ", start_line_number)

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

static func DebugMetadata():
	return load("res://addons/inkgd/runtime/debug_metadata.gd")
