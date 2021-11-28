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

extends "res://addons/inkgd/runtime/ink_object.gd"

# ############################################################################ #
# Imports
# ############################################################################ #

var Ink = load("res://addons/inkgd/runtime/value.gd")
var InkList = load("res://addons/inkgd/runtime/ink_list.gd")

static func NativeFunctionCall():
	return load("res://addons/inkgd/runtime/native_function_call.gd")

# ############################################################################ #

# (String) -> NativeFunctionCall
static func call_with_name(function_name):
	return NativeFunctionCall().new_with_name(function_name)

var name setget set_name, get_name # String
func get_name():
	return _name

func set_name(value):
	_name = value
	if !_is_prototype:
		_prototype = self.StaticNativeFunctionCall.native_functions[_name]
var _name

var number_of_parameters setget set_number_of_parameters, get_number_of_parameters # int
func get_number_of_parameters():
	if _prototype:
		return _prototype.number_of_parameters
	else:
		return _number_of_parameters

func set_number_of_parameters(value):
	_number_of_parameters = value

var _number_of_parameters # int

# (Array<InkObject>) -> InkObject
func call(parameters):
	if _prototype:
		return _prototype.call(parameters)

	if self.number_of_parameters != parameters.size():
		Utils.throw_exception("Unexpected number of parameters")
		return null

	var has_list = false
	for p in parameters:
		if Utils.is_ink_class(p, "Void"):
			Utils.throw_exception(str(
				"Attempting to perform operation on a void value. Did you forget to ",
				"'return' a value from a function you called here?"
			))
			return null
		if Utils.is_ink_class(p, "ListValue"):
			has_list = true

	if parameters.size() == 2 && has_list:
		return call_binary_list_operation(parameters)

	var coerced_params = coerce_values_to_single_type(parameters)
	var coerced_type = coerced_params[0].value_type # Ink.ValueType

	if (coerced_type == Ink.ValueType.INT ||
		coerced_type == Ink.ValueType.FLOAT ||
		coerced_type == Ink.ValueType.STRING ||
		coerced_type == Ink.ValueType.DIVERT_TARGET ||
		coerced_type == Ink.ValueType.LIST):
		return call_coerced(coerced_params)

	return null

# (Array<Value>) -> Value # Call<T> in the original code
func call_coerced(parameters_of_single_type):
	var param1 = parameters_of_single_type[0]
	var val_type = param1.value_type

	var param_count = parameters_of_single_type.size()

	if param_count == 2 || param_count == 1:
		var op_for_type = null
		if _operation_funcs.has(val_type):
			op_for_type = _operation_funcs[val_type]
		else:
			Utils.throw_story_exception("Cannot perform operation '" + self.name + "' on " + val_type)
			return null

		if param_count == 2:
			var param2 = parameters_of_single_type[1]

			var result_val = self.StaticNativeFunctionCall.call(op_for_type, param1.value, param2.value)

			return Ink.Value.create(result_val)
		else:
			var result_val = self.StaticNativeFunctionCall.call(op_for_type, param1.value)

			return Ink.Value.create(result_val)
	else:
		Utils.throw_exception(str(
			"Unexpected number of parameters to NativeFunctionCall: ",
			parameters_of_single_type.size()
		))
		return null

# (Array<InkObject>) -> Value
func call_binary_list_operation(parameters):
	if ((self.name == "+" || self.name == "-") &&
		Utils.is_ink_class(parameters[0], "ListValue") &&
		Utils.is_ink_class(parameters [1], "IntValue")
	):
		return call_list_increment_operation(parameters)

	var v1 = Utils.as_or_null(parameters[0], "Value")
	var v2 = Utils.as_or_null(parameters[1], "Value")

	if ((self.name == "&&" || self.name == "||") &&
		(v1.value_type != Ink.ValueType.LIST || v2.value_type != Ink.ValueType.LIST)
	):
		var op = _operation_funcs[Ink.ValueType.INT]
		var result = bool(self.StaticNativeFunctionCall.call(
			"op_for_type",
			1 if v1.is_truthy else 0,
			1 if v2.is_truthy else 0
		))

		return Ink.BoolValue.new_with(result)

	if v1.value_type == Ink.ValueType.LIST && v2.value_type == Ink.ValueType.LIST:
		return call_coerced([v1, v2])

	Utils.throw_exception(str(
		"Can not call use '", self.name,
		"' operation on ", v1.value_type + " and " + v2.value_type
	))

	return null

# (Array<InkObject>) -> Value
func call_list_increment_operation(list_int_params):
	var list_val = Utils.cast(list_int_params[0], "ListValue")
	var int_val = Utils.cast(list_int_params [1], "IntValue")

	var result_raw_list = InkList.new()

	for list_item in list_val.value.keys(): # TODO: Optimize?
		var list_item_value = list_val.value.get(list_item)

		var int_op = _operation_funcs[Ink.ValueType.INT]

		var target_int = int(self.StaticNativeFunctionCall.call(int_op, list_item_value, int_val.value))

		var item_origin = null # ListDefinition
		for origin in list_val.value.origins:
			if origin.name == list_item.origin_name:
				item_origin = origin
				break

		if item_origin != null:
			var incremented_item = item_origin.try_get_value_for_item(target_int)
			if incremented_item.exists:
				result_raw_list.append(incremented_item.result, target_int)

	return Ink.ListValue.new_with(result_raw_list)

# (Array<InkObject>) -> Array<Value>
func coerce_values_to_single_type(parameters_in):
	var val_type = Ink.ValueType.INT

	var special_case_list = null # Ink.ListValue

	for obj in parameters_in:
		var val = obj # Value
		if val.value_type > val_type:
			val_type = val.value_type

		if val.value_type == Ink.ValueType.LIST:
			special_case_list = Utils.as_or_null(val, "ListValue")

	var parameters_out = [] # Array<Value>

	if val_type == Ink.ValueType.LIST:
		for val in parameters_in:
			if val.value_type == Ink.ValueType.LIST:
				parameters_out.append(val)
			elif val.value_type == Ink.ValueType.INT:
				var int_val = int(val.value_object)
				var list = special_case_list.value.origin_of_max_item

				var item = list.try_get_item_with_value(int_val)
				if item.exists:
					var casted_value = Ink.ListValue.new_with_single_item(item.result, int_val)
					parameters_out.append(casted_value)
				else:
					Utils.throw_exception(str(
						"Could not find List item with the value ", int_val, " in ", list.name
					))

					return null
			else:
				Utils.throw_exception(str(
					"Cannot mix Lists and ", val.value_type, " values in this operation"
				))

				return null

	else:
		for val in parameters_in:
			var casted_value = val.cast(val_type)
			parameters_out.append(casted_value)

	return parameters_out

func _init():
	generate_native_functions_if_necessary()

func _init_with_name(name):
	generate_native_functions_if_necessary()
	self.name = name

func _init_with_name_and_number_of_parameters(name, number_of_parameters):
	_is_prototype = true
	self.name = name
	self.number_of_parameters = number_of_parameters

func generate_native_functions_if_necessary():
	get_reference_to_functions_singleton_if_necessary()
	self.StaticNativeFunctionCall.generate_native_functions_if_necessary()

# (ValueType, String) -> void
func add_op_func_for_type(val_type, op):
	if _operation_funcs == null:
		_operation_funcs = {}

	_operation_funcs[val_type] = op

func to_string():
	return str("Native '", self.name, "'")

var _prototype = null # NativeFunctionCall
var _is_prototype = false # bool

var _operation_funcs = null # Dictionary<ValueType, InkObject>

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type):
	return type == "NativeFunctionCall" || .is_class(type)

func get_class():
	return "NativeFunctionCall"

var StaticNativeFunctionCall setget, get_StaticNativeFunctionCall
func get_StaticNativeFunctionCall():
	return _StaticNativeFunctionCall.get_ref()
var _StaticNativeFunctionCall = WeakRef.new()

func get_reference_to_functions_singleton_if_necessary():
	# TODO: refactor
	if _StaticNativeFunctionCall.get_ref() == null:
		var scene_tree = Engine.get_main_loop()
		_StaticNativeFunctionCall = weakref(scene_tree.root.get_node("__InkRuntime").native_function_call)

static func new_with_name(name):
	var native_function_call = NativeFunctionCall().new()
	native_function_call._init_with_name(name)
	return native_function_call

static func new_with_name_and_number_of_parameters(name, number_of_parameters):
	var native_function_call = NativeFunctionCall().new()
	native_function_call._init_with_name_and_number_of_parameters(name, number_of_parameters)
	return native_function_call
