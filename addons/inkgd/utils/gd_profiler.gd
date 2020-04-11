# ############################################################################ #
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

var block_call_times: Dictionary = {}
var block_calls: Array = []

var _current_call: BlockCall = null

func enter(block_name: String):

    var new_call = BlockCall.new()
    new_call.name = block_name
    new_call.start_time = OS.get_ticks_usec()
    new_call.end_time = OS.get_ticks_usec()

    if _current_call:
        new_call.parent = weakref(_current_call)
        _current_call.inner_calls.append(new_call)
    else:
        block_calls.append(new_call)

    _current_call = new_call

func exit(description: String = ""):
    if _current_call == null:
        printerr("Mismatched enter/exit calls, times will be incorrect.")
        return

    _current_call.end_time = OS.get_ticks_usec()
    _current_call.description = description

    var block_call_time: BlockCallTime
    if block_call_times.has(_current_call.name):
        block_call_time = block_call_times[_current_call.name]
    else:
        block_call_time = BlockCallTime.new()
        block_call_time.name = _current_call.name
        block_call_times[block_call_time.name] = block_call_time

    block_call_time.total_time += _current_call.elaspsed_time
    block_call_time.number_of_calls += 1

    var parent = _current_call.parent
    if parent:
        _current_call = parent.get_ref()
    else:
        _current_call = null

func ordered_block_calls():
    var all_block_call_times = block_call_times.values()
    all_block_call_times.sort_custom(self, "_sort_block_call_times")

    var return_str = ""
    for block_call_time in all_block_call_times:
        return_str += str(
            block_call_time.number_of_calls, "us • ", block_call_time.total_time, " • (",
            block_call_time.name, ")\n"
        )

    return return_str

func block_call_hierarchy(block_call = null, indent = 0):
    var return_str = "name, time\n" if (block_call == null) else ""

    var block_calls
    if block_call == null:
        block_calls = self.block_calls
    else:
        return_str += str("%", indent, "s") % "∟ "
        return_str += str(block_call.name, " ", block_call.description, " • ", block_call.elaspsed_time , "μs", "\n")

        block_calls = block_call.inner_calls

    for block_call in block_calls:
        return_str += block_call_hierarchy(block_call, indent + 1)

    return return_str

func block_call_hierarchy_as_csv(block_call = null):
    var return_str = ""

    var block_calls
    if block_call == null:
        block_calls = self.block_calls
    else:
        return_str += str(block_call.name, " ", block_call.description, ", ", block_call.elaspsed_time, "\n")

        block_calls = block_call.inner_calls

    for block_call in block_calls:
        return_str += block_call_hierarchy_as_csv(block_call)

    return return_str

class BlockCallTime:
    var name: String = ""
    var total_time: int = 0
    var number_of_calls: int = 0

class BlockCall:
    var name: String = ""
    var description: String = ""
    var inner_calls: Array = []
    var parent: WeakRef = null

    var start_time: int = 0
    var end_time: int = 0

    var elaspsed_time: int setget , get_elaspsed_time
    func get_elaspsed_time():
        return end_time - start_time
