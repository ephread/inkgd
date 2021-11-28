# ############################################################################ #
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

extends Reference

class_name InkCompiler

# ############################################################################ #
# Constants
# ############################################################################ #

const _BOM = "\ufeff"

# ############################################################################ #
# Properties
# ############################################################################ #

## The identifier of this compiler.
var identifier setget , get_identifier
func get_identifier() -> int:
	return get_instance_id()

# ############################################################################ #
# Private Properties
# ############################################################################ #

## Ink Configuration
var _configuration: Configuration

## Thread used to compile the story.
var _thread: Thread

# ############################################################################ #
# Signals
# ############################################################################ #

signal did_compile(result)

# ############################################################################ #
# Overrides
# ############################################################################ #

func _init(configuration: Configuration):
	_configuration = configuration

	if _configuration.use_threads:
		_thread = Thread.new()

# ############################################################################ #
# Methods
# ############################################################################ #

## Compile the story, based on the compilation configuration provided
## by this object. If `configuration.use_thread` is set to `false`,
## this method will return `true` if the compilation succeeded and `false`
## otherwise. If `configuration.use_thread` is set to `false`, this method
## always returns `true`.
func compile_story() -> bool:
	if _configuration.use_threads:
		_thread.start(self, "_compile_story", _configuration, Thread.PRIORITY_HIGH)
		return true
	else:
		return _compile_story(_configuration)

# ############################################################################ #
# Private Helpers
# ############################################################################ #

## Compile the story, based on the given compilation configuration
## If `configuration.use_thread` is set to `false`, this method will
## return `true` if the compilation succeeded and `false` otherwise.
## If `configuration.use_thread` is set to `false`, this method always
## returns `true`.
func _compile_story(config: Configuration) -> bool:
	print("Executing compilation command…")
	var return_code = 0
	var output = []

	var start_time = OS.get_ticks_msec()

	if config.use_mono:
		return_code = OS.execute(config.mono_path, [
			config.inklecate_path,
			'-o',
			config.target_file_path,
			config.source_file_path
		], true, output, true)
	else:
		return_code = OS.execute(config.inklecate_path, [
			'-o',
			config.target_file_path,
			config.source_file_path
		], true, output, true)
	
	var end_time = OS.get_ticks_msec()
	
	print("Command executed in %dms." % (end_time - start_time))

	var string_output = PoolStringArray(output)
	if _configuration.use_threads:
		call_deferred("_handle_compilation_result", config, return_code, string_output)
		return true
	else:
		var result = _process_compilation_result(config, return_code, string_output)
		return result.success

## Handles the compilation results when exectuted in a different thread.
##
## This method should be executed on the main thread.
func _handle_compilation_result(config: Configuration, return_code: int, output: Array):
	_thread.wait_to_finish()

	var result = _process_compilation_result(config, return_code, output)
	emit_signal("did_compile", result)

## Process the compilation results turning them into an instance of `Result`.
##
## This method will also print to the editor's output panel.
func _process_compilation_result(
	config: Configuration,
	return_code: int,
	output: PoolStringArray
) -> Result:
	var success: bool = (return_code == 0)
	var output_text: String = output.join("\n").replace(_BOM, "").strip_edges()

	if success:
		print("[" + config.source_file_path + "] was successfully compiled.")
		if output_text.length() > 0:
			print(output_text)
	else:
		printerr("Could not compile [" + config.source_file_path + "].")
		printerr(output_text)

	return Result.new(self.identifier, config.use_threads, success, output_text)

# ############################################################################ #
# Inner Classes
# ############################################################################ #

class Configuration extends Reference:
	var use_threads: bool = false

	var use_mono: bool = false

	var mono_path: String = ""
	var inklecate_path: String = ""
	var source_file_path: String = ""
	var target_file_path: String = ""

	func _init(configuration: InkConfiguration, use_threads: bool):
		self.use_threads = use_threads

		self.use_mono = !_is_running_on_windows() && configuration.use_mono

		self.mono_path = configuration.mono_path
		self.inklecate_path = configuration.inklecate_path
		self.source_file_path = ProjectSettings.globalize_path(configuration.source_file_path)
		self.target_file_path = ProjectSettings.globalize_path(configuration.target_file_path)

	func _is_running_on_windows():
		var os_name = OS.get_name()
		return (os_name == "Windows" || os_name == "UWP")

class Result extends Reference:
	var compiler_identifier: int = 0

	## `true` to compile the story in a thread, `false` otherwise. It's
	## advised to use threads when the compilation was triggered by the user.
	var use_threads: bool = false

	var success: bool = false
	var output: String = ""

	func _init(
		identifier: int,
		use_threads: bool,
		success: bool,
		output: String
	):
		self.compiler_identifier = identifier
		self.use_threads = use_threads
		self.success = success
		self.output = output
