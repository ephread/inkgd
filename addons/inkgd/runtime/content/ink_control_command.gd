# warning-ignore-all:shadowed_variable
# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2023 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends InkObject

class_name InkControlCommand

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
	BEGIN_TAG,
	END_TAG,
	#----
	TOTAL_VALUES
}


# ############################################################################ #

# CommandType
var command_type: int


# ############################################################################ #

@warning_ignore("shadowed_variable")
func _init(command_type: int = CommandType.NOT_SET):
	self.command_type = command_type


# ############################################################################ #

func copy() -> InkObject:
	return InkControlCommand.new(self.command_type)

static func eval_start() -> InkControlCommand:
	return InkControlCommand.new(CommandType.EVAL_START)


static func eval_output() -> InkControlCommand:
	return InkControlCommand.new(CommandType.EVAL_OUTPUT)


static func eval_end() -> InkControlCommand:
	return InkControlCommand.new(CommandType.EVAL_END)


static func duplicate() -> InkControlCommand:
	return InkControlCommand.new(CommandType.DUPLICATE)


static func pop_evaluated_value() -> InkControlCommand:
	return InkControlCommand.new(CommandType.POP_EVALUATED_VALUE)


static func pop_function() -> InkControlCommand:
	return InkControlCommand.new(CommandType.POP_FUNCTION)


static func pop_tunnel() -> InkControlCommand:
	return InkControlCommand.new(CommandType.POP_TUNNEL)


static func begin_string() -> InkControlCommand:
	return InkControlCommand.new(CommandType.BEGIN_STRING)


static func end_string() -> InkControlCommand:
	return InkControlCommand.new(CommandType.END_STRING)


static func no_op() -> InkControlCommand:
	return InkControlCommand.new(CommandType.NO_OP)


static func choice_count() -> InkControlCommand:
	return InkControlCommand.new(CommandType.CHOICE_COUNT)


static func turns() -> InkControlCommand:
	return InkControlCommand.new(CommandType.TURNS)


static func turns_since() -> InkControlCommand:
	return InkControlCommand.new(CommandType.TURNS_SINCE)


static func read_count() -> InkControlCommand:
	return InkControlCommand.new(CommandType.READ_COUNT)


static func random() -> InkControlCommand:
	return InkControlCommand.new(CommandType.RANDOM)


static func seed_random() -> InkControlCommand:
	return InkControlCommand.new(CommandType.SEED_RANDOM)


static func visit_index() -> InkControlCommand:
	return InkControlCommand.new(CommandType.VISIT_INDEX)


static func sequence_shuffle_index() -> InkControlCommand:
	return InkControlCommand.new(CommandType.SEQUENCE_SHUFFLE_INDEX)


static func done() -> InkControlCommand:
	return InkControlCommand.new(CommandType.DONE)


static func end() -> InkControlCommand:
	return InkControlCommand.new(CommandType.END)


static func list_from_int() -> InkControlCommand:
	return InkControlCommand.new(CommandType.LIST_FROM_INT)


static func list_range() -> InkControlCommand:
	return InkControlCommand.new(CommandType.LIST_RANGE)


static func list_random() -> InkControlCommand:
	return InkControlCommand.new(CommandType.LIST_RANDOM)


static func begin_tag() -> InkControlCommand:
	return InkControlCommand.new(CommandType.BEGIN_TAG)


static func end_tag() -> InkControlCommand:
	return InkControlCommand.new(CommandType.END_TAG)


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
		CommandType.BEGIN_TAG:              command_name = "BEGIN_TAG"
		CommandType.END_TAG:                command_name = "END_TAG"
		CommandType.TOTAL_VALUES:           command_name = "TOTAL_VALUES"

	return "Command(%s)" % command_name


# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_ink_class(type: String) -> bool:
	return type == "ControlCommand" || super.is_ink_class(type)


func get_ink_class() -> String:
	return "ControlCommand"
