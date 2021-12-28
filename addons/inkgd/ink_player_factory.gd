# ############################################################################ #
# Copyright © 2018-present Paul Joannon
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

tool
extends Node

class_name InkPlayerFactory

# ############################################################################ #
# Methods
# ############################################################################ #

static func create() -> InkPlayer:
	if _should_use_mono() && !ProjectSettings.get_setting("inkgd/do_not_use_mono_runtime"):
		return load("res://addons/inkgd/mono_support/InkPlayer.cs").new()
	else:
		return load("res://addons/inkgd/ink_player.gd").new()


static func _should_use_mono() -> bool:
	return type_exists("_GodotSharp")
