# warning-ignore-all:shadowed_variable
# warning-ignore-all:unused_class_variable
# warning-ignore-all:return_value_discarded
# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends InkBase

class_name InkVariablesState

# ############################################################################ #
# Imports
# ############################################################################ #

var InkTryGetResult := preload("res://addons/inkgd/runtime/extra/try_get_result.gd") as GDScript
var InkStringSet := preload("res://addons/inkgd/runtime/extra/string_set.gd") as GDScript

var InkValue := load("res://addons/inkgd/runtime/values/value.gd") as GDScript
var InkListValue := load("res://addons/inkgd/runtime/values/list_value.gd") as GDScript
var InkVariablePointerValue := load("res://addons/inkgd/runtime/values/variable_pointer_value.gd") as GDScript

# ############################################################################ #

# (String, InkObject)
signal variable_changed(variable_name, new_value)

# ############################################################################ #

var patch: InkStatePatch # StatePatch

var batch_observing_variable_changes: bool setget \
		set_batch_observing_variable_changes, \
		get_batch_observing_variable_changes
func get_batch_observing_variable_changes() -> bool:
	return _batch_observing_variable_changes

func set_batch_observing_variable_changes(value: bool) -> void:
	_batch_observing_variable_changes = value
	if value:
		_changed_variables_for_batch_obs = InkStringSet.new()
	else:
		if _changed_variables_for_batch_obs != null:
			for variable_name in _changed_variables_for_batch_obs.enumerate():
				var current_value = _global_variables[variable_name]
				emit_signal("variable_changed", variable_name, current_value)

		_changed_variables_for_batch_obs = null

var _batch_observing_variable_changes: bool = false

var callstack: InkCallStack setget set_callstack, get_callstack
func get_callstack() -> InkCallStack:
		return _callstack

func set_callstack(value: InkCallStack):
		_callstack = value

# (String) -> Variant
func get(variable_name: String):
	if self.patch != null:
		var global: InkTryGetResult = patch.try_get_global(variable_name)
		if global.exists:
			return global.result.value_object

	if _global_variables.has(variable_name):
		return _global_variables[variable_name].value_object
	elif _default_global_variables.has(variable_name):
		return _default_global_variables[variable_name].value_object
	else:
		return null

# (String, Variant) -> void
func set(variable_name: String, value) -> void:
	if !_default_global_variables.has(variable_name):
		Utils.throw_story_exception(
				"Cannot assign to a variable (%s) that hasn't been declared in the story" \
				% variable_name
		)
		return

	var val: InkValue = InkValue.create(value)
	if val == null:
		if value == null:
			Utils.throw_exception("Cannot pass null to VariableState")
		else:
			Utils.throw_exception("Invalid value passed to VariableState: %s" % str(value))
		return

	set_global(variable_name, val)

func enumerate() -> Array:
	return _global_variables.keys()

func _init(callstack: InkCallStack, list_defs_origin: InkListDefinitionsOrigin):
	find_static_objects()

	_global_variables = {}
	_callstack = callstack
	_list_defs_origin = list_defs_origin

# () -> void
func apply_patch() -> void:
	for named_var_key in self.patch.globals:
		_global_variables[named_var_key] = self.patch.globals[named_var_key]

	if _changed_variables_for_batch_obs != null:
		for name in self.patch.changed_variables.enumerate():
			_changed_variables_for_batch_obs.append(name)

	patch = null

# (Dictionary<string, Variant>) -> void
func set_json_token(jtoken: Dictionary) -> void:
	_global_variables.clear()

	for var_val_key in _default_global_variables:
		if jtoken.has(var_val_key):
			var loaded_token = jtoken[var_val_key]
			_global_variables[var_val_key] = self._json.jtoken_to_runtime_object(loaded_token)
		else:
			_global_variables[var_val_key] = _default_global_variables[var_val_key]

func write_json(writer: InkSimpleJSON.Writer) -> void:
	writer.write_object_start()
	for key in _global_variables:
		var name: String = key
		var val: InkObject = _global_variables[key]

		if self._ink_runtime.dont_save_default_values:
			if self._default_global_variables.has(name):
				if runtime_objects_equal(val, self._default_global_variables[name]):
					continue

		writer.write_property_start(name)
		self._json.write_runtime_object(writer, val)
		writer.write_property_end()
	writer.write_object_end()

func runtime_objects_equal(obj1: InkObject, obj2: InkObject) -> bool:
	if !Utils.are_of_same_type(obj1, obj2):
		return false

	var bool_val: InkBoolValue = Utils.as_or_null(obj1, "BoolValue")
	if bool_val != null:
		return bool_val.value == Utils.cast(obj2, "BoolValue").value

	var int_val: InkIntValue = Utils.as_or_null(obj1, "IntValue")
	if int_val != null:
		return int_val.value == Utils.cast(obj2, "IntValue").value

	var float_val: InkFloatValue = Utils.as_or_null(obj1, "FloatValue")
	if float_val != null:
		return float_val.value == Utils.cast(obj2, "FloatValue").value

	var val1: InkValue = Utils.as_or_null(obj1, "Value")
	var val2: InkValue = Utils.as_or_null(obj2, "Value")

	if val1 != null:
		if val1.value_object is Object && val2.value_object is Object:
			return val1.value_object.equals(val2.value_object)
		else:
			return val1.value_object == val2.value_object

	Utils.throw_exception(
			"FastRoughDefinitelyEquals: Unsupported runtime object type: %s" \
			% obj1.get_class()
	)

	return false

func get_variable_with_name(name: String, context_index = -1) -> InkObject:
	var var_value: InkObject = get_raw_variable_with_name(name, context_index)

	var var_pointer: InkVariablePointerValue = Utils.as_or_null(var_value, "VariablePointerValue")
	if var_pointer:
		var_value = value_at_variable_pointer(var_pointer)

	return var_value

# (String) -> { exists: bool, result: InkObject }
func try_get_default_variable_value(name: String) -> InkTryGetResult:
	if _default_global_variables.has(name):
		return InkTryGetResult.new(true, _default_global_variables[name])
	else:
		return InkTryGetResult.new(false, null)

func global_variable_exists_with_name(name: String) -> bool:
	return (
			_global_variables.has(name) ||
			_default_global_variables != null && _default_global_variables.has(name)
	)

func get_raw_variable_with_name(name: String, context_index: int) -> InkObject:
	var var_value: InkObject = null

	if context_index == 0 || context_index == -1:
		if self.patch != null:
			var try_result: InkTryGetResult = self.patch.try_get_global(name)
			if try_result.exists: return try_result.result

		if _global_variables.has(name):
			return _global_variables[name]

		if self._default_global_variables != null:
			if self._default_global_variables.has(name):
				return self._default_global_variables[name]

		var list_item_value: InkListValue = _list_defs_origin.find_single_item_list_with_name(name)

		if list_item_value:
			return list_item_value

	var_value = _callstack.get_temporary_variable_with_name(name, context_index)

	return var_value

# (InkVariablePointerValue) -> InkObject
func value_at_variable_pointer(pointer: InkVariablePointerValue) -> InkObject:
	return get_variable_with_name(pointer.variable_name, pointer.context_index)

# (InkVariableAssignment, InkObject) -> void
func assign(var_ass: InkVariableAssignment, value: InkObject) -> void:
	var name: String = var_ass.variable_name
	var context_index: int = -1

	var set_global: bool = false
	if var_ass.is_new_declaration:
		set_global = var_ass.is_global
	else:
		set_global = global_variable_exists_with_name(name)

	if var_ass.is_new_declaration:
		var var_pointer: InkVariablePointerValue = Utils.as_or_null(value, "VariablePointerValue")
		if var_pointer:
			var fully_resolved_variable_pointer: InkObject = resolve_variable_pointer(var_pointer)
			value = fully_resolved_variable_pointer
	else:
		var existing_pointer: InkVariablePointerValue = null # VariablePointerValue
		var first_time: bool = true
		while existing_pointer || first_time:
			first_time = false
			existing_pointer = Utils.as_or_null(
				get_raw_variable_with_name(name, context_index),
				"VariablePointerValue"
			)
			if existing_pointer:
				name = existing_pointer.variable_name
				context_index = existing_pointer.context_index
				set_global = (context_index == 0)

	if set_global:
		set_global(name, value)
	else:
		_callstack.set_temporary_variable(name, value, var_ass.is_new_declaration, context_index)

# () -> void
func snapshot_default_globals():
	_default_global_variables = _global_variables.duplicate()

# (InkObject, InkObject) -> void
func retain_list_origins_for_assignment(old_value, new_value) -> void:
	var old_list: InkListValue = Utils.as_or_null(old_value, "ListValue")
	var new_list: InkListValue = Utils.as_or_null(new_value, "ListValue")

	if old_list && new_list && new_list.value.size() == 0:
		new_list.value.set_initial_origin_names(old_list.value.origin_names)

# (String, InkObject) -> void
func set_global(variable_name: String, value: InkObject) -> void:
	var old_value = null # InkObject

	# Slightly different structure from upstream, since we can't use
	# try_get_global in the conditional.
	if patch != null:
		var patch_value: InkTryGetResult = patch.try_get_global(variable_name)
		if patch_value.exists:
			old_value = patch_value.result

	if old_value == null:
		if self._global_variables.has(variable_name):
			old_value = self._global_variables[variable_name]

	InkListValue.retain_list_origins_for_assignment(old_value, value)

	if patch != null:
		self.patch.set_global(variable_name, value)
	else:
		self._global_variables[variable_name] = value

	if !value.equals(old_value):
		if _batch_observing_variable_changes:
			if patch != null:
				patch.add_changed_variable(variable_name)
			elif self._changed_variables_for_batch_obs != null:
				_changed_variables_for_batch_obs.append(variable_name)
		else:
			emit_signal("variable_changed", variable_name, value)

# (VariablePointerValue) -> VariablePointerValue
func resolve_variable_pointer(var_pointer: InkVariablePointerValue) -> InkVariablePointerValue:
	var context_index: int = var_pointer.context_index

	if context_index == -1:
		context_index = get_context_index_of_variable_named(var_pointer.variable_name)

	var value_of_variable_pointed_to = get_raw_variable_with_name(
		var_pointer.variable_name, context_index
	)

	var double_redirection_pointer: InkVariablePointerValue = Utils.as_or_null(
			value_of_variable_pointed_to, "VariablePointerValue"
	)

	if double_redirection_pointer:
		return double_redirection_pointer
	else:
		return InkVariablePointerValue.new_with_context(var_pointer.variable_name, context_index)

# ############################################################################ #

# (String) -> int
func get_context_index_of_variable_named(var_name):
	if global_variable_exists_with_name(var_name):
		return 0

	return _callstack.current_element_index

# Dictionary<String, InkObject>
var _global_variables: Dictionary
var _default_global_variables = null # Dictionary<String, InkObject>

var _callstack: InkCallStack
var _changed_variables_for_batch_obs: InkStringSet = null
var _list_defs_origin: InkListDefinitionsOrigin

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type: String) -> bool:
	return type == "VariableState" || .is_class(type)

func get_class() -> String:
	return "VariableState"

# ############################################################################ #
# Static Properties
# ############################################################################ #

var _json: InkStaticJSON setget , get_json
func get_json():
	return self._ink_runtime.json

var _ink_runtime setget , get_ink_runtime
func get_ink_runtime():
	return _weak_ink_runtime.get_ref()
var _weak_ink_runtime: WeakRef

func find_static_objects():
	var ink_runtime = Engine.get_main_loop().root.get_node("__InkRuntime")

	Utils.__assert__(
			ink_runtime != null,
			"Could not retrieve 'InkRuntime' singleton from the scene tree."
	)

	_weak_ink_runtime = weakref(ink_runtime)
