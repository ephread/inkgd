# ############################################################################ #
# Copyright © 2015-present inkle Ltd.
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://addons/inkgd/runtime/ink_base.gd"

# ############################################################################ #
# Imports
# ############################################################################ #

var TryGetResult = load("res://addons/inkgd/runtime/extra/try_get_result.gd")
var StringSet = load("res://addons/inkgd/runtime/extra/string_set.gd")
var Ink = load("res://addons/inkgd/runtime/value.gd")

# ############################################################################ #

# (String, InkObject)
signal variable_changed(variable_name, new_value)

var batch_observing_variable_changes setget set_batch_observing_variable_changes, \
                                           get_batch_observing_variable_changes
func get_batch_observing_variable_changes():
    return _batch_observing_variable_changes

func set_batch_observing_variable_changes(value):
    _batch_observing_variable_changes = value
    if value:
        _changed_variables = StringSet.new()
    else:
        if _changed_variables != null:
            for variable_name in _changed_variables.enumerate():
                var current_value = _global_variables[variable_name]
                emit_signal("variable_changed", variable_name, current_value)

        _changed_variables = null

var _batch_observing_variable_changes # bool

var call_stack setget set_call_stack, get_call_stack
func get_call_stack():
        return _call_stack

func set_call_stack(value):
        _call_stack = value

func get(variable_name):
    if _global_variables.has(variable_name):
        return _global_variables[variable_name].value_object
    elif _default_global_variables.has(variable_name):
        return _default_global_variables[variable_name].value_object
    else:
        return null

func set(variable_name, value):
    if !_default_global_variables.has(variable_name):
        Utils.throw_story_exception(str(
            "Cannot assign to a variable (",
            variable_name,
            ") that hasn't been declared in the story"
        ))
        return

    var val = Ink.Value.create(value)
    if val == null:
        if value == null:
            Utils.throw_story_exception("Cannot pass null to VariableState")
        else:
            Utils.throw_story_exception(
                "Invalid value passed to VariableState: " + str(value)
            )
        return

    set_global(variable_name, val)

func enumerate():
    return _global_variables.keys()

func _init(call_stack, list_defs_origin):
    get_json()
    _global_variables = {}
    _call_stack = call_stack
    _list_defs_origin = list_defs_origin

func copy_from(to_copy):
    _global_variables = to_copy._global_variables.duplicate()

    _default_global_variables = to_copy._default_global_variables

    for connected_signal in to_copy.get_signal_connection_list("variable_changed"):
        self.connect("variable_changed", connected_signal["target"], connected_signal["method"])

    if to_copy.batch_observing_variable_changes != self.batch_observing_variable_changes:
        if to_copy.batch_observing_variable_changes:
            _batch_observing_variable_changes = true
            _changed_variables = to_copy._changed_variables.duplicate()
        else:
            _batch_observing_variable_changes = false
            _changed_variables = null

var json_token setget set_json_token, get_json_token # Dictionary<String, Variant>
func get_json_token():
    return Json.dictionary_runtime_objs_to_jobject(_global_variables)

func set_json_token(value):
    _global_variables = Json.jobject_to_dictionary_runtime_objs(value)

# (String) -> { exists: bool, result: InkObject }
func try_get_default_variable_value(name):
    if _default_global_variables.has(name):
        return TryGetResult.new(true, _default_global_variables[name])
    else:
        return TryGetResult.new(false, null)

# (String) -> bool
func global_variable_exists_with_name(name):
    return (_global_variables.has(name) ||
            _default_global_variables != null && _default_global_variables.has(name))

# (String, int) -> InkObject
func get_variable_with_name(name, context_index = -1):
    var var_value = get_raw_variable_with_name(name, context_index)

    var var_pointer = Utils.as_or_null(var_value, "VariablePointerValue")
    if var_pointer:
        var_value = value_at_variable_pointer(var_pointer)

    return var_value

# (String, int) -> InkObject
func get_raw_variable_with_name(name, context_index):
    var var_value = null

    if context_index == 0 || context_index == -1:

        if _global_variables.has(name):
            return _global_variables[name]

        var list_item_value = _list_defs_origin.find_single_item_list_with_name(name)

        if list_item_value:
            return list_item_value

    var_value = _call_stack.get_temporary_variable_with_name(name, context_index)

    return var_value

# (VariablePointerValue) -> InkObject
func value_at_variable_pointer(pointer):
    return get_variable_with_name(pointer.variable_name, pointer.context_index)

# (VariableAssignment, InkObject) -> void
func assign(var_ass, value):
    var name = var_ass.variable_name
    var context_index = -1

    var set_global = false
    if (var_ass.is_new_declaration):
        set_global = var_ass.is_global
    else:
        set_global = global_variable_exists_with_name(name)

    if var_ass.is_new_declaration:
        var var_pointer = Utils.as_or_null(value, "VariablePointerValue")
        if var_pointer:
            var fully_resolved_variable_pointer = resolve_variable_pointer(var_pointer)
            value = fully_resolved_variable_pointer
    else:
        var existing_pointer = null # VariablePointerValue
        var first_time = true
        while (existing_pointer || first_time):
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
        _call_stack.set_temporary_variable(name, value, var_ass.is_new_declaration, context_index)

# () -> void
func snapshot_default_globals():
    _default_global_variables = _global_variables.duplicate()

# (InkObject, InkObject)
func retain_list_origins_for_assignment(old_value, new_value):
    var old_list = Utils.as_or_null(old_value, "ListValue")
    var new_list = Utils.as_or_null(new_value, "ListValue")

    if old_list && new_list && new_list.value.size() == 0:
        new_list.value.set_initial_origin_names(old_list.value.origin_names)

# (String, InkObject)
func set_global(variable_name, value):
    var old_value = null # InkObject
    if _global_variables.has(variable_name):
        old_value = _global_variables[variable_name]

    Ink.ListValue.retain_list_origins_for_assignment(old_value, value)

    _global_variables[variable_name] = value

    if !value.equals(old_value):
        if _batch_observing_variable_changes:
            _changed_variables.append(variable_name)
        else:
            emit_signal("variable_changed", variable_name, value)

# (VariablePointerValue) -> VariablePointerValue
func resolve_variable_pointer(var_pointer):
    var context_index = var_pointer.context_index

    if context_index == -1:
        context_index = get_context_index_of_variable_named(var_pointer.variable_name)

    var value_of_variable_pointed_to = get_raw_variable_with_name(
        var_pointer.variable_name, context_index
    )

    var double_redirection_pointer = Utils.as_or_null(
        value_of_variable_pointed_to, "VariablePointerValue"
    )

    if double_redirection_pointer:
        return double_redirection_pointer
    else:
        return Ink.VariablePointerValue.new_with_context(var_pointer.variable_name, context_index)

# ############################################################################ #

# (String) -> int
func get_context_index_of_variable_named(var_name):
    if global_variable_exists_with_name(var_name):
        return 0

    return _call_stack.current_element_index

var _global_variables = null # Dictionary<String, InkObject>
var _default_global_variables = null # Dictionary<String, InkObject>

var _call_stack = null # CallStack
var _changed_variables = null # StringSet
var _list_defs_origin = null # ListDefinitionsOrigin

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type):
    return type == "VariableState" || .is_class(type)

func get_class():
    return "VariableState"

# ############################################################################ #

var Json = null # Eventually a pointer to InkRuntime.StaticJson

func get_json():
    var InkRuntime = Engine.get_main_loop().root.get_node("__InkRuntime")

    Utils.assert(InkRuntime != null,
                 str("Could not retrieve 'InkRuntime' singleton from the scene tree."))

    Json = InkRuntime.json
