# ############################################################################ #
# Copyright © 2015-present inkle Ltd.
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

tool
extends InkObject

class_name InkGlue

# ############################################################################ #

func to_string() -> String:
	return "Glue"

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type: String) -> bool:
	return type == "Glue" || .is_class(type)

func get_class() -> String:
	return "Glue"
