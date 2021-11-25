# warning-ignore-all:shadowed_variable
# ############################################################################ #
# Copyright © 2015-present inkle Ltd.
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://addons/inkgd/runtime/ink_object.gd"

# ############################################################################ #
# Imports
# ############################################################################ #

static func ControlCommand():
	return load("res://addons/inkgd/runtime/control_command.gd")

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

var command_type # CommandType

# ############################################################################ #

# (CommandType) -> InkControlCommand
func _init(command_type = CommandType.NOT_SET):
	self.command_type = command_type

# ############################################################################ #

# () -> ControlCommand
func copy():
	return ControlCommand().new(self.command_type)

# () -> ControlCommand
static func eval_start():
	return ControlCommand().new(CommandType.EVAL_START)

# () -> ControlCommand
static func eval_output():
	return ControlCommand().new(CommandType.EVAL_OUTPUT)

# () -> ControlCommand
static func eval_end():
	return ControlCommand().new(CommandType.EVAL_END)

# () -> ControlCommand
static func duplicate():
	return ControlCommand().new(CommandType.DUPLICATE)

# () -> ControlCommand
static func pop_evaluated_value():
	return ControlCommand().new(CommandType.POP_EVALUATED_VALUE)

# () -> ControlCommand
static func pop_function():
	return ControlCommand().new(CommandType.POP_FUNCTION)

# () -> ControlCommand
static func pop_tunnel():
	return ControlCommand().new(CommandType.POP_TUNNEL)

# () -> ControlCommand
static func begin_string():
	return ControlCommand().new(CommandType.BEGIN_STRING)

# () -> ControlCommand
static func end_string():
	return ControlCommand().new(CommandType.END_STRING)

# () -> ControlCommand
static func no_op():
	return ControlCommand().new(CommandType.NO_OP)

# () -> ControlCommand
static func choice_count():
	return ControlCommand().new(CommandType.CHOICE_COUNT)

# () -> ControlCommand
static func turns():
	return ControlCommand().new(CommandType.TURNS)

# () -> ControlCommand
static func turns_since():
	return ControlCommand().new(CommandType.TURNS_SINCE)

# () -> ControlCommand
static func read_count():
	return ControlCommand().new(CommandType.READ_COUNT)

# () -> ControlCommand
static func random():
	return ControlCommand().new(CommandType.RANDOM)

# () -> ControlCommand
static func seed_random():
	return ControlCommand().new(CommandType.SEED_RANDOM)

# () -> ControlCommand
static func visit_index():
	return ControlCommand().new(CommandType.VISIT_INDEX)

# () -> ControlCommand
static func sequence_shuffle_index():
	return ControlCommand().new(CommandType.SEQUENCE_SHUFFLE_INDEX)

# () -> ControlCommand
static func done():
	return ControlCommand().new(CommandType.DONE)

# () -> ControlCommand
static func end():
	return ControlCommand().new(CommandType.END)

# () -> ControlCommand
static func list_from_int():
	return ControlCommand().new(CommandType.LIST_FROM_INT)

# () -> ControlCommand
static func list_range():
	return ControlCommand().new(CommandType.LIST_RANGE)

# () -> ControlCommand
static func list_random():
	return ControlCommand().new(CommandType.LIST_RANDOM)

# () -> String
func to_string():
	var command_name = ""
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

	return str("Command(", command_name, ")")

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type):
	return type == "ControlCommand" || .is_class(type)

func get_class():
	return "ControlCommand"
