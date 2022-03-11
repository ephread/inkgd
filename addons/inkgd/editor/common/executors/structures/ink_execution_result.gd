# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

extends Reference

## A test result, containing information about whether the test
## suceeded and the generated output.
class_name InkExecutionResult

# ############################################################################ #
# Properties
# ############################################################################ #

## The identifier of the compiler that generated this result.
## This is the value of 'InkExecutor.identifier'.
var identifier: int = 0

var use_threads: bool = false
var user_triggered: bool = false

var success: bool = false

var output: String = ""

# ############################################################################ #
# Overrides
# ############################################################################ #

func _init(
	identifier: int,
	use_threads: bool,
	user_triggered: bool,
	success: bool,
	output: String
):
	self.identifier = identifier
	self.use_threads = use_threads
	self.user_triggered = user_triggered
	self.success = success
	self.output = output
