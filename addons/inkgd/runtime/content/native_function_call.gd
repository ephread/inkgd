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

extends InkObject

class_name InkNativeFunctionCall

# ############################################################################ #
# Imports
# ############################################################################ #

const ValueType = preload("res://addons/inkgd/runtime/values/value_type.gd").ValueType
var InkList := load("res://addons/inkgd/runtime/lists/ink_list.gd") as GDScript

var InkValue := load("res://addons/inkgd/runtime/values/value.gd") as GDScript
var InkBoolValue := load("res://addons/inkgd/runtime/values/bool_value.gd") as GDScript
var InkListValue := load("res://addons/inkgd/runtime/values/list_value.gd") as GDScript

static func InkNativeFunctionCall() -> GDScript:
	return load("res://addons/inkgd/runtime/content/native_function_call.gd") as GDScript

# ############################################################################ #

# (String) -> NativeFunctionCall
static func call_with_name(function_name) -> InkNativeFunctionCall:
	return InkNativeFunctionCall().new_with_name(function_name)

var name: String setget set_name, get_name
func get_name() -> String:
	return _name

func set_name(value: String):
	_name = value
	if !_is_prototype:
		_prototype = self._static_native_function_call.native_functions[_name]
var _name

var number_of_parameters: int setget set_number_of_parameters, get_number_of_parameters
func get_number_of_parameters() -> int:
	if _prototype:
		return _prototype.number_of_parameters
	else:
		return _number_of_parameters

func set_number_of_parameters(value: int):
	_number_of_parameters = value

var _number_of_parameters = 0

# (Array<InkObject>) -> InkObject
#
# The name is different to avoid shadowing 'Object.call'
#
# The method takes a `StoryErrorMetadata` object as a parameter that
# doesn't exist in upstream. The metadat are used in case an 'exception'
# is raised. For more information, see story.gd.
func call_with_parameters(parameters: Array, metadata: StoryErrorMetadata) -> InkObject:
	if _prototype:
		return _prototype.call_with_parameters(parameters, metadata)

	if self.number_of_parameters != parameters.size():
		Utils.throw_exception("Unexpected number of parameters")
		return null

	var has_list = false
	for p in parameters:
		if Utils.is_ink_class(p, "Void"):
			Utils.throw_story_exception(
					"Attempting to perform operation on a void value. Did you forget to " +
					"'return' a value from a function you called here?",
					false,
					metadata
			)
			return null
		if Utils.is_ink_class(p, "ListValue"):
			has_list = true

	if parameters.size() == 2 && has_list:
		return call_binary_list_operation(parameters, metadata)

	var coerced_params: Array = coerce_values_to_single_type(parameters, metadata)

	# ValueType
	var coerced_type: int = coerced_params[0].value_type

	if (
			coerced_type == ValueType.INT ||
			coerced_type == ValueType.FLOAT ||
			coerced_type == ValueType.STRING ||
			coerced_type == ValueType.DIVERT_TARGET ||
			coerced_type == ValueType.LIST
	):
		return call_coerced(coerced_params, metadata)

	return null

# (Array<Value>) -> Value # Call<T> in the original code
#
# The method takes a `StoryErrorMetadata` object as a parameter that
# doesn't exist in upstream. The metadat are used in case an 'exception'
# is raised. For more information, see story.gd.
func call_coerced(parameters_of_single_type: Array, metadata: StoryErrorMetadata) -> InkValue:
	var param1: InkValue = parameters_of_single_type[0]
	var val_type: int = param1.value_type

	var param_count: int = parameters_of_single_type.size()

	if param_count == 2 || param_count == 1:
		var op_for_type = null
		if _operation_funcs.has(val_type):
			op_for_type = _operation_funcs[val_type]
		else:
			var type_name = Utils.value_type_name(val_type)
			Utils.throw_story_exception(
					"Cannot perform operation '%s' on value of type (%d)" \
					% [self.name, type_name],
					false,
					metadata
			)
			return null

		if param_count == 2:
			var param2 = parameters_of_single_type[1]

			var result_val = self._static_native_function_call.call(op_for_type, param1.value, param2.value)

			return InkValue.create(result_val)
		else:
			var result_val = self._static_native_function_call.call(op_for_type, param1.value)

			return InkValue.create(result_val)
	else:
		Utils.throw_exception(
				"Unexpected number of parameters to NativeFunctionCall: %d" % \
				parameters_of_single_type.size()
		)
		return null

# (Array<InkObject>) -> Value
#
# The method takes a `StoryErrorMetadata` object as a parameter that
# doesn't exist in upstream. The metadat are used in case an 'exception'
# is raised. For more information, see story.gd.
func call_binary_list_operation(parameters: Array, metadata) -> InkValue:
	if ((self.name == "+" || self.name == "-") &&
		Utils.is_ink_class(parameters[0], "ListValue") &&
		Utils.is_ink_class(parameters [1], "IntValue")
	):
		return call_list_increment_operation(parameters)

	var v1 = Utils.as_or_null(parameters[0], "Value")
	var v2 = Utils.as_or_null(parameters[1], "Value")

	if ((self.name == "&&" || self.name == "||") &&
		(v1.value_type != ValueType.LIST || v2.value_type != ValueType.LIST)
	):
		var op: String = _operation_funcs[ValueType.INT]
		var result = bool(self._static_native_function_call.call(
			"op_for_type",
			1 if v1.is_truthy else 0,
			1 if v2.is_truthy else 0
		))

		return InkBoolValue.new_with(result)

	if v1.value_type == ValueType.LIST && v2.value_type == ValueType.LIST:
		return call_coerced([v1, v2], metadata)

	var v1_type_name = Utils.value_type_name(v1.value_type)
	var v2_type_name = Utils.value_type_name(v2.value_type)
	Utils.throw_story_exception(
			"Can not call use '%s' operation on %s and %s" % \
			[self.name, v1_type_name, v2_type_name],
			false,
			metadata
	)

	return null

# (Array<InkObject>) -> Value
func call_list_increment_operation(list_int_params: Array) -> InkValue:
	var list_val: InkListValue = Utils.cast(list_int_params[0], "ListValue")
	var int_val: InkIntValue = Utils.cast(list_int_params [1], "IntValue")

	var result_raw_list = InkList.new()

	for list_item in list_val.value.keys(): # TODO: Optimize?
		var list_item_value = list_val.value.get_item(list_item)

		var int_op: String = _operation_funcs[ValueType.INT]

		var target_int = int(
				self._static_native_function_call.call(
						int_op,
						list_item_value,
						int_val.value
				)
		)

		var item_origin: InkListDefinition = null
		for origin in list_val.value.origins:
			if origin.name == list_item.origin_name:
				item_origin = origin
				break

		if item_origin != null:
			var incremented_item: InkTryGetResult = item_origin.try_get_item_with_value(target_int)
			if incremented_item.exists:
				result_raw_list.set_item(incremented_item.result, target_int)

	return InkListValue.new_with(result_raw_list)

# (Array<InkObject>) -> Array<Value>?
#
# The method takes a `StoryErrorMetadata` object as a parameter that
# doesn't exist in upstream. The metadat are used in case an 'exception'
# is raised. For more information, see story.gd.
func coerce_values_to_single_type(parameters_in: Array, metadata):
	var val_type = ValueType.INT

	var special_case_list: InkListValue = null # ListValue

	for obj in parameters_in:
		var val: InkValue = obj
		if val.value_type > val_type:
			val_type = val.value_type

		if val.value_type == ValueType.LIST:
			special_case_list = Utils.as_or_null(val, "ListValue")

	var parameters_out: Array = [] # Array<Value>

	if val_type == ValueType.LIST:
		for val in parameters_in:
			if val.value_type == ValueType.LIST:
				parameters_out.append(val)
			elif val.value_type == ValueType.INT:
				var int_val = int(val.value_object)
				var list = special_case_list.value.origin_of_max_item

				var item: InkTryGetResult = list.try_get_item_with_value(int_val)
				if item.exists:
					var casted_value = InkListValue.new_with_single_item(item.result, int_val)
					parameters_out.append(casted_value)
				else:
					Utils.throw_story_exception(
							"Could not find List item with the value %d in %s" \
							% [int_val, list.name],
							false,
							metadata
					)

					return null
			else:
				var type_name = Utils.value_type_name(val.value_type)
				Utils.throw_story_exception(
						"Cannot mix Lists and %s values in this operation" % type_name,
						false,
						metadata
				)

				return null

	else:
		for val in parameters_in:
			var casted_value = val.cast(val_type)
			parameters_out.append(casted_value)

	return parameters_out

func _init():
	generate_native_functions_if_necessary()

func _init_with_name(name: String):
	generate_native_functions_if_necessary()
	self.name = name

func _init_with_name_and_number_of_parameters(name: String, number_of_parameters: int):
	_is_prototype = true
	self.name = name
	self.number_of_parameters = number_of_parameters

func generate_native_functions_if_necessary() -> void:
	find_static_objects()
	self._static_native_function_call.generate_native_functions_if_necessary()

# (ValueType, String) -> void
func add_op_func_for_type(val_type: int, op: String) -> void:
	if _operation_funcs == null:
		_operation_funcs = {}

	_operation_funcs[val_type] = op

func _to_string() -> String:
	return "Native '%s'" % self.name

# NativeFunctionCall
var _prototype = null

var _is_prototype: bool = false

# Dictionary<ValueType, String>
var _operation_funcs: Dictionary = {}

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type):
	return type == "NativeFunctionCall" || .is_class(type)

func get_class():
	return "NativeFunctionCall"

var _static_native_function_call: InkStaticNativeFunctionCall setget \
		 , get_static_native_function_call
func get_static_native_function_call():
	return _weak_static_native_function_call.get_ref()
var _weak_static_native_function_call = WeakRef.new()

func find_static_objects():
	if _static_native_function_call == null:
		var ink_runtime = Engine.get_main_loop().root.get_node("__InkRuntime")
		_weak_static_native_function_call = weakref(ink_runtime.native_function_call)

# ############################################################################ #

static func new_with_name(name: String):
	var native_function_call = InkNativeFunctionCall().new()
	native_function_call._init_with_name(name)
	return native_function_call

static func new_with_name_and_number_of_parameters(name: String, number_of_parameters: int):
	var native_function_call = InkNativeFunctionCall().new()
	native_function_call._init_with_name_and_number_of_parameters(name, number_of_parameters)
	return native_function_call
