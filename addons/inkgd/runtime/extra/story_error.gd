 # ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

# An object tha represents a "Story Error", which is equivalent in certain
# context to upstream's StoryException.

class_name StoryError

# ############################################################################ #
# Properties
# ############################################################################ #

var message: String
var use_end_line_number: bool
var metadata # StoryErrorMetadata | null

# ############################################################################ #
# Initialization
# ############################################################################ #

func _init(message: String, use_end_line_number: bool, metadata):
	self.message = message
	self.use_end_line_number = use_end_line_number
	self.metadata = metadata
