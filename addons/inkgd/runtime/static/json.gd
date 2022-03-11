# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends InkBase

class_name InkStaticJSON

# In the C# code this class has only static methods. In the GDScript, it will rather
# be a unique object, added to the InkRuntime singleton.

# ############################################################################ #
# IMPORTS
# ############################################################################ #

var PushPopType = preload("res://addons/inkgd/runtime/enums/push_pop.gd").PushPopType
var InkListItem = preload("res://addons/inkgd/runtime/lists/structs/ink_list_item.gd")

# ############################################################################ #

var InkNativeFunctionCall = load("res://addons/inkgd/runtime/content/native_function_call.gd")

var InkValue = load("res://addons/inkgd/runtime/values/value.gd")
var InkStringValue = load("res://addons/inkgd/runtime/values/string_value.gd")
var InkDivertTargetValue = load("res://addons/inkgd/runtime/values/divert_target_value.gd")
var InkVariablePointerValue = load("res://addons/inkgd/runtime/values/variable_pointer_value.gd")
var InkListValue = load("res://addons/inkgd/runtime/values/list_value.gd")

var InkControlCommand = load("res://addons/inkgd/runtime/content/control_command.gd")
var InkGlue = load("res://addons/inkgd/runtime/content/glue.gd")
var InkVoid = load("res://addons/inkgd/runtime/content/void.gd")

var InkPath = load("res://addons/inkgd/runtime/ink_path.gd")
var InkDivert = load("res://addons/inkgd/runtime/content/divert.gd")
var InkTag = load("res://addons/inkgd/runtime/content/tag.gd")

var InkContainer = load("res://addons/inkgd/runtime/content/container.gd")
var InkChoice = load("res://addons/inkgd/runtime/content/choices/choice.gd")
var InkChoicePoint = load("res://addons/inkgd/runtime/content/choices/choice_point.gd")

var InkList = load("res://addons/inkgd/runtime/lists/ink_list.gd")
var InkListDefinition = load("res://addons/inkgd/runtime/lists/list_definition.gd")
var InkListDefinitionsOrigin = load("res://addons/inkgd/runtime/lists/list_definitions_origin.gd")

var InkVariableReference = load("res://addons/inkgd/runtime/content/variable_reference.gd")
var InkVariableAssignment = load("res://addons/inkgd/runtime/content/variable_assignment.gd")

# ############################################################################ #

# (Array<Variant>, bool) -> Array
func jarray_to_runtime_obj_list(jarray: Array, skip_last = false) -> Array:
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

# (self.Json.Writer, Dictionary<String, InkObject>) -> void
func write_dictionary_runtime_objs(writer, dictionary: Dictionary) -> void:
	writer.write_object_start()
	for key in dictionary:
		writer.write_property_start(key)
		write_runtime_object(writer, dictionary[key])
		writer.write_property_end()
	writer.write_object_end()

# (self.Json.Writer, Array<InkObject>) -> void
func write_list_runtime_objs(writer, list: Array) -> void:
	writer.write_array_start()
	for val in list:
		write_runtime_object(writer, val)
	writer.write_array_end()

# (self.Json.Writer, Array<Int>) -> void
func write_int_dictionary(writer, dict: Dictionary) -> void:
	writer.write_object_start()
	for key in dict:
		writer.write_property(key, dict[key])
	writer.write_object_end()

# (self.Json.Writer, InkObject) -> void
func write_runtime_object(writer, obj: InkObject) -> void:
	var container = Utils.as_or_null(obj, "InkContainer")
	if container:
		write_runtime_container(writer, container)
		return

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

		writer.write_object_start()

		writer.write_property(div_type_key, target_str)

		if divert.has_variable_target:
			writer.write_property("var", true)

		if divert.is_conditional:
			writer.write_property("c", true)

		if divert.external_args > 0:
			writer.write_property("exArgs", divert.external_args)

		writer.write_object_end()
		return

	var choice_point = Utils.as_or_null(obj, "ChoicePoint")
	if choice_point:
		writer.write_object_start()
		writer.write_property("*", choice_point.path_string_on_choice)
		writer.write_property("flg", choice_point.flags)
		writer.write_object_end()
		return

	var bool_val = Utils.as_or_null(obj, "BoolValue")
	if bool_val:
		writer.write(bool_val.value)
		return

	var int_val = Utils.as_or_null(obj, "IntValue")
	if int_val:
		writer.write(int_val.value)
		return

	var float_val = Utils.as_or_null(obj, "FloatValue")
	if float_val:
		writer.write(float_val.value)
		return

	var str_val = Utils.as_or_null(obj, "StringValue")
	if str_val:
		if str_val.is_newline:
			writer.write_string("\\n", false)
		else:
			writer.write_string_start()
			writer.write_string_inner("^")
			writer.write_string_inner(str_val.value)
			writer.write_string_end()
		return

	var list_val = Utils.as_or_null(obj, "ListValue")
	if list_val:
		write_ink_list(writer, list_val)
		return

	var div_target_val = Utils.as_or_null(obj, "DivertTargetValue")
	if div_target_val:
		writer.write_object_start()
		writer.write_property("^->", div_target_val.value.components_string)
		writer.write_object_end()
		return

	var var_ptr_val = Utils.as_or_null(obj, "VariablePointerValue")
	if var_ptr_val:
		writer.write_object_start()
		writer.write_property("^var", var_ptr_val.value)
		writer.write_property("ci", var_ptr_val.context_index)
		writer.write_object_end()
		return

	var glue = Utils.as_or_null(obj, "Glue")
	if glue:
		writer.write("<>")
		return

	var control_cmd = Utils.as_or_null(obj, "ControlCommand")
	if control_cmd:
		writer.write(self._control_command_names[control_cmd.command_type])
		return

	var native_func = Utils.as_or_null(obj, "NativeFunctionCall")
	if native_func:
		var name = native_func.name

		if name == "^": name = "L^"

		writer.write(name)
		return

	var var_ref = Utils.as_or_null(obj, "VariableReference")
	if var_ref:
		writer.write_object_start()

		var read_count_path = var_ref.path_string_for_count
		if read_count_path != null:
			writer.write_property(["CNT?"], read_count_path)
		else:
			writer.write_property(["VAR?"], var_ref.name)

		writer.write_object_end()
		return

	var var_ass = Utils.as_or_null(obj, "VariableAssignment")
	if var_ass:
		writer.write_object_start()

		var key = "VAR=" if var_ass.is_global else "temp="
		writer.write_property(key, var_ass.variable_name)

		if !var_ass.is_new_declaration:
			writer.write_property("re", true)

		writer.write_object_end()

		return

	var void_obj = Utils.as_or_null(obj, "Void")
	if void_obj:
		writer.write("void")
		return

	var tag = Utils.as_or_null(obj, "Tag")
	if tag:
		writer.write_object_start()
		writer.write_property("#", tag.text)
		writer.write_object_end()
		return

	var choice = Utils.as_or_null(obj, "Choice")
	if choice:
		write_choice(writer, choice)
		return

	Utils.throw_exception("Failed to convert runtime object to Json token: %s", obj)
	return

# (Dictionary<String, Variant>) -> Dictionary<String, InkObject>
func jobject_to_dictionary_runtime_objs(jobject: Dictionary) -> Dictionary:
	var dict = {}

	for key in jobject:
		dict[key] = jtoken_to_runtime_object(jobject[key])

	return dict

# (Dictionary<String, Variant>) -> Dictionary<String, int>
func jobject_to_int_dictionary(jobject: Dictionary) -> Dictionary:
	var dict = {}
	for key in jobject:
		dict[key] = int(jobject[key])

	return dict

# (Variant) -> InkObject
func jtoken_to_runtime_object(token) -> InkObject:

	if token is int || token is float || token is bool:
		return InkValue.create(token)

	if token is String:
		var _str = token

		var first_char = _str[0]
		if first_char == "^":
			return InkStringValue.new_with(_str.substr(1, _str.length() - 1))
		elif first_char == "\n" && _str.length() == 1:
			return InkStringValue.new_with("\n")

		if _str == "<>": return InkGlue.new()

		var i = 0
		while (i < _control_command_names.size()):
			var cmd_name = _control_command_names[i]
			if _str == cmd_name:
				return InkControlCommand.new(i)
			i += 1

		if _str == "L^": _str = "^"
		if _static_native_function_call.call_exists_with_name(_str):
			return InkNativeFunctionCall.call_with_name(_str)

		if _str == "->->":
			return InkControlCommand.pop_tunnel()
		elif _str == "~ret":
			return InkControlCommand.pop_function()

		if _str == "void":
			return InkVoid.new()

	if token is Dictionary:
		var obj = token
		var prop_value

		if obj.has("^->"):
			prop_value = obj["^->"]
			return InkDivertTargetValue.new_with(
					InkPath.new_with_components_string(str(prop_value))
			)

		if obj.has("^var"):
			prop_value = obj["^var"]
			var var_ptr = InkVariablePointerValue.new_with_context(str(prop_value))
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
			var divert = InkDivert.new()
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
			var choice = InkChoicePoint.new()
			choice.path_string_on_choice = str(prop_value)

			if obj.has("flg"):
				prop_value = obj["flg"]
				choice.flags = int(prop_value)

			return choice

		if obj.has("VAR?"):
			prop_value = obj["VAR?"]
			return InkVariableReference.new(str(prop_value))
		elif obj.has("CNT?"):
			prop_value = obj["CNT?"]
			var read_count_var_ref = InkVariableReference.new()
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
			var var_ass = InkVariableAssignment.new_with(var_name, is_new_decl)
			var_ass.is_global = is_global_var
			return var_ass

		if obj.has("#"):
			prop_value = obj["#"]
			return InkTag.new(str(prop_value))

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
				raw_list.set_item(item, val)

			return InkListValue.new_with(raw_list)

		if obj.has("originalChoicePath"):
			return jobject_to_choice(obj)

	if token is Array:
		var container = jarray_to_container(token)
		return container

	if token == null:
		return null

	Utils.throw_exception("Failed to convert token to runtime object: %s" % str(token))
	return null

# (self.Json.Writer, InkContainer, Bool) -> void
func write_runtime_container(writer, container: InkContainer, without_name = false) -> void:
	writer.write_array_start()

	for c in container.content:
		write_runtime_object(writer, c)

	var named_only_content = container.named_only_content
	var count_flags = container.count_flags
	var has_name_property = (container.name != null) && !without_name

	var has_terminator = named_only_content != null || count_flags > 0 || has_name_property

	if has_terminator:
		writer.write_object_start()

	if named_only_content != null:
		for named_content_key in named_only_content:
			var name = named_content_key
			var named_container = Utils.as_or_null(named_only_content[named_content_key], "InkContainer")
			writer.write_property_start(name)
			write_runtime_container(writer, named_container, true)
			writer.write_property_end()

	if count_flags > 0:
		writer.write_property("#f", count_flags)

	if has_name_property:
		writer.write_property("#n", container.name)

	if has_terminator:
		writer.write_object_end()
	else:
		writer.write_null()

	writer.write_array_end()

# (Array<Variant>) -> InkContainer
func jarray_to_container(jarray: Array) -> InkContainer:
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
func jobject_to_choice(jobj: Dictionary) -> InkChoice:
	var choice = InkChoice.new()
	choice.text = str(jobj["text"])
	choice.index = int(jobj["index"])
	choice.source_path = str(jobj["originalChoicePath"])
	choice.original_thread_index = int(jobj["originalThreadIndex"])
	choice.path_string_on_choice = str(jobj["targetPath"])
	return choice

# (self.Json.Writer, Choice) -> Void
func write_choice(writer, choice: InkChoice) -> void:
	writer.write_object_start()
	writer.write_property("text", choice.text)
	writer.write_property("index", choice.index)
	writer.write_property("originalChoicePath", choice.source_path)
	writer.write_property("originalThreadIndex", choice.original_thread_index)
	writer.write_property("targetPath", choice.path_string_on_choice)
	writer.write_object_end()

# (self.Json.Writer, ListValue) -> Void
func write_ink_list(writer, list_val):
	var raw_list = list_val.value

	writer.write_object_start()

	writer.write_property_start("list")

	writer.write_object_start()

	for item_key in raw_list.raw_keys():
		var item = InkListItem.from_serialized_key(item_key)
		var item_val = raw_list.get_raw(item_key)

		writer.write_property_name_start()
		writer.write_property_name_inner(item.origin_name if item.origin_name else "?")
		writer.write_property_name_inner(".")
		writer.write_property_name_inner(item.item_name)
		writer.write_property_name_end()

		writer.write(item_val)

		writer.write_property_end()

	writer.write_object_end()

	writer.write_property_end()

	if raw_list.size() == 0 && raw_list.origin_names != null && raw_list.origin_names.size() > 0:
		writer.write_property_start("origins")
		writer.write_array_start()
		for name in raw_list.origin_names:
			writer.write(name)
		writer.write_array_end()
		writer.write_property_end()

	writer.write_object_end()

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

		var def = InkListDefinition.new(name, items)
		all_defs.append(def)

	return InkListDefinitionsOrigin.new(all_defs)

func _init(native_function_call):
	_static_native_function_call = native_function_call

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
	while i < InkControlCommand.CommandType.TOTAL_VALUES:
		if _control_command_names[i] == null:
			Utils.throw_exception("Control command not accounted for in serialisation")
		i += 1

# Array<String>
var _control_command_names = null

# ############################################################################ #

# Eventually a pointer to InkRuntime.StaticJson
var _static_native_function_call = null
