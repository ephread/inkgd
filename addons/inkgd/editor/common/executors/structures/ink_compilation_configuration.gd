# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

extends InkExecutionConfiguration

## Contains all the configuration settings necessary to perform a compilation.
class_name InkCompilationConfiguration

# ############################################################################ #
# Properties
# ############################################################################ #

## The path to the story to compile, local to the file system.
var source_file_path: String = ""

## The path to the compiled story, local to the file system.
var target_file_path: String = ""

# ############################################################################ #
# Overrides
# ############################################################################ #

func _init(
	configuration: InkConfiguration,
	use_threads: bool,
	user_triggered: bool,
	source_file_path: String,
	target_file_path: String
).(configuration, use_threads, user_triggered):
	self.source_file_path = ProjectSettings.globalize_path(source_file_path)
	self.target_file_path = ProjectSettings.globalize_path(target_file_path)

# ############################################################################ #
# Private Methods
# ############################################################################ #

func _is_running_on_windows():
	var os_name = OS.get_name()
	return (os_name == "Windows" || os_name == "UWP")
