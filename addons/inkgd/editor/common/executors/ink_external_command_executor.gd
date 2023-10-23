# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

extends RefCounted

class_name InkExternalCommandExecutor

# ############################################################################ #
# Properties
# ############################################################################ #

## The identifier of this compiler.
var identifier: int: get = get_identifier
func get_identifier() -> int:
	return get_instance_id()

# ############################################################################ #
# Constants
# ############################################################################ #

const BOM = "\ufeff"

# ############################################################################ #
# Private Properties
# ############################################################################ #

## Thread used to compile the story.
@warning_ignore("unused_private_class_variable") # Used by subclasses.
var _thread: Thread
