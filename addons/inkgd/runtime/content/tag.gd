# ############################################################################ #
# Copyright © 2015-present inkle Ltd.
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends InkObject

class_name InkTag

var text: String

func _init(tag_text: String):
	text = tag_text

func _to_string() -> String:
	return '# ' + text

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type: String) -> bool:
	return type == "Tag" || .is_class(type)

func get_class() -> String:
	return "Tag"
