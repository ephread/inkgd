# warning-ignore-all:shadowed_variable
# ############################################################################ #
# Copyright © 2015-present inkle Ltd.
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends Reference

var exists = false # Bool
var result = null # Variant

func _init(exists, result):
	self.exists = exists
	self.result = result
