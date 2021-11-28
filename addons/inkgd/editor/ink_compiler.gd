# ############################################################################ #
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

extends Reference

class_name InkCompiler

# ############################################################################ #

var _configuration: Configuration
var _thread: Thread
var _last_execution_result: Result
var _use_thread: bool

var identifier setget , get_identifier
func get_identifier() -> int:
	return get_instance_id()

# ############################################################################ #

signal did_compile(result)

# ############################################################################ #

func _init(configuration: Configuration):
	_configuration = configuration

	if _configuration.use_threads:
		_thread = Thread.new()

# ############################################################################ #

func compile_story() -> bool:
	if _configuration.use_threads:
		_thread.start(self, "_compile_story", _configuration, Thread.PRIORITY_HIGH)
		return true
	else:
		return _compile_story(_configuration)

# ############################################################################ #

func _compile_story(config: Configuration) -> bool:
	print("Executing compilation command…")
	var return_code = 0
	var output = []

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
	
	print(str("Compilation ", "succeeded" if return_code == 0 else "failed."))

	_last_execution_result = Result.new(
		self.identifier,
		config.use_threads,
		return_code,
		PoolStringArray(output)
	)
	
	_process_compilation_result(config, _last_execution_result)

	if _configuration.use_threads:
		call_deferred("_handle_compilation_result", _last_execution_result)
	
	return return_code == 0

func _handle_compilation_result(result: Result):
	_thread.wait_to_finish()
	emit_signal("did_compile", result)

func _process_compilation_result(config: Configuration, result: Result):
	var output_text = result.output.join("\n")
	if result.return_code == 0:
		print(str("[", config.source_file_path ,"] was successfully compiled."))

		if output_text.strip_edges().length() > 0:
			push_warning(output_text)
	else:
		print(str("Could not compile [", config.source_file_path ,"]."))
		push_error(output_text)

# ############################################################################ #

class Configuration:
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

class Result:
	var compiler_identifier: int
	var use_threads: bool
	
	var return_code: int
	var output: PoolStringArray
	
	func _init(
		identifier: int,
		use_threads: bool,
		return_code: bool,
		output: PoolStringArray
	):
		self.compiler_identifier = identifier
		self.use_threads = use_threads
		self.return_code = return_code
		self.output = output
