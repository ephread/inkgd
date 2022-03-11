# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

extends InkExternalCommandExecutor

class_name InkConfigurationTester

# ############################################################################ #
# Imports
# ############################################################################ #

var InkExecutionResult = load("res://addons/inkgd/editor/common/executors/structures/ink_execution_result.gd")

# ############################################################################ #
# Private Properties
# ############################################################################ #

## Ink Configuration
var _configuration: InkExecutionConfiguration

# ############################################################################ #
# Signals
# ############################################################################ #

## Emitted when a test  completed. Note that this doesn't imply that
## the test was successful. Check the content of result
## (InkConfigurationTester.Result) for more information.
signal availability_tested(result)

# ############################################################################ #
# Overrides
# ############################################################################ #

func _init(configuration: InkExecutionConfiguration):
	_configuration = configuration

	if _configuration.use_threads:
		_thread = Thread.new()

# ############################################################################ #
# Methods
# ############################################################################ #

## Test inklecate's availability, based on the configuration provided by this object.
## If `configuration.use_thread` is set to `false`, this method will return
## an instance of `InkExecutionResult`, otherwise, it will return `null`.
func test_availability():
	if _configuration.use_threads:
		var error = _thread.start(self, "_test_availablity", _configuration, Thread.PRIORITY_HIGH)
		if error != OK:
			var result = InkExecutionResult.new(
				self.identifier,
				_configuration.use_threads,
				_configuration.user_triggered,
				false,
				""
			)

			emit_signal("availability_tested", result)
		return true
	else:
		return _test_availability(_configuration)

# ############################################################################ #
# Private Helpers
# ############################################################################ #

## Test inklecate's availability, based on the configuration provided by this object
## If `configuration.use_thread` is set to `false`, this method will return
## an instance of `InkExecutionResult`, otherwise, it will return `null`.
func _test_availability(config: InkExecutionConfiguration):
	print("[inkgd] [INFO] Executing test command…")
	var return_code = 0
	var output = []

	var start_time = OS.get_ticks_msec()

	if config.use_mono:
		var args = [config.inklecate_path]
		return_code = OS.execute(config.mono_path, args, true, output, true)

	else:
		return_code = OS.execute(config.inklecate_path, [], true, output, true)

	var end_time = OS.get_ticks_msec()

	print("[inkgd] [INFO] Command executed in %dms." % (end_time - start_time))

	var string_output = PoolStringArray(output)
	if _configuration.use_threads:
		call_deferred("_handle_test_result", config, return_code, string_output)
		return null
	else:
		return _process_test_result(config, return_code, string_output)


## Handles the test result when exectuted in a different thread.
##
## This method should always be executed on the main thread.
func _handle_test_result(config: InkExecutionConfiguration, return_code: int, output: Array):
	_thread.wait_to_finish()

	var result = _process_test_result(config, return_code, output)
	emit_signal("availability_tested", result)


## Process the compilation results turning them into an instance of `Result`.
##
## This method will also print to the editor's output panel.
func _process_test_result(
	config: InkExecutionConfiguration,
	return_code: int,
	output: PoolStringArray
) -> InkExecutionResult:
	var success: bool = (return_code == 0 || _contains_inklecate_output_prefix(output))
	var output_text: String = output.join("\n").replace(BOM, "").strip_edges()

	if success:
		if !output_text.empty():
			print("[inkgd] [INFO] inklecate was found and executed:")
			print(output_text)
		else:
			print("[inkgd] [INFO] inklecate was found and executed.")
	else:
		printerr("[inkgd] [ERROR] Something went wrong while testing inklecate's setup.")
		printerr(output_text)

	return InkExecutionResult.new(
			self.identifier,
			config.use_threads,
			config.user_triggered,
			success,
			output_text
	)


## Guess whether the provided `output_array` looks like the usage inklecate
## outputs when run with no parameters.
func _contains_inklecate_output_prefix(output_array: PoolStringArray):
	# No valid output -> it's not inklecate.
	if output_array.size() == 0: return false

	# The first line of the output is cleaned up by removing the BOM and
	# any sort of whitespace/unprintable character.
	var cleaned_line = output_array[0].replace(BOM, "").strip_edges()

	# If the first line starts with the correct substring, it's likely
	# to be inklecate!
	return cleaned_line.find("Usage: inklecate2") == 0
