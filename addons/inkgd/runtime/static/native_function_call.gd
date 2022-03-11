# warning-ignore-all:unused_class_variable
# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends Reference

class_name InkStaticNativeFunctionCall

# ############################################################################ #
# Imports
# ############################################################################ #

const ValueType = preload("res://addons/inkgd/runtime/values/value_type.gd").ValueType

static func InkNativeFunctionCall():
	return load("res://addons/inkgd/runtime/content/native_function_call.gd")

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

var native_functions = null # Dictionary<String, String>

# ############################################################################ #

# (String) -> Bool
func call_exists_with_name(function_name):
	generate_native_functions_if_necessary()
	return native_functions.has(function_name)

# () -> void
func generate_native_functions_if_necessary():
	if native_functions == null:
		native_functions = {}

		add_int_binary_op(ADD,                      "int_binary_op_add")
		add_int_binary_op(SUBTRACT,                 "int_binary_op_substract")
		add_int_binary_op(MULTIPLY,                 "int_binary_op_multiply")
		add_int_binary_op(DIVIDE,                   "int_binary_op_divide")
		add_int_binary_op(MOD,                      "int_binary_op_mod")
		add_int_unary_op (NEGATE,                   "int_unary_op_negate")

		add_int_binary_op(EQUALS,                   "int_binary_op_equals")
		add_int_binary_op(GREATER,                  "int_binary_op_greater")
		add_int_binary_op(LESS,                     "int_binary_op_less")
		add_int_binary_op(GREATER_THAN_OR_EQUALS,   "int_binary_op_greater_than_or_equals")
		add_int_binary_op(LESS_THAN_OR_EQUALS,      "int_binary_op_less_than_or_equals")
		add_int_binary_op(NOT_EQUALS,               "int_binary_op_not_equals")
		add_int_unary_op (NOT,                      "int_unary_op_not")

		add_int_binary_op(AND,                      "int_binary_op_and")
		add_int_binary_op(OR,                       "int_binary_op_or")

		add_int_binary_op(MAX,                      "int_binary_op_max")
		add_int_binary_op(MIN,                      "int_binary_op_min")

		add_int_binary_op(POW,                      "int_binary_op_pow")
		add_int_unary_op (FLOOR,                    "int_unary_op_floor")
		add_int_unary_op (CEILING,                  "int_unary_op_ceiling")
		add_int_unary_op (INT,                      "int_unary_op_int")
		add_int_unary_op (FLOAT,                    "int_unary_op_float")

		add_float_binary_op(ADD,                    "float_binary_op_add")
		add_float_binary_op(SUBTRACT,               "float_binary_op_substract")
		add_float_binary_op(MULTIPLY,               "float_binary_op_multiply")
		add_float_binary_op(DIVIDE,                 "float_binary_op_divide")
		add_float_binary_op(MOD,                    "float_binary_op_mod")
		add_float_unary_op (NEGATE,                 "float_unary_op_negate")

		add_float_binary_op(EQUALS,                 "float_binary_op_equals")
		add_float_binary_op(GREATER,                "float_binary_op_greater")
		add_float_binary_op(LESS,                   "float_binary_op_less")
		add_float_binary_op(GREATER_THAN_OR_EQUALS, "float_binary_op_greater_than_or_equals")
		add_float_binary_op(LESS_THAN_OR_EQUALS,    "float_binary_op_less_than_or_equals")
		add_float_binary_op(NOT_EQUALS,             "float_binary_op_not_equals")
		add_float_unary_op (NOT,                    "float_unary_op_not")

		add_float_binary_op(AND,                    "float_binary_op_and")
		add_float_binary_op(OR,                     "float_binary_op_or")

		add_float_binary_op(MAX,                    "float_binary_op_max")
		add_float_binary_op(MIN,                    "float_binary_op_min")

		add_float_binary_op(POW,                    "float_binary_op_pow")
		add_float_unary_op (FLOOR,                  "float_unary_op_floor")
		add_float_unary_op (CEILING,                "float_unary_op_ceiling")
		add_float_unary_op (INT,                    "float_unary_op_int")
		add_float_unary_op (FLOAT,                  "float_unary_op_float")

		add_string_binary_op(ADD,                   "string_binary_op_add")
		add_string_binary_op(EQUALS,                "string_binary_op_equals")
		add_string_binary_op(NOT_EQUALS,            "string_binary_op_not_equals")
		add_string_binary_op(HAS,                   "string_binary_op_has")
		add_string_binary_op(HASNT,                 "string_binary_op_hasnt")

		add_list_binary_op (ADD,                    "list_binary_op_add")
		add_list_binary_op (SUBTRACT,               "list_binary_op_substract")
		add_list_binary_op (HAS,                    "list_binary_op_has")
		add_list_binary_op (HASNT,                  "list_binary_op_hasnt")
		add_list_binary_op (INTERSECT,              "list_binary_op_intersect")

		add_list_binary_op (EQUALS,                 "list_binary_op_equals")
		add_list_binary_op (GREATER,                "list_binary_op_greater")
		add_list_binary_op (LESS,                   "list_binary_op_less")
		add_list_binary_op (GREATER_THAN_OR_EQUALS, "list_binary_op_greater_than_or_equals")
		add_list_binary_op (LESS_THAN_OR_EQUALS,    "list_binary_op_less_than_or_equals")
		add_list_binary_op (NOT_EQUALS,             "list_binary_op_not_equals")

		add_list_binary_op (AND,                    "list_binary_op_and")
		add_list_binary_op (OR,                     "list_binary_op_or")

		add_list_unary_op (NOT,                     "list_unary_op_not")

		add_list_unary_op (INVERT,                  "list_unary_op_invert")
		add_list_unary_op (ALL,                     "list_unary_op_all")
		add_list_unary_op (LIST_MIN,                "list_unary_op_list_min")
		add_list_unary_op (LIST_MAX,                "list_unary_op_list_max")
		add_list_unary_op (COUNT,                   "list_unary_op_count")
		add_list_unary_op (VALUE_OF_LIST,           "list_unary_op_value_of_list")

		add_op_to_native_func(EQUALS, 2, ValueType.DIVERT_TARGET,
							  "native_func_divert_targets_equal")
		add_op_to_native_func(NOT_EQUALS, 2, ValueType.DIVERT_TARGET,
							  "native_func_divert_targets_not_equal")

# (String, int, ValueType, Variant)
func add_op_to_native_func(name, args, val_type, op):
	var native_func = null # NativeFunctionCall
	if native_functions.has(name):
		native_func = native_functions[name]
	else:
		native_func = InkNativeFunctionCall().new_with_name_and_number_of_parameters(name, args)
		native_functions[name] = native_func

	native_func.add_op_func_for_type(val_type, op)

func add_int_binary_op(name, op_function_name):
	add_op_to_native_func(name, 2, ValueType.INT, op_function_name)

func add_int_unary_op(name, op_function_name):
	add_op_to_native_func(name, 1, ValueType.INT, op_function_name)

func add_float_binary_op(name, op_function_name):
	add_op_to_native_func(name, 2, ValueType.FLOAT, op_function_name)

func add_float_unary_op(name, op_function_name):
	add_op_to_native_func(name, 1, ValueType.FLOAT, op_function_name)

func add_string_binary_op(name, op_function_name):
	add_op_to_native_func(name, 2, ValueType.STRING, op_function_name)

func add_list_binary_op(name, op_function_name):
	add_op_to_native_func(name, 2, ValueType.LIST, op_function_name)

func add_list_unary_op(name, op_function_name):
	add_op_to_native_func(name, 1, ValueType.LIST, op_function_name)

# ############################################################################ #

func int_binary_op_add(x, y):                      return x + y
func int_binary_op_substract(x, y):                return x - y
func int_binary_op_multiply(x, y):                 return x * y
func int_binary_op_divide(x, y):                   return x / y
func int_binary_op_mod(x, y):                      return x % y
func int_unary_op_negate(x):                       return -x

func int_binary_op_equals(x, y):                   return x == y
func int_binary_op_greater(x, y):                  return x > y
func int_binary_op_less(x, y):                     return x < y
func int_binary_op_greater_than_or_equals(x, y):   return x >= y
func int_binary_op_less_than_or_equals(x, y):      return x <= y
func int_binary_op_not_equals(x, y):               return x != y
func int_unary_op_not(x):                          return x == 0

func int_binary_op_and(x, y):                      return x != 0 && y != 0
func int_binary_op_or(x, y):                       return x != 0 || y != 0

func int_binary_op_max(x, y):                      return max(x, y)
func int_binary_op_min(x, y):                      return min(x, y)

func int_binary_op_pow(x, y):                      return pow(float(x), float(y))
func int_unary_op_floor(x):                        return x
func int_unary_op_ceiling(x):                      return x
func int_unary_op_int(x):                          return x
func int_unary_op_float(x):                        return float(x)

func float_binary_op_add(x, y):                    return x + y
func float_binary_op_substract(x, y):              return x - y
func float_binary_op_multiply(x, y):               return x * y
func float_binary_op_divide(x, y):                 return x / y
func float_binary_op_mod(x, y):                    return fmod(x, y)
func float_unary_op_negate(x):                     return -x

func float_binary_op_equals(x, y):                 return x == y
func float_binary_op_greater(x, y):                return x > y
func float_binary_op_less(x, y):                   return x < y
func float_binary_op_greater_than_or_equals(x, y): return x >= y
func float_binary_op_less_than_or_equals(x, y):    return x <= y
func float_binary_op_not_equals(x, y):             return x != y
func float_unary_op_not(x):                        return x == 0.0

func float_binary_op_and(x, y):                    return x != 0.0 && y != 0.0
func float_binary_op_or(x, y):                     return x != 0.0 || y != 0.0

func float_binary_op_max(x, y):                    return max(x, y)
func float_binary_op_min(x, y):                    return min(x, y)

func float_binary_op_pow(x, y):                    return pow(x, y)
func float_unary_op_floor(x):                      return floor(x)
func float_unary_op_ceiling(x):                    return ceil(x)
func float_unary_op_int(x):                        return int(x)
func float_unary_op_float(x):                      return x

func string_binary_op_add(x, y):                   return str(x, y)
func string_binary_op_equals(x, y):                return x == y
func string_binary_op_not_equals(x, y):            return x != y

# Note: The Content Test (in) operator does not returns true when testing
# against the empty string, unlike the behaviour of the original C# runtime.
func string_binary_op_has(x, y):                   return y == "" || (y in x)
func string_binary_op_hasnt(x, y):                 return !(y in x) && y != ""

func list_binary_op_add(x, y):                     return x.union(y)
func list_binary_op_substract(x, y):               return x.without(y)
func list_binary_op_has(x, y):                     return x.contains(y)
func list_binary_op_hasnt(x, y):                   return !x.contains(y)
func list_binary_op_intersect(x, y):               return x.intersection(y)

func list_binary_op_equals(x, y):                  return x.equals(y)
func list_binary_op_greater(x, y):                 return x.greater_than(y)
func list_binary_op_less(x, y):                    return x.less_than(y)
func list_binary_op_greater_than_or_equals(x, y):  return x.greater_than_or_equals(y)
func list_binary_op_less_than_or_equals(x, y):     return x.less_than_or_equals(y)
func list_binary_op_not_equals(x, y):              return !x.equals(y)

func list_binary_op_and(x, y):                     return x.size() > 0 && y.size() > 0
func list_binary_op_or(x, y):                      return x.size() > 0 || y.size() > 0

func list_unary_op_not(x):                         return 1 if x.size() == 0 else 0

func list_unary_op_invert(x):                      return x.inverse
func list_unary_op_all(x):                         return x.all
func list_unary_op_list_min(x):                    return x.min_as_list()
func list_unary_op_list_max(x):                    return x.max_as_list()
func list_unary_op_count(x):                       return x.size()
func list_unary_op_value_of_list(x):               return x.max_item.value

func native_func_divert_targets_equal(d1, d2):     return d1.equals(d2)
func native_func_divert_targets_not_equal(d1, d2): return !d1.equals(d2)
