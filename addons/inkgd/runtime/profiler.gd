# ############################################################################ #
# Copyright © 2015-present inkle Ltd.
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://addons/inkgd/runtime/ink_base.gd"

func _init():
	pass

# () -> String
func report():
	return ""

# () -> void
func pre_continue():
	pass

# () -> void
func post_continue():
	pass

# () -> void
func pre_step():
	pass

# (CallStack) -> void
func step(callstack):
	pass

# () -> void
func post_step():
	pass

# () -> String
func step_length_record():
	return ""

# () -> String
func mega_log():
	return ""

# () -> void
func pre_snapshot():
	pass

# () -> void
func post_snapshot():
	pass

# (Stopwatch) -> float
func millisecs(watch):
	pass

# (float) -> String
static func format_millisecs(num):
	return ""
