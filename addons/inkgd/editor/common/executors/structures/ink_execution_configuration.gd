# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

tool
extends Reference

## Contains all the configuration settings necessary to perform an execution.
class_name InkExecutionConfiguration

# ############################################################################ #
# Properties
# ############################################################################ #

var use_threads: bool = false
var user_triggered: bool = false


var use_mono: bool = false
var mono_path: String = ""
var inklecate_path: String = ""

# ############################################################################ #
# Overrides
# ############################################################################ #

func _init(
	configuration: InkConfiguration,
	use_threads: bool,
	user_triggered: bool
):
	self.use_threads = use_threads
	self.user_triggered = user_triggered

	self.use_mono = !_is_running_on_windows() && configuration.use_mono

	self.mono_path = configuration.mono_path
	self.inklecate_path = configuration.inklecate_path

# ############################################################################ #
# Private Methods
# ############################################################################ #

func _is_running_on_windows():
	var os_name = OS.get_name()
	return (os_name == "Windows" || os_name == "UWP")
