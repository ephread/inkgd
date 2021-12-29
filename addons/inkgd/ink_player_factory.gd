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

static func create():
	if _should_use_mono() && !ProjectSettings.get_setting("inkgd/do_not_use_mono_runtime"):
		var InkPlayer = load("res://addons/inkgd/mono/InkPlayer.cs")
		if InkPlayer.can_instance():
			return InkPlayer.new()
		else:
			printerr(
					"[inkgd] [ERROR] InkPlayer can't be instantiated. Try to rebuild the C# " +
					"solution then disable and reenable InkGD in " +
					"Project > Project setting… > Plugins."
			)
			return null
	else:
		return load("res://addons/inkgd/ink_player.gd").new()


static func _should_use_mono() -> bool:
	return type_exists("_GodotSharp")
