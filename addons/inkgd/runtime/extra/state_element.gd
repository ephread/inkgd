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

# This element is only used during JSON parsing and is never duplicated / passed
# around so it doesn't need to be either immutable or have a 'duplicate' method.

class_name InkStateElement

# ############################################################################ #

enum State {
	NONE,
	OBJECT,
	ARRAY,
	PROPERTY,
	PROPERTY_NAME,
	STRING,
}

# ############################################################################ #

var type: int = State.NONE # State
var child_count: int = 0

# ############################################################################ #

func _init(type: int):
	self.type = type
