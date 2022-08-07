# warning-ignore-all:shadowed_variable
# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #


extends Reference

class_name InkTryGetResult

# ############################################################################ #

var exists: bool = false # Bool
var result = null # Variant

# ############################################################################ #

func _init(exists: bool, result):
	self.exists = exists
	self.result = result
