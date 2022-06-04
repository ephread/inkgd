# warning-ignore-all:unused_class_variable
# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

# Simple replacement of the Stopwatch class from the .NET Framework.
# Less accurate than the original implemntation, but good enough for
# the use-case.

class_name InkStopWatch

# ############################################################################ #

var _start_time: int = -1

var elapsed_milliseconds setget , get_elapsed_milliseconds
func get_elapsed_milliseconds() -> int:
	if _start_time == -1:
		return 0

	return OS.get_ticks_msec() - _start_time

# ############################################################################ #

func start() -> void:
	_start_time = OS.get_ticks_msec()

func stop() -> void:
	_start_time = -1
