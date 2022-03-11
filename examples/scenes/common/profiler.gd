# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

extends Reference

class_name InkGDProfiler

# ############################################################################ #
# Properties
# ############################################################################ #

var milliseconds_elaspsed: int setget , get_milliseconds_elaspsed
func get_milliseconds_elaspsed():
	if _start_time == -1 || _end_time == -1:
		return 0

	return _end_time - _start_time


# ############################################################################ #
# Private properties
# ############################################################################ #

var _start_time: int = -1
var _end_time: int = -1


# ############################################################################ #
# Methods
# ############################################################################ #

func start():
	_start_time = OS.get_ticks_msec()


func stop():
	_end_time = OS.get_ticks_msec()


func reset():
	_start_time = 0
	_end_time = 0
