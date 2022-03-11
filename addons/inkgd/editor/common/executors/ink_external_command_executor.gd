# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

extends Reference

class_name InkExternalCommandExecutor

# ############################################################################ #
# Properties
# ############################################################################ #

## The identifier of this compiler.
var identifier: int setget , get_identifier
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
var _thread: Thread
