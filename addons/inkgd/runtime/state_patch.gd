# warning-ignore-all:shadowed_variable
# warning-ignore-all:unused_class_variable
# ############################################################################ #
# Copyright © 2015-present inkle Ltd.
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

# ############################################################################ #
# Imports
# ############################################################################ #

var StringSet = load("res://addons/inkgd/runtime/extra/string_set.gd")
var TryGetResult = preload("res://addons/inkgd/runtime/extra/try_get_result.gd")

# ############################################################################ #

var globals setget , get_globals # Dictionary<String, InkObject>
func get_globals():
	return _globals

var changed_variables setget , get_changed_variables # StringSet
func get_changed_variables():
	return _changed_variables

var visit_counts setget , get_visit_counts # Dictionary<InkContainer, int>
func get_visit_counts():
	return _visit_counts

var turn_indices setget , get_turn_indices # Dictionary<InkContainer, int>
func get_turn_indices():
	return _turn_indices

func _init(to_copy):
	if to_copy != null:
		_globals = to_copy._globals.duplicate()
		_changed_variables = to_copy._changed_variables.duplicate()
		_visit_counts = to_copy._visit_counts.duplicate()
		_turn_indices = to_copy._turn_indices.duplicate()
	else:
		_globals = {}
		_changed_variables = StringSet.new()
		_visit_counts = {}
		_turn_indices = {}

# (String) -> { exists: bool, result: InkObject }
func try_get_global(name):
	if _globals.has(name):
		return TryGetResult.new(true, _globals[name])

	return TryGetResult.new(false, null)

# (String, InkObject) -> void
func set_global(name, value):
	_globals[name] = value

# (String) -> void
func add_changed_variable(name):
	_changed_variables.append(name)

# (InkContainer) -> { exists: bool, result: int }
func try_get_visit_count(container):
	if _visit_counts.has(container):
		return TryGetResult.new(true, _visit_counts[container])

	return TryGetResult.new(false, 0)

# (InkContainer, int) -> void
func set_visit_count(container, index):
	_visit_counts[container] = index

# (InkContainer, int) -> void
func set_turn_index(container, index):
	_turn_indices[container] = index

# (InkContainer) -> { exists: bool, result: int }
func try_get_turn_index(container):
	if _turn_indices.has(container):
		return TryGetResult.new(true, _turn_indices[container])

	return TryGetResult.new(false, 0)

var _globals = null
var _changed_variables = StringSet.new()
var _visit_counts = {}
var _turn_indices = {}

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type):
	return type == "StatePatch" || .is_class(type)

func get_class():
	return "StatePatch"
