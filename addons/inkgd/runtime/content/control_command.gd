# warning-ignore-all:shadowed_variable
# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends InkObject

class_name InkControlCommand

# ############################################################################ #
# Imports
# ############################################################################ #

static func ControlCommand() -> GDScript:
	return load("res://addons/inkgd/runtime/control_command.gd") as GDScript

# ############################################################################ #

enum CommandType {
	NOT_SET = -1,
	EVAL_START,
	EVAL_OUTPUT,
	EVAL_END,
	DUPLICATE,
	POP_EVALUATED_VALUE,
	POP_FUNCTION,
	POP_TUNNEL,
	BEGIN_STRING,
	END_STRING,
	NO_OP,
	CHOICE_COUNT,
	TURNS,
	TURNS_SINCE,
	READ_COUNT,
	RANDOM,
	SEED_RANDOM,
	VISIT_INDEX,
	SEQUENCE_SHUFFLE_INDEX,
	START_THREAD,
	DONE,
	END,
	LIST_FROM_INT,
	LIST_RANGE,
	LIST_RANDOM,
	#----
	TOTAL_VALUES
}

# ############################################################################ #

# CommandType
var command_type: int

# ############################################################################ #

func _init(command_type: int = CommandType.NOT_SET):
	self.command_type = command_type

# ############################################################################ #

func copy() -> InkControlCommand:
	return ControlCommand().new(self.command_type)

static func eval_start() -> InkControlCommand:
	return ControlCommand().new(CommandType.EVAL_START)

static func eval_output() -> InkControlCommand:
	return ControlCommand().new(CommandType.EVAL_OUTPUT)

static func eval_end() -> InkControlCommand:
	return ControlCommand().new(CommandType.EVAL_END)

static func duplicate() -> InkControlCommand:
	return ControlCommand().new(CommandType.DUPLICATE)

static func pop_evaluated_value() -> InkControlCommand:
	return ControlCommand().new(CommandType.POP_EVALUATED_VALUE)

static func pop_function() -> InkControlCommand:
	return ControlCommand().new(CommandType.POP_FUNCTION)

static func pop_tunnel() -> InkControlCommand:
	return ControlCommand().new(CommandType.POP_TUNNEL)

static func begin_string() -> InkControlCommand:
	return ControlCommand().new(CommandType.BEGIN_STRING)

static func end_string() -> InkControlCommand:
	return ControlCommand().new(CommandType.END_STRING)

static func no_op() -> InkControlCommand:
	return ControlCommand().new(CommandType.NO_OP)

static func choice_count() -> InkControlCommand:
	return ControlCommand().new(CommandType.CHOICE_COUNT)

static func turns() -> InkControlCommand:
	return ControlCommand().new(CommandType.TURNS)

static func turns_since() -> InkControlCommand:
	return ControlCommand().new(CommandType.TURNS_SINCE)

static func read_count() -> InkControlCommand:
	return ControlCommand().new(CommandType.READ_COUNT)

static func random() -> InkControlCommand:
	return ControlCommand().new(CommandType.RANDOM)

static func seed_random() -> InkControlCommand:
	return ControlCommand().new(CommandType.SEED_RANDOM)

static func visit_index() -> InkControlCommand:
	return ControlCommand().new(CommandType.VISIT_INDEX)

static func sequence_shuffle_index() -> InkControlCommand:
	return ControlCommand().new(CommandType.SEQUENCE_SHUFFLE_INDEX)

static func done() -> InkControlCommand:
	return ControlCommand().new(CommandType.DONE)

static func end() -> InkControlCommand:
	return ControlCommand().new(CommandType.END)

static func list_from_int() -> InkControlCommand:
	return ControlCommand().new(CommandType.LIST_FROM_INT)

static func list_range() -> InkControlCommand:
	return ControlCommand().new(CommandType.LIST_RANGE)

static func list_random() -> InkControlCommand:
	return ControlCommand().new(CommandType.LIST_RANDOM)

# () -> String
func _to_string() -> String:
	var command_name: String = ""
	match self.command_type:
		CommandType.NOT_SET:                command_name = "NOT_SET"
		CommandType.EVAL_START:             command_name = "EVAL_START"
		CommandType.EVAL_OUTPUT:            command_name = "EVAL_OUTPUT"
		CommandType.EVAL_END:               command_name = "EVAL_END"
		CommandType.DUPLICATE:              command_name = "DUPLICATE"
		CommandType.POP_EVALUATED_VALUE:    command_name = "POP_EVALUATED_VALUE"
		CommandType.POP_FUNCTION:           command_name = "POP_FUNCTION"
		CommandType.POP_TUNNEL:             command_name = "POP_TUNNEL"
		CommandType.BEGIN_STRING:           command_name = "BEGIN_STRING"
		CommandType.END_STRING:             command_name = "END_STRING"
		CommandType.NO_OP:                  command_name = "NO_OP"
		CommandType.CHOICE_COUNT:           command_name = "CHOICE_COUNT"
		CommandType.TURNS:                  command_name = "TURNS"
		CommandType.TURNS_SINCE:            command_name = "TURNS_SINCE"
		CommandType.READ_COUNT:             command_name = "READ_COUNT"
		CommandType.RANDOM:                 command_name = "RANDOM"
		CommandType.SEED_RANDOM:            command_name = "SEED_RANDOM"
		CommandType.VISIT_INDEX:            command_name = "VISIT_INDEX"
		CommandType.SEQUENCE_SHUFFLE_INDEX: command_name = "SEQUENCE_SHUFFLE_INDEX"
		CommandType.START_THREAD:           command_name = "START_THREAD"
		CommandType.DONE:                   command_name = "DONE"
		CommandType.END:                    command_name = "END"
		CommandType.LIST_FROM_INT:          command_name = "LIST_FROM_INT"
		CommandType.LIST_RANGE:             command_name = "LIST_RANGE"
		CommandType.LIST_RANDOM:            command_name = "LIST_RANDOM"
		CommandType.TOTAL_VALUES:           command_name = "TOTAL_VALUES"

	return "Command(%s)" % command_name

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type: String) -> bool:
	return type == "ControlCommand" || .is_class(type)

func get_class() -> String:
	return "ControlCommand"
