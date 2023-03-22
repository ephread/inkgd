# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
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
var approximate = false # bool

var correct_obj: InkObject: get = get_correct_obj
func get_correct_obj():
	return null if approximate else obj

var container: InkContainer: get = get_container
func get_container():
	return obj as InkContainer
