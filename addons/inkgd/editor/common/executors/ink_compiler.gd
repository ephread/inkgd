# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

extends InkExternalCommandExecutor

class_name InkCompiler

# ############################################################################ #
# Imports
# ############################################################################ #

var InkExecutionResult = load("res://addons/inkgd/editor/common/executors/structures/ink_execution_result.gd")

# ############################################################################ #
# Private Properties
# ############################################################################ #

## Ink Configuration
var _configuration: InkCompilationConfiguration

# ############################################################################ #
# Signals
# ############################################################################ #

## Emitted when a compilation completed. Note that this doesn't imply that
## the compulation was successful. Check the content of result
## (InkCompiler.Result) for more information.
signal story_compiled(result)

# ############################################################################ #
# Overrides
# ############################################################################ #

func _init(configuration: InkCompilationConfiguration):
	_configuration = configuration

	if _configuration.use_threads:
		_thread = Thread.new()

# ############################################################################ #
# Methods
# ############################################################################ #

## Compile the story, based on the compilation configuration provided
## by this object. If `configuration.use_thread` is set to `false`,
## this method will return `true` if the compilation succeeded and `false`
## otherwise. If `configuration.use_thread` is set to `true`, this method
## always returns `true`.
func compile_story() -> bool:
	if _configuration.use_threads:
		var error = _thread.start(self, "_compile_story", _configuration, Thread.PRIORITY_HIGH)

		if error != OK:
			var result = InkExecutionResult.new(
				self.identifier,
				_configuration.use_threads,
				_configuration.user_triggered,
				false,
				""
			)

			call_deferred("emit_signal", "story_compiled", result)

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
func _compile_story(config: InkCompilationConfiguration) -> bool:
	print("[inkgd] [INFO] Executing compilation command…")
	var return_code = 0
	var output = []

	var start_time = OS.get_ticks_msec()

	if config.use_mono:
		var args = [config.inklecate_path, '-o', config.target_file_path, config.source_file_path]
		return_code = OS.execute(config.mono_path, args, true, output, true)
	else:
		var args = ['-o', config.target_file_path, config.source_file_path]
		return_code = OS.execute(config.inklecate_path, args, true, output, true)

	var end_time = OS.get_ticks_msec()

	print("[inkgd] [INFO] Command executed in %dms." % (end_time - start_time))

	var string_output = PoolStringArray(output)
	if _configuration.use_threads:
		call_deferred("_handle_compilation_result", config, return_code, string_output)
		return true
	else:
		var result = _process_compilation_result(config, return_code, string_output)
		return result.success


## Handles the compilation results when exectuted in a different thread.
##
## This method should always be executed on the main thread.
func _handle_compilation_result(
	config: InkCompilationConfiguration,
	return_code: int,
	output: Array
):
	_thread.wait_to_finish()

	var result = _process_compilation_result(config, return_code, output)
	emit_signal("story_compiled", result)


## Process the compilation results turning them into an instance of `Result`.
##
## This method will also print to the editor's output panel.
func _process_compilation_result(
	config: InkCompilationConfiguration,
	return_code: int,
	output: PoolStringArray
) -> InkExecutionResult:
	var success: bool = (return_code == 0)
	var output_text: String = output.join("\n").replace(BOM, "").strip_edges()

	if success:
		print("[inkgd] [INFO] %s was successfully compiled." % config.source_file_path)
		if output_text.length() > 0:
			print(output_text)
	else:
		printerr("[inkgd] [ERROR] Could not compile %s." % config.source_file_path)
		printerr(output_text)

	return InkExecutionResult.new(
			self.identifier,
			config.use_threads,
			config.user_triggered,
			success,
			output_text
	)
