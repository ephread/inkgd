# warning-ignore-all:shadowed_variable
# warning-ignore-all:unused_class_variable
# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2023 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends InkObject

class_name InkNativeFunctionCall

# ############################################################################ #

const ADD                    = "+"
const SUBTRACT               = "-"
const DIVIDE                 = "/"
const MULTIPLY               = "*"
const MOD                    = "%"
const NEGATE                 = "_"
const EQUALS                 = "=="
const GREATER                = ">"
const LESS                   = "<"
const GREATER_THAN_OR_EQUALS = ">="
const LESS_THAN_OR_EQUALS    = "<="
const NOT_EQUALS             = "!="
const NOT                    = "!"
const AND                    = "&&"
const OR                     = "||"
const MIN                    = "MIN"
const MAX                    = "MAX"
const POW                    = "POW"
const FLOOR                  = "FLOOR"
const CEILING                = "CEILING"
const INT                    = "INT"
const FLOAT                  = "FLOAT"
const HAS                    = "?"
const HASNT                  = "!?"
const INTERSECT              = "^"
const LIST_MIN               = "LIST_MIN"
const LIST_MAX               = "LIST_MAX"
const ALL                    = "LIST_ALL"
const COUNT                  = "LIST_COUNT"
const VALUE_OF_LIST          = "LIST_VALUE"
const INVERT                 = "LIST_INVERT"

# ############################################################################ #

# (String) -> NativeFunctionCall
@warning_ignore("shadowed_variable")
static func call_with_name(function_name: String) -> InkNativeFunctionCall:
	return InkNativeFunctionCall.new_with_name(function_name)


# (String) -> Bool
static func call_exists_with_name(function_name: String):
	generate_native_functions_if_necessary()
	return InkNativeFunctionCall._native_functions.has(function_name)


var name: String:
	get:
		return _name

	set(value):
		_name = value
		if !_is_prototype:
			_prototype = InkNativeFunctionCall._native_functions[_name]

var _name: String


var number_of_parameters: int:
	get:
		if _prototype:
			return _prototype.number_of_parameters
		else:
			return _number_of_parameters

	set(value):
		_number_of_parameters = value

var _number_of_parameters: int = 0


# (Array<InkObject>) -> InkObject
#
# The name is different to avoid shadowing 'Object.call'
#
# The method takes a `InkStoryErrorMetadata` object as a parameter that
# doesn't exist in upstream. The metadat are used in case an 'exception'
# is raised. For more information, see story.gd.
func call_with_parameters(parameters: Array, metadata: InkStoryErrorMetadata) -> InkObject:
	if _prototype:
		return _prototype.call_with_parameters(parameters, metadata)

	if self.number_of_parameters != parameters.size():
		InkUtils.throw_exception("Unexpected number of parameters")
		return null

	var has_list = false
	for p in parameters:
		if InkUtils.is_ink_class(p, "Void"):
			InkUtils.throw_story_exception(
					"Attempting to perform operation on a void value. Did you forget to " +
					"'return' a value from a function you called here?",
					false,
					metadata
			)
			return null
		if InkUtils.is_ink_class(p, "ListValue"):
			has_list = true

	if parameters.size() == 2 && has_list:
		return call_binary_list_operation(parameters, metadata)

	var coerced_params: Array = coerce_values_to_single_type(parameters, metadata)

	# ValueType
	var coerced_type: int = coerced_params[0].value_type

	if (
			coerced_type == Ink.ValueType.INT ||
			coerced_type == Ink.ValueType.FLOAT ||
			coerced_type == Ink.ValueType.STRING ||
			coerced_type == Ink.ValueType.DIVERT_TARGET ||
			coerced_type == Ink.ValueType.LIST
	):
		return call_coerced(coerced_params, metadata)

	return null


# (Array<Value>) -> Value # Call<T> in the original code
#
# The method takes a `InkStoryErrorMetadata` object as a parameter that
# doesn't exist in upstream. The metadata are used in case an 'exception'
# is raised. For more information, see story.gd.
func call_coerced(parameters_of_single_type: Array, metadata: InkStoryErrorMetadata) -> InkValue:
	var param1: InkValue = parameters_of_single_type[0]
	var val_type: int = param1.value_type

	var param_count: int = parameters_of_single_type.size()

	if param_count == 2 || param_count == 1:
		var op_for_type = null
		if _operation_funcs.has(val_type):
			op_for_type = _operation_funcs[val_type]
		else:
			var type_name = InkUtils.value_type_name(val_type)
			InkUtils.throw_story_exception(
					"Cannot perform operation '%s' on value of type (%d)" \
					% [self.name, type_name],
					false,
					metadata
			)
			return null

		if param_count == 2:
			var param2 = parameters_of_single_type[1]

			var result_val = op_for_type.call(param1.value, param2.value)

			return InkValue.create(result_val)
		else:
			var result_val = op_for_type.call(param1.value)

			return InkValue.create(result_val)
	else:
		InkUtils.throw_exception(
				"Unexpected number of parameters to NativeFunctionCall: %d" % \
				parameters_of_single_type.size()
		)
		return null


# (Array<InkObject>) -> Value
#
# The method takes a `InkStoryErrorMetadata` object as a parameter that
# doesn't exist in upstream. The metadat are used in case an 'exception'
# is raised. For more information, see story.gd.
func call_binary_list_operation(parameters: Array, metadata: InkStoryErrorMetadata) -> InkValue:
	if ((self.name == "+" || self.name == "-") &&
		InkUtils.is_ink_class(parameters[0], "ListValue") &&
		InkUtils.is_ink_class(parameters [1], "IntValue")
	):
		return call_list_increment_operation(parameters)

	var v1 = InkUtils.as_or_null(parameters[0], "Value")
	var v2 = InkUtils.as_or_null(parameters[1], "Value")

	if ((self.name == "&&" || self.name == "||") &&
		(v1.value_type != Ink.ValueType.LIST || v2.value_type != Ink.ValueType.LIST)
	):
		var op: Callable = _operation_funcs[Ink.ValueType.INT]
		var result = bool(op.call(
				1 if v1.is_truthy else 0,
				1 if v2.is_truthy else 0
		))

		return InkBoolValue.new_with(result)

	if v1.value_type == Ink.ValueType.LIST && v2.value_type == Ink.ValueType.LIST:
		return call_coerced([v1, v2], metadata)

	var v1_type_name = InkUtils.value_type_name(v1.value_type)
	var v2_type_name = InkUtils.value_type_name(v2.value_type)
	InkUtils.throw_story_exception(
			"Can not call use '%s' operation on %s and %s" % \
			[self.name, v1_type_name, v2_type_name],
			false,
			metadata
	)

	return null


# (Array<InkObject>) -> Value
func call_list_increment_operation(list_int_params: Array) -> InkValue:
	var list_val: InkListValue = InkUtils.cast(list_int_params[0], "ListValue")
	var int_val: InkIntValue = InkUtils.cast(list_int_params [1], "IntValue")

	var result_raw_list = InkList.new()

	for list_item in list_val.value.keys(): # TODO: Optimize?
		var list_item_value = list_val.value.get_item(list_item)

		var int_op: Callable = _operation_funcs[Ink.ValueType.INT]

		var target_int = int(int_op.call(list_item_value, int_val.value))

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
# The method takes a `InkStoryErrorMetadata` object as a parameter that
# doesn't exist in upstream. The metadata are used in case an 'exception'
# is raised. For more information, see story.gd.
func coerce_values_to_single_type(parameters_in: Array, metadata: InkStoryErrorMetadata):
	var val_type: int = Ink.ValueType.INT

	var special_case_list: InkListValue = null

	for obj in parameters_in:
		var val: InkValue = obj
		if val.value_type > val_type:
			val_type = val.value_type

		if val.value_type == Ink.ValueType.LIST:
			special_case_list = InkUtils.as_or_null(val, "ListValue")

	var parameters_out: Array = [] # Array<Value>

	if val_type == Ink.ValueType.LIST:
		for val in parameters_in:
			if val.value_type == Ink.ValueType.LIST:
				parameters_out.append(val)
			elif val.value_type == Ink.ValueType.INT:
				var int_val = int(val.value_object)
				var list = special_case_list.value.origin_of_max_item

				var item: InkTryGetResult = list.try_get_item_with_value(int_val)
				if item.exists:
					var casted_value = InkListValue.new_with_single_item(item.result, int_val)
					parameters_out.append(casted_value)
				else:
					InkUtils.throw_story_exception(
							"Could not find List item with the value %d in %s" \
							% [int_val, list.name],
							false,
							metadata
					)

					return null
			else:
				var type_name = InkUtils.value_type_name(val.value_type)
				InkUtils.throw_story_exception(
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


@warning_ignore("shadowed_variable")
func _init_with_name(name: String):
	self.name = name


@warning_ignore("shadowed_variable")
func _init_with_name_and_number_of_parameters(name: String, number_of_parameters: int):
	_is_prototype = true
	self.name = name
	self.number_of_parameters = number_of_parameters


# () -> void
static func generate_native_functions_if_necessary():
	if InkNativeFunctionCall._native_functions == null:
		InkNativeFunctionCall._native_functions = {}

		add_int_binary_op(ADD,                      func(x: int, y: int): return x + y)
		add_int_binary_op(SUBTRACT,                 func(x: int, y: int): return x - y)
		add_int_binary_op(MULTIPLY,                 func(x: int, y: int): return x * y)
		add_int_binary_op(DIVIDE,                   func(x: int, y: int): return x / y)
		add_int_binary_op(MOD,                      func(x: int, y: int): return x % y)
		add_int_unary_op (NEGATE,                   func(x: int): return -x)

		add_int_binary_op(EQUALS,                   func(x: int, y: int): return x == y)
		add_int_binary_op(GREATER,                  func(x: int, y: int): return x > y)
		add_int_binary_op(LESS,                     func(x: int, y: int): return x < y)
		add_int_binary_op(GREATER_THAN_OR_EQUALS,   func(x: int, y: int): return x >= y)
		add_int_binary_op(LESS_THAN_OR_EQUALS,      func(x: int, y: int): return x <= y)
		add_int_binary_op(NOT_EQUALS,               func(x: int, y: int): return x != y)
		add_int_unary_op (NOT,                      func(x: int): return x == 0)

		add_int_binary_op(AND,                      func(x: int, y: int): return x != 0 && y != 0)
		add_int_binary_op(OR,                       func(x: int, y: int): return x != 0 || y != 0)

		add_int_binary_op(MAX,                      func(x: int, y: int): return max(x, y))
		add_int_binary_op(MIN,                      func(x: int, y: int): return min(x, y))

		add_int_binary_op(POW,                      func(x: int, y: int): return pow(float(x), float(y)))
		add_int_unary_op (FLOOR,                    func(x: int): return x)
		add_int_unary_op (CEILING,                  func(x: int): return x)
		add_int_unary_op (INT,                      func(x: int): return x)
		add_int_unary_op (FLOAT,                    func(x: int): return float(x))

		add_float_binary_op(ADD,                    func(x: float, y: float): return x + y)
		add_float_binary_op(SUBTRACT,               func(x: float, y: float): return x - y)
		add_float_binary_op(MULTIPLY,               func(x: float, y: float): return x * y)
		add_float_binary_op(DIVIDE,                 func(x: float, y: float): return x / y)
		add_float_binary_op(MOD,                    func(x: float, y: float): return fmod(x, y))
		add_float_unary_op (NEGATE,                 func(x: float): return -x)

		add_float_binary_op(EQUALS,                 func(x: float, y: float): return x == y)
		add_float_binary_op(GREATER,                func(x: float, y: float): return x > y)
		add_float_binary_op(LESS,                   func(x: float, y: float): return x < y)
		add_float_binary_op(GREATER_THAN_OR_EQUALS, func(x: float, y: float): return x >= y)
		add_float_binary_op(LESS_THAN_OR_EQUALS,    func(x: float, y: float): return x <= y)
		add_float_binary_op(NOT_EQUALS,             func(x: float, y: float): return x != y)
		add_float_unary_op (NOT,                    func(x: float): return x == 0.0)

		add_float_binary_op(AND,                    func(x: float, y: float): return x != 0.0 && y != 0.0)
		add_float_binary_op(OR,                     func(x: float, y: float): return x != 0.0 || y != 0.0)

		add_float_binary_op(MAX,                    func(x: float, y: float): return max(x, y))
		add_float_binary_op(MIN,                    func(x: float, y: float): return min(x, y))

		add_float_binary_op(POW,                    func(x: float, y: float): return pow(x, y))
		add_float_unary_op (FLOOR,                  func(x: float): return floor(x))
		add_float_unary_op (CEILING,                func(x: float): return ceil(x))
		add_float_unary_op (INT,                    func(x: float): return int(x))
		add_float_unary_op (FLOAT,                  func(x: float): return x)

		add_string_binary_op(ADD,                   func(x: String, y: String): return str(x, y))
		add_string_binary_op(EQUALS,                func(x: String, y: String): return x == y)
		add_string_binary_op(NOT_EQUALS,            func(x: String, y: String): return x != y)

		# Note: The Content Test (in) operator does not returns true when testing
		# against the empty string, unlike the behaviour of the original C# runtime.
		add_string_binary_op(HAS,                   func(x: String, y: String): return y == "" || (y in x))
		add_string_binary_op(HASNT,                 func(x: String, y: String): return !(y in x) && y != "")

		add_list_binary_op (ADD,                    func(x: InkList, y: InkList): return x.union(y))
		add_list_binary_op (SUBTRACT,               func(x: InkList, y: InkList): return x.without(y))
		add_list_binary_op (HAS,                    func(x: InkList, y: InkList): return x.contains(y))
		add_list_binary_op (HASNT,                  func(x: InkList, y: InkList): return !x.contains(y))
		add_list_binary_op (INTERSECT,              func(x: InkList, y: InkList): return x.intersection(y))

		add_list_binary_op (EQUALS,                 func(x: InkList, y: InkList): return x.equals(y))
		add_list_binary_op (GREATER,                func(x: InkList, y: InkList): return x.greater_than(y))
		add_list_binary_op (LESS,                   func(x: InkList, y: InkList): return x.less_than(y))
		add_list_binary_op (GREATER_THAN_OR_EQUALS, func(x: InkList, y: InkList): return x.greater_than_or_equals(y))
		add_list_binary_op (LESS_THAN_OR_EQUALS,    func(x: InkList, y: InkList): return x.less_than_or_equals(y))
		add_list_binary_op (NOT_EQUALS,             func(x: InkList, y: InkList): return !x.equals(y))

		add_list_binary_op (AND,                    func(x: InkList, y: InkList): return x.size() > 0 && y.size() > 0)
		add_list_binary_op (OR,                     func(x: InkList, y: InkList): return x.size() > 0 || y.size() > 0)

		add_list_unary_op (NOT,                     func(x: InkList): return 1 if x.size() == 0 else 0)

		add_list_unary_op (INVERT,                  func(x: InkList): return x.inverse)
		add_list_unary_op (ALL,                     func(x: InkList): return x.all)
		add_list_unary_op (LIST_MIN,                func(x: InkList): return x.min_as_list())
		add_list_unary_op (LIST_MAX,                func(x: InkList): return x.max_as_list())
		add_list_unary_op (COUNT,                   func(x: InkList): return x.size())
		add_list_unary_op (VALUE_OF_LIST,           func(x: InkList): return x.max_item.value)

		add_op_to_native_func(EQUALS, 2, Ink.ValueType.DIVERT_TARGET, func(d1: InkPath, d2: InkPath): return d1.equals(d2))
		add_op_to_native_func(NOT_EQUALS, 2, Ink.ValueType.DIVERT_TARGET, func(d1: InkPath, d2: InkPath): return !d1.equals(d2))


func add_op_func_for_type(val_type: int, op: Callable) -> void:
	if _operation_funcs == null:
		_operation_funcs = {}

	_operation_funcs[val_type] = op


# (String, int, ValueType, Variant)
static func add_op_to_native_func(name: String, args: int, val_type: int, op: Callable):
	var native_func = null # NativeFunctionCall
	if InkNativeFunctionCall._native_functions.has(name):
		native_func = InkNativeFunctionCall._native_functions[name]
	else:
		native_func = InkNativeFunctionCall.new_with_name_and_number_of_parameters(name, args)
		InkNativeFunctionCall._native_functions[name] = native_func

	native_func.add_op_func_for_type(val_type, op)


static func add_int_binary_op(name: String, op: Callable):
	add_op_to_native_func(name, 2, Ink.ValueType.INT, op)


static func add_int_unary_op(name: String, op: Callable):
	add_op_to_native_func(name, 1, Ink.ValueType.INT, op)


static func add_float_binary_op(name: String, op: Callable):
	add_op_to_native_func(name, 2, Ink.ValueType.FLOAT, op)


static func add_float_unary_op(name: String, op: Callable):
	add_op_to_native_func(name, 1, Ink.ValueType.FLOAT, op)


static func add_string_binary_op(name: String, op: Callable):
	add_op_to_native_func(name, 2, Ink.ValueType.STRING, op)


static func add_list_binary_op(name: String, op: Callable):
	add_op_to_native_func(name, 2, Ink.ValueType.LIST, op)


static func add_list_unary_op(name: String, op: Callable):
	add_op_to_native_func(name, 1, Ink.ValueType.LIST, op)


func _to_string() -> String:
	return "Native '%s'" % self.name


var _prototype: InkNativeFunctionCall = null

var _is_prototype: bool = false

var _operation_funcs: Dictionary = {} # Dictionary<ValueType, Callable>

static var _native_functions = null # Dictionary<String, String>


# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_ink_class(type):
	return type == "NativeFunctionCall" || super.is_ink_class(type)


func get_ink_class():
	return "NativeFunctionCall"

# ############################################################################ #

@warning_ignore("shadowed_variable")
static func new_with_name(name: String):
	var native_function_call = InkNativeFunctionCall.new()
	native_function_call._init_with_name(name)
	return native_function_call


@warning_ignore("shadowed_variable")
static func new_with_name_and_number_of_parameters(name: String, number_of_parameters: int):
	var native_function_call = InkNativeFunctionCall.new()
	native_function_call._init_with_name_and_number_of_parameters(name, number_of_parameters)
	return native_function_call
