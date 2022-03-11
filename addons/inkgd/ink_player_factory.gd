# ############################################################################ #
# Copyright © 2018-2021 Paul Joannon
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

tool
extends Reference

class_name InkPlayerFactory

const DO_NOT_USE_MONO_RUNTIME_SETTING = "inkgd/do_not_use_mono_runtime"

# ############################################################################ #
# Methods
# ############################################################################ #

static func create():
	if _should_use_mono():
		var InkPlayer = load("res://addons/inkgd/mono/InkPlayer.cs")
		if InkPlayer.can_instance():
			return InkPlayer.new()
		else:
			printerr(
					"[inkgd] [ERROR] InkPlayer can't be instantiated. Make sure that a suitable " +
					"copy of 'ink-runtime-engine.dll' can be found in project and double check " +
					"that the .csproj file contains a <Reference> item pointing to it. " +
					"If everything is configured correctly, you may need to rebuild " +
					"the C# solution. Please refer to [TO BE ADDED] for additional help."
			)
			print("[inkgd] [INFO] Falling back to the GDScript runtime.")

	# Falling back to GDscript.
	return load("res://addons/inkgd/ink_player.gd").new()


static func _should_use_mono() -> bool:
	if ProjectSettings.has_setting(DO_NOT_USE_MONO_RUNTIME_SETTING):
		var do_not_use_mono = ProjectSettings.get_setting(DO_NOT_USE_MONO_RUNTIME_SETTING)
		if do_not_use_mono == null:
			do_not_use_mono = false

		return _can_run_mono() && !do_not_use_mono
	else:
		return _can_run_mono()

static func _can_run_mono() -> bool:
	return type_exists("_GodotSharp")
