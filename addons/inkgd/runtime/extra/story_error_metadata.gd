 # ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

# An object that keeps track of the Debug Metadata and current pointer at the
# exact moment an error was raised, so that they can be processed and reported
# later. It's required because GDScript doesn't support exceptions and
# errors don't bubble up the stack.

class_name StoryErrorMetadata

# ############################################################################ #
# Properties
# ############################################################################ #

var debug_metadata # InkDebugMetadata | null
var pointer: InkPointer

# ############################################################################ #
# Initialization
# ############################################################################ #

func _init(debug_metadata: InkDebugMetadata, pointer: InkPointer):
	self.debug_metadata = debug_metadata
	self.pointer = pointer
