# warning-ignore-all:unused_class_variable
# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2023 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

# ############################################################################ #
# !! VALUE TYPE
# ############################################################################ #

# Search results are never duplicated / passed around so they don't need to
# be either immutable or have a 'duplicate' method.

extends InkBase

class_name InkSearchResult

# ############################################################################ #

var obj: InkObject = null
var approximate: bool = false

var correct_obj: InkObject:
	get: return null if approximate else obj

var container: InkContainer:
	get: return InkUtils.as_or_null(obj, "InkContainer")

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_ink_class(type: String) -> bool:
	return type == "SearchResult" || super.is_ink_class(type)

func get_ink_class() -> String:
	return "SearchResult"
