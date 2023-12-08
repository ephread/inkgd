# ############################################################################ #
# Copyright © 2019-2023 Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

extends RefCounted

# A crude validator catching the most common mistakes.

class_name InkCSharpValidator

const INK_ENGINE_RUNTIME = "ink-engine-runtime.dll"

# ############################################################################ #
# Methods
# ############################################################################ #

func validate_csharp_project_files(project_name) -> bool:
	var ink_engine_runtime := get_runtime_path()

	if ink_engine_runtime.is_empty():
		print(
				"[inkgd] [INFO] 'ink-engine-runtime.dll' seems to be missing " +
				"from the project. If you encounter errors while building the " +
				"solution, please refer to [TO BE ADDED] for help."
		)
		return false

	return _validate_csproj(project_name, ink_engine_runtime)

func get_runtime_path() -> String:
	return _scan_directory("res://")

func _validate_csproj(project_name: String, runtime_path: String) -> bool:
	var csproj_path = "res://%s.csproj" % project_name

	if !FileAccess.file_exists(csproj_path):
		printerr(
				("[inkgd] [ERROR] The C# project (%s.csproj) doesn't exist. " % project_name) +
				"You can create a new C# project through " +
				"Project > Tools > C# > Create C# Solution. Alternatively, you can also set " +
				"Project Settings > General > Inkgd > Do Not Use Mono Runtime to 'Yes' " +
				"if you do not wish to use the C# version of Ink. "
		)
		return false

	var file := FileAccess.open(csproj_path, FileAccess.READ)
	var error := FileAccess.get_open_error()
	if error != OK:
		printerr(
				"[inkgd] [ERROR] The C# project (%s.csproj) exists but it could not be opened." +
				"(Code %d)" % [project_name, error]
		)
		return false

	var content := file.get_as_text()
	file.close()

	if content.find(runtime_path.replace("res://", "")) == -1:
		print(
				"[inkgd] [INFO] '%s.csproj' seems to be missing a " % project_name +
				"<RefCounted> item matching '%s'. If you encounter " % runtime_path +
				"further errors please refer to [TO BE ADDED] for help."
		)
		return false

	print("[inkgd] [INFO] The C# Project seems to be configured correctly.")
	return true

func _scan_directory(path) -> String:
	var directory := DirAccess.open(path)
	var error := DirAccess.get_open_error()
	if error != OK:
		printerr(
				"[inkgd] [ERROR] Could not open '%s', " % path +
				"can't look for ink-engine-runtime.dll."
		)
		return ""

	if directory.list_dir_begin()  != OK:# TODOConverter3To4 fill missing arguments https://github.com/godotengine/godot/pull/40547
		printerr(
				"[inkgd] [ERROR] Could not list contents of '%s', " % path +
				"can't look for ink-engine-runtime.dll."
		)
		return ""

	var file_name := directory.get_next()
	while file_name != "":
		if directory.current_is_dir():
			var ink_runtime = _scan_directory(
					"%s/%s" % [directory.get_current_dir(), file_name]
			)

			if !ink_runtime.is_empty():
				return ink_runtime
		else:
			if file_name == INK_ENGINE_RUNTIME:
				return "%s/%s" % [directory.get_current_dir(), file_name]

		file_name = directory.get_next()

	return ""
