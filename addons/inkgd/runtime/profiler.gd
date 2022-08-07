# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends InkBase

class_name InkProfiler

func _init():
	pass

# () -> String
func report() -> String:
	return ""

# () -> void
func pre_continue() -> void:
	pass

# () -> void
func post_continue() -> void:
	pass

# () -> void
func pre_step() -> void:
	pass

# (CallStack) -> void
func step(callstack: InkCallStack) -> void:
	pass

# () -> void
func post_step() -> void:
	pass

func step_length_record() -> String:
	return ""

func mega_log() -> String:
	return ""

func pre_snapshot() -> void:
	pass

func post_snapshot() -> void:
	pass

func millisecs(watch: InkStopWatch) -> float:
	return 0.0

static func format_millisecs(num: float) -> String:
	return ""
