# ############################################################################ #
# Copyright © 2018-present Paul Joannon
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

tool
extends Node

class_name InkPlayer

# ############################################################################ #
# Imports
# ############################################################################ #

var InkRuntime = load("res://addons/inkgd/runtime.gd")
var InkResource = load("res://addons/inkgd/editor/import_plugins/ink_resource.gd")
var Story = load("res://addons/inkgd/runtime/story.gd")


# ############################################################################ #
# Signals
# ############################################################################ #

## Emitted when the ink runtime encountered an exception. Exception are
## usually not recoverable as they corrupt the state.
signal exception_raised(message)

## Emitted when the story encountered an error. These errors are usually
## recoverable.
signal story_error(message, type)

## Emitted with `true` when the runtime had loaded the JSON file and created
## the story. If an error was encountered, `successfully` will be `false` and
## and error will appear Godot's output.
signal loaded(successfully)

## Emitted with the text and tags of the current line when the story
## successfully continued.
signal continued(text, tags)

## Emitted when the player should pick a choice.
signal prompt_choices(choices)

## Emitted when a choice was reported back to the runtime.
signal choice_made(choice)

## Emitted when an external function is about to evaluate.
signal function_evaluating(function_name, arguments)

## Emitted when an external function evaluated.
signal function_evaluated(function_name, arguments, text_output, result)

## Emitted when a valid path string was choosen.
signal path_string_choosen(path, arguments)

## Emitted when the story ended.
signal ended()


# ############################################################################ #
# Exported Properties
# ############################################################################ #

## The compiled Ink file (.json) to play.
export(Resource) var ink_file

## When `true` the story will be created in a separate threads, to
## prevent the UI from freezing if the story is too big. Note that
## on platforms where threads aren't available, the value of this
## property is ignored.
export(bool) var loads_in_background = true


# ############################################################################ #
# Properties
# ############################################################################ #

## `true` if the story can continue (i. e. is not expecting a choice to be
## choosen and hasn't reached the end.
var can_continue: bool setget , get_can_continue
func get_can_continue() -> bool:
	if _story == null:
		_push_null_story_error()
		return false

	return _story.can_continue


## The content of the current line.
var current_text: String setget , get_current_text
func get_current_text() -> String:
	if _story == null:
		_push_null_story_error()
		return ""

	if _story.current_text == null:
		_push_null_state_error("current_choices")
		return ""

	return _story.current_text


## The current choices. Empty is there are no choices for the current line.
var current_choices: Array setget , get_current_choices
func get_current_choices() -> Array:
	if _story == null:
		_push_null_story_error()
		return []

	if _story.current_choices == null:
		_push_null_state_error("current_choices")
		return []

	var text_choices = []
	for choice in _story.current_choices:
		text_choices.append(choice.text)

	return text_choices


## The current tags. Empty is there are no tags for the current line.
var current_tags: Array setget , get_current_tags
func get_current_tags() -> Array:
	if _story == null:
		_push_null_story_error()
		return []

	if _story.current_tags == null:
		_push_null_state_error("current_tags")
		return []

	return _story.current_tags


## The global tags for the story. Empty if none have been declared.
var global_tags: Array setget , get_global_tags
func get_global_tags() -> Array:
	if _story == null:
		_push_null_story_error()
		return []

	return _story.global_tags


## `true` to allow external function fallbacks, `false` otherwise. If this
## property is `false` and the appropriate function hasn't been binded, the
## story will output an error.
var allow_external_function_fallbacks: bool setget set_aeff, get_aeff
func set_aeff(new_value):
	if _story == null:
		_push_null_story_error()
		return

	_story.allow_external_function_fallbacks = new_value
func get_aeff() -> bool:
	return _story.allow_external_function_fallbacks

## `true` if the story currenlty has choices, `false` otherwise.
var has_choices: bool setget , get_has_choices
func get_has_choices() -> bool:
	return !self.current_choices.empty()


# ############################################################################ #
# Private Properties
# ############################################################################ #

var _story = null
var _thread: Thread
var _manages_runtime: bool = false

var _observed_variables: Array = []
var _bound_functions: Array = []

# ############################################################################ #
# Overrides
# ############################################################################ #

func _ready():
	call_deferred("_add_runtime")


func _exit_tree():
	call_deferred("_remove_runtime")

# ############################################################################ #
# Methods
# ############################################################################ #

## Creates the story, based on the value of `ink_file`. The result of this
## method is reported through the 'story_loaded' signal.
func create_story():
	if ink_file == null:
		_push_error("'ink_file' is 'Nil', did Godot import the resource correctly?")
		call_deferred("emit_signal", "loaded", false)
		return

	if !("json" in ink_file) || typeof(ink_file.json) != TYPE_STRING:
		_push_error("'ink_file' doesn't have the appropriate resource type. Are you sure you imported a JSON file?")
		call_deferred("emit_signal", "loaded", false)
		return

	if loads_in_background && _current_platform_supports_threads():
		_thread = Thread.new()
		var error = _thread.start(self, "_async_create_story")
		if error != OK:
			printerr("Could not start the thread: error code %d", error)
			emit_signal("loaded", true)
	else:
		_create_story()
		_finalise_story_creation()


## Destroys the current story. ALways call this method first if you want to
## recreate the story.
func reset():
	_story = null


# ############################################################################ #
# Methods | Story Flow
# ############################################################################ #

## Continues the story.
func continue_story():
	var text: String = ""
	if self.can_continue:
		_story.continue()

		text = self.current_text

	elif self.has_choices:
		emit_signal("prompt_choices", self.current_choices)
	else:
		emit_signal("ended")

	return text


## Chooses a choice. If the story is not currently expected choices or
## the index is out of bounds, this method does nothing.
func choose_choice_index(index: int):
	if index >= 0 && index < self.current_choices.size():
		_story.choose_choice_index(index);


## Moves the story to the specified knot/stitch/gather. This method
## will throw an error through the 'exception' signal if the path string
## does not match any known path.
func choose_path_string(path_string: String):
	if _story == null:
		return

	_story.choose_path_string(path_string)


## Switches the flow, creating a new flow if it doesn't exist.
func switch_flow(flow_name):
	if _story == null:
		return

	_story.switch_flow(flow_name)


## Switches the the default flow.
func switch_to_default_flow(flow_name):
	if _story == null:
		return

	_story.switch_to_default_flow()


## Remove the given flow.
func remove_flow(flow_name):
	if _story == null:
		return

	_story.remove_flow(flow_name)


# ############################################################################ #
# Methods | State Management
# ############################################################################ #

## Gets the current state as a JSON string. It can then be saved somewhere.
func get_state() -> String:
	return _story.state.to_json()


## Sets the state from a JSON string.
func set_state(state: String):
	_story.state.load_json(state)


## Saves the current state to the given path.
func save_state_to_path(path: String):
	if !path.begins_with("res://") && !path.begins_with("user://"):
		path = "user://%s" % path

	var file = File.new()
	file.open(path, File.WRITE)
	save_state_to_file(file)
	file.close()


## Saves the current state to the file.
func save_state_to_file(file: File):
	if file.is_open():
		file.store_string(get_state())


## Loads the state from the given path.
func load_state_from_path(path: String):
	if !path.begins_with("res://") && !path.begins_with("user://"):
		path = "user://%s" % path

	var file = File.new()
	file.open(path, File.READ)
	load_state_to_file(file)
	file.close()


## Loads the state from the given file.
func load_state_to_file(file: File):
	if !file.is_open():
		return

	file.seek(0);
	if file.get_len() > 0:
		_story.state.load_json(file.get_as_text())


# ############################################################################ #
# Methods | Tags
# ############################################################################ #

## Returns the tags declared at the given path.
func tags_for_content_at_path(path) -> Array:
	if _story == null:
		return []

	return _story.tags_for_content_at_path(path)


# ############################################################################ #
# Methods | Visit Count
# ############################################################################ #

## Returns the visit count of the given path.
func visit_count_at_path_string(path: String) -> int:
	return _story.visit_count_at_path_string(path)


# ############################################################################ #
# Methods | Variables
# ############################################################################ #

## Returns the value of variable named 'name' or 'null' if it doesn't exist.
func get_variable(name: String):
	return _story.variables_state.get(name)


## Sets the value of variable named 'name'.
func set_variable(name: String, value):
	_story.variables_state.set(name, value)


# ############################################################################ #
# Methods | Variable Observers
# ############################################################################ #

## Registers an observer for the given variables.
func observe_variables(variable_names: Array, object: Object, method_name: String):
	_story.observe_variables(variable_names, object, method_name)


## Registers an observer for the given variable.
func observe_variable(variable_name: String, object: Object, method_name: String):
	_story.observe_variable(variable_name, object, method_name)


## Removes an observer for the given variable name. This method is highly
## specific and will only remove one observer.
func remove_variable_observer(object: Object, method_name: String, specific_variable_name: String):
	_story.remove_variable_observer(object, method_name, specific_variable_name)


## Removes all observers registered with the couple object/method_name,
## regardless of which variable they observed.
func remove_variable_observer_for_all_variable(object: Object, method_name: String):
	_story.remove_variable_observer(object, method_name)


## Removes all observers observing the given variable.
func remove_all_variable_observers(specific_variable_name: String):
	_story.remove_variable_observer(specific_variable_name)


# ############################################################################ #
# Methods | External Functions
# ############################################################################ #

## Binds an external function.
func bind_external_function(func_name: String, object: Object, method_name: String, lookahead_safe = false):
	_story.bind_external_function(func_name, object, method_name, lookahead_safe)


## Unbinds an external function.
func unbind_external_function(func_name: String):
	_story.unbind_external_function(func_name)


# ############################################################################ #
# Methods | Functions
# ############################################################################ #

## Evaluate a given ink function, returning its return value (but not
## its output).
func evaluate_function(function_name: String, arguments = null):
	return _story.evaluate_function(function_name, arguments, false)


## Evaluate a given ink function, returning both its return value and
## text output in a dictionary of the form:
##
## ```
## { "result": "<return_value>", "output": "<text_output>" }
## ```
func evaluate_function_and_get_output(function_name: String, arguments = null) -> Dictionary:
	return _story.evaluate_function(function_name, arguments, true)


# ############################################################################ #
# Private Methods | Signal Forwarding
# ############################################################################ #

func _exception_raised(message):
	emit_signal("exception_raised", message)


func _on_error(message, type):
	if get_signal_connection_list("on_error").size() == 0:
		printerr(message) # TODO: Deal with type.
	else:
		emit_signal("story_error", message, type)


func _on_did_continue():
	emit_signal("continued", self.current_text, self.current_tags)


func _on_make_choice(choice):
	emit_signal("choice_made", choice)


func _on_evaluate_function(function_name, arguments):
	emit_signal("function_evaluating", function_name, arguments)


func _on_complete_evaluate_function(function_name, arguments, text_output, result):
	emit_signal("function_evaluated", function_name, arguments, text_output, result)


func _on_choose_path_string(path, arguments):
	emit_signal("path_string_choosen", path, arguments)


# ############################################################################ #
# Private Methods
# ############################################################################ #

func _create_story():
	_story = Story.new(ink_file.json)


func _async_create_story():
	_create_story()
	call_deferred("_async_creation_completed")


func _async_creation_completed():
	_thread.wait_to_finish()
	_thread = null

	_finalise_story_creation()


func _finalise_story_creation():
	_story.connect("on_error", self, "_on_error")
	_story.connect("on_did_continue", self, "_on_did_continue")
	_story.connect("on_make_choice", self, "_on_make_choice")
	_story.connect("on_evaluate_function", self, "_on_evaluate_function")
	_story.connect("on_complete_evaluate_function", self, "_on_complete_evaluate_function")
	_story.connect("on_choose_path_string", self, "_on_choose_path_string")

	_story.connect_exception(self, "_exception_raised")

	emit_signal("loaded", true)


func _add_runtime():
	# The InkRuntime is normaly an auto-loaded singleton,
	# but if it's not present, it's added here.
	if get_tree().root.get_node("__InkRuntime") == null:
		_manages_runtime = true
		InkRuntime.init(get_tree().root)


func _remove_runtime():
	if _manages_runtime:
		InkRuntime.deinit(get_tree().root)


func _current_platform_supports_threads():
	return OS.get_name() != "HTML5"


func _push_null_story_error():
	_push_error("The story is 'Nil', was it loaded properly?")


func _push_null_state_error(variable: String):
	var message = "'%s' is 'Nil', the internal state is corrupted or missing, this is an unrecoverable error."
	_push_error(message % variable)


func _push_error(message: String):
	if Engine.is_editor_hint():
		printerr(message)
	else:
		push_error(message)
