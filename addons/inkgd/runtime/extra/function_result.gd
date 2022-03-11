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

class_name InkFunctionResult

# ############################################################################ #

var text_output: String = ""
var return_value = null

# ############################################################################ #

func _init(text_output: String, return_value):
	self.text_output = text_output
	self.return_value = return_value
