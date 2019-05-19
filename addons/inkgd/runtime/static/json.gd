# ############################################################################ #
# Copyright © 2015-present inkle Ltd.
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends Reference

# In the C# code this class has only static methods. In the GDScript, it will rather
# be a unique object, added to the InkRuntime singleton.

# ############################################################################ #
# IMPORTS
# ############################################################################ #

var PushPopType = preload("res://addons/inkgd/runtime/push_pop.gd").PushPopType
var Ink = load("res://addons/inkgd/runtime/value.gd")
var Glue = load("res://addons/inkgd/runtime/glue.gd")
var ControlCommand = load("res://addons/inkgd/runtime/control_command.gd")
var Divert = load("res://addons/inkgd/runtime/divert.gd")
var ChoicePoint = load("res://addons/inkgd/runtime/choice_point.gd")
var VariableReference = load("res://addons/inkgd/runtime/variable_reference.gd")
var VariableAssignment = load("res://addons/inkgd/runtime/variable_assignment.gd")
var Tag = load("res://addons/inkgd/runtime/tag.gd")
var ListDefinition = load("res://addons/inkgd/runtime/list_definition.gd")
var ListDefinitionsOrigin = load("res://addons/inkgd/runtime/list_definitions_origin.gd")
var InkListItem = load("res://addons/inkgd/runtime/ink_list_item.gd")
var InkList = load("res://addons/inkgd/runtime/ink_list.gd")
var NativeFunctionCall = load("res://addons/inkgd/runtime/native_function_call.gd")
var Void = load("res://addons/inkgd/runtime/void.gd")
var InkContainer = load("res://addons/inkgd/runtime/container.gd")
var Choice = load("res://addons/inkgd/runtime/choice.gd")
var InkPath = load("res://addons/inkgd/runtime/ink_path.gd")
var Utils = load("res://addons/inkgd/runtime/extra/utils.gd")

# ############################################################################ #

# (Array) -> Array
func list_to_jarray(serialisables):
    var jarray = []
    for s in serialisables:
        jarray.append(runtime_object_to_jtoken(s))

    return jarray

# (Array, bool) -> Array
func jarray_to_runtime_obj_list(jarray, skip_last = false):
    var count = jarray.size()
    if skip_last:
        count -= 1

    var list = []
    var i = 0
    while (i < count):
        var jtok = jarray[i]
        var runtime_obj = jtoken_to_runtime_object(jtok)
        list.append(runtime_obj)

        i += 1

    return list

# (Dictionary<String, InkObject>) -> Dictionary<String, Variant>
func dictionary_runtime_objs_to_jobject(dictionary):
    var json_obj = {}

    for key in dictionary:
        var runtime_obj = Utils.as_or_null(dictionary[key], "InkObject")
        if runtime_obj != null:
            json_obj[key] = runtime_object_to_jtoken(runtime_obj)

    return json_obj

# (Dictionary<String, Variant>) -> Dictionary<String, InkObject>
func jobject_to_dictionary_runtime_objs(jobject):
    var dict = {}

    for key in jobject:
        dict[key] = jtoken_to_runtime_object(jobject[key])

    return dict

# (Dictionary<String, Variant>) -> Dictionary<String, int>
func jobject_to_int_dictionary(jobject):
    var dict = {}
    for key in jobject:
        dict[key] = int(jobject[key])

    return dict

# (Dictionary<String, int>) -> Dictionary<String, InkObject>
func int_dictionary_to_jobject(dict):
    var jobj = {}

    for key in dict:
        jobj[key] = dict[key]

    return jobj

# (Variant) -> InkObject
func jtoken_to_runtime_object(token):

    if token is int || token is float:
        return Ink.Value.create(token)

    if token is String:
        var _str = token

        var first_char = _str[0]
        if first_char == "^":
            return Ink.StringValue.new_with(_str.substr(1, _str.length() - 1))
        elif first_char == "\n" && _str.length() == 1:
            return Ink.StringValue.new_with("\n")

        if _str == "<>": return Glue.new()

        var i = 0
        while (i < _control_command_names.size()):
            var cmd_name = _control_command_names[i]
            if _str == cmd_name:
                return ControlCommand.new(i)
            i += 1

        if _str == "L^": _str = "^"
        if StaticNativeFunctionCall.call_exists_with_name(_str):
            return NativeFunctionCall.call_with_name(_str)

        if _str == "->->":
            return ControlCommand.pop_tunnel()
        elif _str == "~ret":
            return ControlCommand.pop_function()

        if _str == "void":
            return Void.new()

    if token is Dictionary:
        var obj = token
        var prop_value

        if obj.has("^->"):
            prop_value = obj["^->"]
            return Ink.DivertTargetValue.new_with(InkPath.new_with_components_string(str(prop_value)))

        if obj.has("^var"):
            prop_value = obj["^var"]
            var var_ptr = Ink.VariablePointerValue.new_with_context(str(prop_value))
            if (obj.has("ci")):
                prop_value = obj["ci"]
                var_ptr.context_index = int(prop_value)
            return var_ptr

        var is_divert = false
        var pushes_to_stack = false
        var div_push_type = PushPopType.FUNCTION
        var external = false

        if obj.has("->"):
            prop_value = obj["->"]
            is_divert = true
        elif obj.has("f()"):
            prop_value = obj["f()"]
            is_divert = true
            pushes_to_stack = true
            div_push_type = PushPopType.FUNCTION
        elif obj.has("->t->"):
            prop_value = obj["->t->"]
            is_divert = true
            pushes_to_stack = true
            div_push_type = PushPopType.TUNNEL
        elif obj.has("x()"):
            prop_value = obj["x()"]
            is_divert = true
            external = true
            pushes_to_stack = false
            div_push_type = PushPopType.FUNCTION

        if is_divert:
            var divert = Divert.new()
            divert.pushes_to_stack = pushes_to_stack
            divert.stack_push_type = div_push_type
            divert.is_external = external

            var target = str(prop_value)

            if obj.has("var"):
                prop_value = obj["var"]
                divert.variable_divert_name = target
            else:
                divert.target_path_string = target

            divert.is_conditional = obj.has("c")
            #if divert.is_conditional: prop_value = obj["c"]

            if external:
                if obj.has("exArgs"):
                    prop_value = obj["exArgs"]
                    divert.external_args = int(prop_value)

            return divert

        if obj.has("*"):
            prop_value = obj["*"]
            var choice = ChoicePoint.new()
            choice.path_string_on_choice = str(prop_value)

            if obj.has("flg"):
                prop_value = obj["flg"]
                choice.flags = int(prop_value)

            return choice

        if obj.has("VAR?"):
            prop_value = obj["VAR?"]
            return VariableReference.new(str(prop_value))
        elif obj.has("CNT?"):
            prop_value = obj["CNT?"]
            var read_count_var_ref = VariableReference.new()
            read_count_var_ref.path_string_for_count = str(prop_value)
            return read_count_var_ref

        var is_var_ass = false
        var is_global_var = false
        if obj.has("VAR="):
            prop_value = obj["VAR="]
            is_var_ass = true
            is_global_var = true
        elif obj.has("temp="):
            prop_value = obj["temp="]
            is_var_ass = true
            is_global_var = false

        if is_var_ass:
            var var_name = str(prop_value)
            var is_new_decl = !obj.has("re")
            var var_ass = VariableAssignment.new_with(var_name, is_new_decl)
            var_ass.is_global = is_global_var
            return var_ass

        if obj.has("#"):
            prop_value = obj["#"]
            return Tag.new(str(prop_value))

        if obj.has("list"):
            prop_value = obj["list"]
            var list_content = prop_value
            var raw_list = InkList.new()
            if obj.has("origins"):
                prop_value = obj["origins"]
                var names_as_objs = prop_value
                raw_list.set_initial_origin_names(names_as_objs)

            for name_to_val_key in list_content:
                var item = InkListItem.new_with_full_name(name_to_val_key)
                var val = list_content[name_to_val_key]
                raw_list.set(item, val)

            return Ink.ListValue.new_with(raw_list)

        if obj["originalChoicePath"] != null:
            return jobject_to_choice(obj)

    if token is Array:
        var container = jarray_to_container(token)
        return container

    if token == null:
        return null

    Utils.throw_exception("Failed to convert token to runtime object: " + token)
    return null

# (InkObject) -> Variant
func runtime_object_to_jtoken(obj):
    var container = Utils.as_or_null(obj, "InkContainer")
    if container:
        return container_to_jarray(container)

    var divert = Utils.as_or_null(obj, "Divert")
    if divert:
        var div_type_key = "->" # String
        if divert.is_external:
            div_type_key = "x()"
        elif divert.pushes_to_stack:
            if divert.stack_push_type == PushPopType.FUNCTION:
                div_type_key = "f()"
            elif divert.stackPushType == PushPopType.TUNNEL:
                div_type_key = "->t->"

        var target_str = null # String
        if divert.has_variable_target:
            target_str = divert.variable_divert_name
        else:
            target_str = divert.target_path_string

        var jobj = {} # Dictionary<String, Variant>
        jobj[div_type_key] = target_str

        if divert.has_variable_target:
            jobj["var"] = true

        if divert.is_conditional:
            jobj["c"] = true

        if divert.external_args > 0:
            jobj["exArgs"] = divert.external_args

        return jobj

    var choice_point = Utils.as_or_null(obj, "ChoicePoint")
    if choice_point:
        var jobj = {} # Dictionary<String, Variant>
        jobj["*"] = choice_point.path_string_on_choice
        jobj["flg"] = choice_point.flags
        return jobj

    var int_val = Utils.as_or_null(obj, "IntValue")
    if int_val:
        return int_val.value

    var float_val = Utils.as_or_null(obj, "FloatValue")
    if float_val:
        return float_val.value

    var str_val = Utils.as_or_null(obj, "StringValue")
    if str_val:
        if str_val.is_newline:
            return "\n"
        else:
            return "^" + str_val.value

    var list_val = Utils.as_or_null(obj, "ListValue")
    if list_val:
        return ink_list_to_jobject(list_val)

    var div_target_val = Utils.as_or_null(obj, "DivertTargetValue")
    if div_target_val:
        var div_target_json_obj = {} # Dictionary<String, Variant>
        div_target_json_obj["^->"] = div_target_val.value.components_string
        return div_target_json_obj

    var var_ptr_val = Utils.as_or_null(obj, "VariablePointerValue")
    if var_ptr_val:
        var var_ptr_json_obj = {} # Dictionary<String, Variant>
        var_ptr_json_obj["^var"] = var_ptr_val.value
        var_ptr_json_obj["ci"] = var_ptr_val.context_index
        return var_ptr_json_obj

    var glue = Utils.as_or_null(obj, "Glue")
    if glue: return "<>"

    var control_cmd = Utils.as_or_null(obj, "ControlCommand")
    if control_cmd:
        return _control_command_names[control_cmd.command_type]

    var native_func = Utils.as_or_null(obj, "NativeFunctionCall")
    if native_func:
        var name = native_func.name

        if name == "^": name = "L^"
        return name

    var var_ref = Utils.as_or_null(obj, "VariableReference")
    if var_ref:
        var jobj = {} # Dictionary<String, Variant>
        var read_count_path = var_ref.path_string_for_count
        if read_count_path != null:
            jobj ["CNT?"] = read_count_path
        else:
            jobj ["VAR?"] = var_ref.name

        return jobj

    var var_ass = Utils.as_or_null(obj, "VariableAssignment")
    if var_ass:
        var key = "VAR=" if var_ass.is_global else "temp="
        var jobj = {} # Dictionary<String, Variant>
        jobj[key] = var_ass.variable_name

        if !var_ass.is_new_declaration:
            jobj["re"] = true

        return jobj

    var void_obj = Utils.as_or_null(obj, "Void")
    if void_obj:
        return "void"

    var tag = Utils.as_or_null(obj, "Tag")
    if tag:
        var jobj = {} # Dictionary<String, Variant>
        jobj["#"] = tag.text
        return jobj

    var choice = Utils.as_or_null(obj, "Choice")
    if choice:
        return choice_to_jobject(choice)

    Utils.throw_exception(str("Failed to convert runtime object to Json token: ", obj))
    return null

# (InkContainer) -> Array<Variant>
func container_to_jarray(container):
    var jarray = list_to_jarray(container.content)

    var named_only_content = container.named_only_content
    var count_flags = container.count_flags
    if (named_only_content != null && named_only_content.size() > 0 ||
        count_flags > 0 || container.name != null):

        var terminating_obj = null # Dictionary<String, Variant>
        if named_only_content != null:
            terminating_obj = dictionary_runtime_objs_to_jobject(named_only_content)

            for named_content_obj_key in terminating_obj:
                var sub_container_jarray = Utils.as_or_null(terminating_obj[named_content_obj_key], "Array")
                if sub_container_jarray != null:
                    var attr_jobj = Utils.as_or_null(sub_container_jarray.back(), "Dictionary")
                    if attr_jobj != null:
                        attr_jobj.erase("#n")
                        if attr_jobj.size() == 0:
                            sub_container_jarray[sub_container_jarray.size() - 1] = null
        else:
            terminating_obj = {}

        if count_flags > 0:
            terminating_obj["#f"] = count_flags

        if container.name != null:
            terminating_obj["#n"] = container.name

        jarray.append(terminating_obj)
    else:
        jarray.append(null)

    return jarray

# (Array<Variant>) -> InkContainer
func jarray_to_container(jarray):
    var container = InkContainer.new()
    container.content = jarray_to_runtime_obj_list(jarray, true)

    var terminating_obj = Utils.as_or_null(jarray.back(), "Dictionary") # Dictionary<string, Variant>
    if terminating_obj != null:
        var named_only_content = {} # new Dictionary<String, InkObject>

        for key in terminating_obj:
            if key == "#f":
                container.count_flags = int(terminating_obj[key])
            elif key == "#n":
                container.name = str(terminating_obj[key])
            else:
                var named_content_item = jtoken_to_runtime_object(terminating_obj[key])
                var named_sub_container = Utils.as_or_null(named_content_item, "InkContainer")
                if named_sub_container:
                    named_sub_container.name = key
                named_only_content[key] = named_content_item

        container.named_only_content = named_only_content

    return container

# (Dictionary<String, Variant>) -> Choice
func jobject_to_choice(jobj):
    var choice = Choice.new()
    choice.text = str(jobj["text"])
    choice.index = int(jobj["index"])
    choice.source_path = str(jobj["originalChoicePath"])
    choice.original_thread_index = int(jobj["originalThreadIndex"])
    choice.path_string_on_choice = str(jobj["targetPath"])
    return choice

# (Choice) -> Dictionary<String, Variant>
func choice_to_jobject(choice):
    var jobj = {} # Dictionary<String, Variant>
    jobj["text"] = choice.text
    jobj["index"] = choice.index
    jobj["originalChoicePath"] = choice.source_path
    jobj["originalThreadIndex"] = choice.original_thread_index
    jobj["targetPath"] = choice.path_string_on_choice
    return jobj

# (ListValue) -> Dictionary<String, Variant>
func ink_list_to_jobject(list_val):
    var raw_list = list_val.value

    var dict = {} # Dictionary<String, Variant>

    var content = {} # Dictionary<String, Variant>

    for item_key in raw_list.raw_keys():
        var item = item_key
        var val = raw_list.get_raw(item_key)
        content[InkListItem.from_serialized_key(item).to_string()] = val

    dict["list"] = content

    if raw_list.size() == 0 && raw_list.origin_names != null && raw_list.origin_names.size() > 0:
        dict["origins"] = raw_list.origin_names

    return dict

# (ListDefinitionsOrigin) -> Dictionary<String, Variant>
func list_definitions_to_jtoken (origin):
    var result = {} # Dictionary<String, Variant>
    for def in origin.lists:
        var list_def_json = {} # Dictionary<String, Variant>
        for item_to_val_key in def.items:
            var item = InkListItem.from_serialized_key(item_to_val_key)
            var val = def.items[item_to_val_key]
            list_def_json[item.item_name] = val

        result[def.name] = list_def_json

    return result

# (Variant) -> ListDefinitionsOrigin
func jtoken_to_list_definitions(obj):
    var defs_obj = obj

    var all_defs = [] # Array<ListDefinition>

    for k in defs_obj:
        var name = str(k) # String
        var list_def_json = defs_obj[k] # Dictionary<String, Variant>


        var items = {} # Dictionary<String, int>
        for name_value_key in list_def_json:
            items[name_value_key] = int(list_def_json[name_value_key])

        var def = ListDefinition.new(name, items)
        all_defs.append(def)

    return ListDefinitionsOrigin.new(all_defs)

func _init(native_function_call):
    StaticNativeFunctionCall = native_function_call

    _control_command_names = []

    _control_command_names.append("ev")        # EVAL_START
    _control_command_names.append("out")       # EVAL_OUTPUT
    _control_command_names.append("/ev")       # EVAL_END
    _control_command_names.append("du")        # DUPLICATE
    _control_command_names.append("pop")       # POP_EVALUATED_VALUE
    _control_command_names.append("~ret")      # POP_FUNCTION
    _control_command_names.append("->->")      # POP_TUNNEL
    _control_command_names.append("str")       # BEGIN_STRING
    _control_command_names.append("/str")      # END_STRING
    _control_command_names.append("nop")       # NO_OP
    _control_command_names.append("choiceCnt") # CHOICE_COUNT
    _control_command_names.append("turn")      # TURNS
    _control_command_names.append("turns")     # TURNS_SINCE
    _control_command_names.append("readc")     # READ_COUNT
    _control_command_names.append("rnd")       # RANDOM
    _control_command_names.append("srnd")      # SEED_RANDOM
    _control_command_names.append("visit")     # VISIT_INDEX
    _control_command_names.append("seq")       # SEQUENCE_SHUFFLE_INDEX
    _control_command_names.append("thread")    # START_THREAD
    _control_command_names.append("done")      # DONE
    _control_command_names.append("end")       # END
    _control_command_names.append("listInt")   # LIST_FROM_INT
    _control_command_names.append("range")     # LIST_RANGE
    _control_command_names.append("lrnd")      # LIST_RANDOM

    var i = 0
    while i < ControlCommand.CommandType.TOTAL_VALUES:
        if _control_command_names[i] == null:
            Utils.throw_exception("Control command not accounted for in serialisation")
        i += 1

var _control_command_names = null # Array<String>

# ############################################################################ #

var StaticNativeFunctionCall = null # Eventually a pointer to InkRuntime.StaticJson
