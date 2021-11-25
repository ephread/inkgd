# warning-ignore-all:unused_class_variable
# ############################################################################ #
# Copyright © 2015-present inkle Ltd.
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

# Simple replacement of the Stopwatch class from the .NET Framework.
# Less accurate than the original implemntation, but good enough for
# the use-case.

var _start_time = null

var elapsed_milliseconds setget , get_elapsed_milliseconds
func get_elapsed_milliseconds():
	if _start_time == null:
		return 0

	return OS.get_ticks_msec() - _start_time

func start():
	_start_time = OS.get_ticks_msec()

func stop():
	_start_time = null
