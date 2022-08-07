# warning-ignore-all:shadowed_variable
# warning-ignore-all:unused_class_variable
# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends InkBase

class_name InkStatePatch

# ############################################################################ #
# Imports
# ############################################################################ #

var InkTryGetResult := preload("res://addons/inkgd/runtime/extra/try_get_result.gd") as GDScript
var InkStringSet := preload("res://addons/inkgd/runtime/extra/string_set.gd") as GDScript

# ############################################################################ #

# Dictionary<String, InkObject>
var globals: Dictionary setget , get_globals
func get_globals() -> Dictionary:
	return _globals

# StringSet
var changed_variables: InkStringSet setget , get_changed_variables
func get_changed_variables() -> InkStringSet:
	return _changed_variables

# Dictionary<InkContainer, int>
var visit_counts: Dictionary setget , get_visit_counts
func get_visit_counts() -> Dictionary:
	return _visit_counts

# Dictionary<InkContainer, int>
var turn_indices setget , get_turn_indices
func get_turn_indices() -> Dictionary:
	return _turn_indices

# ############################################################################ #

func _init(to_copy: InkStatePatch):
	if to_copy != null:
		_globals = to_copy._globals.duplicate()
		_changed_variables = to_copy._changed_variables.duplicate()
		_visit_counts = to_copy._visit_counts.duplicate()
		_turn_indices = to_copy._turn_indices.duplicate()
	else:
		_globals = {}
		_changed_variables = InkStringSet.new()
		_visit_counts = {}
		_turn_indices = {}

# (String) -> { exists: bool, result: InkObject }
func try_get_global(name) -> InkTryGetResult:
	if _globals.has(name):
		return InkTryGetResult.new(true, _globals[name])

	return InkTryGetResult.new(false, null)

func set_global(name: String, value: InkObject) -> void:
	_globals[name] = value

func add_changed_variable(name: String) -> void:
	_changed_variables.append(name)

# (InkContainer) -> { exists: bool, result: int }
func try_get_visit_count(container) -> InkTryGetResult:
	if _visit_counts.has(container):
		return InkTryGetResult.new(true, _visit_counts[container])

	return InkTryGetResult.new(false, 0)

func set_visit_count(container: InkContainer, index: int) -> void:
	_visit_counts[container] = index

func set_turn_index(container: InkContainer, index: int) -> void:
	_turn_indices[container] = index

# (InkContainer) -> { exists: bool, result: int }
func try_get_turn_index(container) -> InkTryGetResult:
	if _turn_indices.has(container):
		return InkTryGetResult.new(true, _turn_indices[container])

	return InkTryGetResult.new(false, 0)

var _globals: Dictionary
var _changed_variables: InkStringSet
var _visit_counts: Dictionary
var _turn_indices: Dictionary

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type: String) -> bool:
	return type == "StatePatch" || .is_class(type)

func get_class() -> String:
	return "StatePatch"
