# ############################################################################ #
# Copyright © 2018-2022 Paul Joannon
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

extends Node

class_name InkPlayer

# ############################################################################ #
# Imports
# ############################################################################ #

var ErrorType = preload("res://addons/inkgd/runtime/enums/error.gd").ErrorType

var InkRuntime = load("res://addons/inkgd/runtime.gd")
var InkResource = load("res://addons/inkgd/editor/import_plugins/ink_resource.gd")
var InkStory = load("res://addons/inkgd/runtime/story.gd")
var InkFunctionResult = load("res://addons/inkgd/runtime/extra/function_result.gd")


# ############################################################################ #
# Signals
# ############################################################################ #

## Emitted when the ink runtime encountered an exception. Exception are
## usually not recoverable as they corrupt the state. `stack_trace` is
## an optional PoolStringArray containing a stack trace, for logging purposes.
signal exception_raised(message, stack_trace)

## Emitted when the _story encountered an error. These errors are usually
## recoverable.
signal error_encountered(message, type)

## Emitted with `true` when the runtime had loaded the JSON file and created
## the _story. If an error was encountered, `successfully` will be `false` and
## and error will appear Godot's output.
signal loaded(successfully)

## Emitted with the text and tags of the current line when the _story
## successfully continued.
signal continued(text, tags)

## Emitted when using `continue_async`, if the time spent evaluating the ink
## exceeded the alloted time.
signal interrupted()

## Emitted when the player should pick a choice.
signal prompt_choices(choices)

## Emitted when a choice was reported back to the runtime.
signal choice_made(choice)

## Emitted when an external function is about to evaluate.
signal function_evaluating(function_name, arguments)

## Emitted when an external function evaluated.
signal function_evaluated(function_name, arguments, function_result)

## Emitted when a valid path string was choosen.
signal path_choosen(path, arguments)

## Emitted when the _story ended.
signal ended()


# ############################################################################ #
# Exported Properties
# ############################################################################ #

## The compiled Ink file (.json) to play.
export var ink_file: Resource

## When `true` the _story will be created in a separate threads, to
## prevent the UI from freezing if the _story is too big. Note that
## on platforms where threads aren't available, the value of this
## property is ignored.
export var loads_in_background: bool = true


# ############################################################################ #
# Properties
# ############################################################################ #

# These properties aren't exported because they depend on the runtime or the
# story to be set. The runtime insn't always available upon instantiation,
# and the story is only available after calling 'create_story' so rather than
# losing the values and confusing everybody, those properties are code-only.

## `true` to allow external function fallbacks, `false` otherwise. If this
## property is `false` and the appropriate function hasn't been binded, the
## _story will output an error.
var allow_external_function_fallbacks: bool setget set_aeff, get_aeff
func set_aeff(value: bool):
	if _story == null:
		_push_null_story_error()
		return

	_story.allow_external_function_fallbacks = value
func get_aeff() -> bool:
	if _story == null:
		_push_null_story_error()
		return false

	return _story.allow_external_function_fallbacks

# skips saving global values that remain equal to the initial values that were
# declared in Ink.
var do_not_save_default_values: bool setget set_dnsdv, get_dnsdv
func set_dnsdv(value: bool):
	var ink_runtime = _ink_runtime.get_ref()
	if ink_runtime == null:
		_push_null_runtime_error()
		return false

	ink_runtime.dont_save_default_values = value
func get_dnsdv() -> bool:
	var ink_runtime = _ink_runtime.get_ref()
	if ink_runtime == null:
		_push_null_runtime_error()
		return false

	return ink_runtime.dont_save_default_values

## Uses `assert` instead of `push_error` to report critical errors, thus
## making them more explicit during development.
var stop_execution_on_exception: bool setget set_seoex, get_seoex
func set_seoex(value: bool):
	var ink_runtime = _ink_runtime.get_ref()
	if ink_runtime == null:
		_push_null_runtime_error()
		return

	ink_runtime.stop_execution_on_exception = value
func get_seoex() -> bool:
	var ink_runtime = _ink_runtime.get_ref()
	if ink_runtime == null:
		_push_null_runtime_error()
		return false

	return ink_runtime.stop_execution_on_exception

## Uses `assert` instead of `push_error` to report _story errors, thus
## making them more explicit during development.
var stop_execution_on_error: bool setget set_seoer, get_seoer
func set_seoer(value: bool):
	var ink_runtime = _ink_runtime.get_ref()
	if ink_runtime == null:
		_push_null_runtime_error()
		return

	ink_runtime.stop_execution_on_error = value

func get_seoer() -> bool:
	var ink_runtime = _ink_runtime.get_ref()
	if ink_runtime == null:
		_push_null_runtime_error()
		return false

	return ink_runtime.stop_execution_on_error


# ############################################################################ #
# Read-only Properties
# ############################################################################ #

## `true` if the _story can continue (i. e. is not expecting a choice to be
## choosen and hasn't reached the end).
var can_continue: bool setget , get_can_continue
func get_can_continue() -> bool:
	if _story == null:
		_push_null_story_error()
		return false

	return _story.can_continue


## If `continue_async` was called (with milliseconds limit > 0) then this
## property will return false if the ink evaluation isn't yet finished, and
## you need to call it again in order for the continue to fully complete.
var async_continue_complete: bool setget , get_async_continue_complete
func get_async_continue_complete() -> bool:
	if _story == null:
		_push_null_story_error()
		return false

	return _story.async_continue_complete


## The content of the current line.
var current_text: String setget , get_current_text
func get_current_text() -> String:
	if _story == null:
		_push_null_story_error()
		return ""


	return _story.current_text


## The current choices. Empty is there are no choices for the current line.
var current_choices: Array setget , get_current_choices
func get_current_choices() -> Array:
	if _story == null:
		_push_null_story_error()
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
		return []

	return _story.current_tags


## The global tags for the _story. Empty if none have been declared.
var global_tags: Array setget , get_global_tags
func get_global_tags() -> Array:
	if _story == null:
		_push_null_story_error()
		return []

	if _story.global_tags == null:
		return []

	return _story.global_tags


## `true` if the _story currently has choices, `false` otherwise.
var has_choices: bool setget , get_has_choices
func get_has_choices() -> bool:
	return !self.current_choices.empty()


## The name of the current flow.
var current_flow_name: String setget , get_current_flow_name
func get_current_flow_name() -> String:
	if _story == null:
		_push_null_story_error()
		return ""

	return _story.state.current_flow_name


## The current story path.
var current_path: String setget , get_current_path
func get_current_path() -> String:
	if _story == null:
		_push_null_story_error()
		return ""

	var path = _story.state.current_path_string
	if path == null:
		return ""
	else:
		return path


# ############################################################################ #
# Private Properties
# ############################################################################ #

var _ink_runtime: WeakRef = WeakRef.new()
var _story: InkStory = null
var _thread: Thread
var _manages_runtime: bool = false


# ############################################################################ #
# Initialization
# ############################################################################ #

func _init():
	name = "InkPlayer"


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

## Creates the _story, based on the value of `ink_file`. The result of this
## method is reported through the 'story_loaded' signal.
func create_story() -> int:
	if ink_file == null:
		_push_error("'ink_file' is null, did Godot import the resource correctly?")
		call_deferred("emit_signal", "loaded", false)
		return ERR_CANT_CREATE

	if !("json" in ink_file) || typeof(ink_file.json) != TYPE_STRING:
		_push_error(
				"'ink_file' doesn't have the appropriate resource type." + \
				"Are you sure you imported a JSON file?"
		)
		call_deferred("emit_signal", "loaded", false)
		return ERR_CANT_CREATE

	if loads_in_background && _current_platform_supports_threads():
		_thread = Thread.new()
		var error = _thread.start(self, "_async_create_story", ink_file.json)
		if error != OK:
			printerr("[inkgd] [ERROR] Could not start the thread: error code %d", error)
			call_deferred("emit_signal", "loaded", false)
			return error
		else:
			return OK
	else:
		call_deferred("_create_and_finalize_story", ink_file.json)
		return OK


## Reset the Story back to its initial state as it was when it was
## first constructed.
func reset() -> void:
	if _story == null:
		_push_null_story_error()
		return

	_story.reset_state()


## Destroys the current story.
func destroy() -> void:
	_story = null

# ############################################################################ #
# Methods | Story Flow
# ############################################################################ #

## Continues the story.
func continue_story() -> String:
	if _story == null:
		_push_null_story_error()
		return ""

	var text: String = ""
	if self.can_continue:
		_story.continue()

		text = self.current_text

	elif self.has_choices:
		emit_signal("prompt_choices", self.current_choices)
	else:
		emit_signal("ended")

	return text

## An "asynchronous" version of `continue_story` that only partially evaluates
## the ink, with a budget of a certain time limit. It will exit ink evaluation
## early if the evaluation isn't complete within the time limit, with the
## `async_continue_complete` property being false. This is useful if the
## evaluation takes a long time, and you want to distribute it over multiple
## game frames for smoother animation. If you pass a limit of zero, then it will
## fully evaluate the ink in the same way as calling continue_story.
##
## To get notified when the evaluation is exited early, you can connect to the
## `interrupted` signal.
func continue_story_async(millisecs_limit_async: float) -> void:
	if _story == null:
		_push_null_story_error()
		return

	if self.can_continue:
		_story.continue_async(millisecs_limit_async)

		if !self.async_continue_complete:
			emit_signal("interrupted")
			return

	elif self.has_choices:
		emit_signal("prompt_choices", self.current_choices)
	else:
		emit_signal("ended")

## Continue the story until the next choice point or until it runs out of
## content. This is as opposed to `continue` which only evaluates one line
## of output at a time. It returns the resulting text evaluated by the ink
## engine, concatenated together.
func continue_story_maximally() -> String:
	if _story == null:
		_push_null_story_error()
		return ""

	var text: String = ""
	if self.can_continue:
		_story.continue_maximally()

		text = self.current_text

	elif self.has_choices:
		emit_signal("prompt_choices", self.current_choices)
	else:
		emit_signal("ended")

	return text

## Chooses a choice. If the _story is not currently expected choices or
## the index is out of bounds, this method does nothing.
func choose_choice_index(index: int) -> void:
	if _story == null:
		_push_null_story_error()
		return

	if index >= 0 && index < self.current_choices.size():
		_story.choose_choice_index(index);


## Moves the _story to the specified knot/stitch/gather. This method
## will throw an error through the 'exception' signal if the path string
## does not match any known path.
func choose_path(path: String) -> void:
	if _story == null:
		_push_null_story_error()
		return

	_story.choose_path_string(path)


## Switches the flow, creating a new flow if it doesn't exist.
func switch_flow(flow_name: String) -> void:
	if _story == null:
		_push_null_story_error()
		return

	_story.switch_flow(flow_name)


## Switches the the default flow.
func switch_to_default_flow() -> void:
	if _story == null:
		_push_null_story_error()
		return

	_story.switch_to_default_flow()


## Remove the given flow.
func remove_flow(flow_name: String) -> void:
	if _story == null:
		_push_null_story_error()
		return

	_story.remove_flow(flow_name)


# ############################################################################ #
# Methods | Tags
# ############################################################################ #

## Returns the tags declared at the given path.
func tags_for_content_at_path(path: String) -> Array:
	if _story == null:
		_push_null_story_error()
		return []

	return _story.tags_for_content_at_path(path)


# ############################################################################ #
# Methods | Visit Count
# ############################################################################ #

## Returns the visit count of the given path.
func visit_count_at_path(path: String) -> int:
	if _story == null:
		_push_null_story_error()
		return 0

	return _story.state.visit_count_at_path_string(path)


# ############################################################################ #
# Methods | State Management
# ############################################################################ #

## Gets the current state as a JSON string. It can then be saved somewhere.
func get_state() -> String:
	if _story == null:
		_push_null_story_error()
		return ""

	return _story.state.to_json()


## If you have a large story, and saving state to JSON takes too long for your
## framerate, you can temporarily freeze a copy of the state for saving on
## a separate thread. Internally, the engine maintains a "diff patch".
## When you've finished saving your state, call `background_save_complete`
## and that diff patch will be applied, allowing the story to continue
## in its usual mode.
func copy_state_for_background_thread_save() -> String:
	if _story == null:
		_push_null_story_error()
		return ""

	return _story.copy_state_for_background_thread_save().to_json()


## See `copy_state_for_background_thread_save`. This method releases the
## "frozen" save state, applying its patch that it was using internally.
func background_save_complete() -> void:
	if _story == null:
		_push_null_story_error()
		return

	_story.background_save_complete()


## Sets the state from a JSON string.
func set_state(state: String) -> void:
	if _story == null:
		_push_null_story_error()
		return

	_story.state.load_json(state)


## Saves the current state to the given path.
func save_state_to_path(path: String):
	if _story == null:
		_push_null_story_error()
		return

	if !path.begins_with("res://") && !path.begins_with("user://"):
		path = "user://%s" % path

	var file = File.new()
	file.open(path, File.WRITE)
	save_state_to_file(file)
	file.close()


## Saves the current state to the file.
func save_state_to_file(file: File):
	if _story == null:
		_push_null_story_error()
		return

	if file.is_open():
		file.store_string(get_state())

# TODO: Add save and load in background

## Loads the state from the given path.
func load_state_from_path(path: String):
	if _story == null:
		_push_null_story_error()
		return

	if !path.begins_with("res://") && !path.begins_with("user://"):
		path = "user://%s" % path

	var file = File.new()
	file.open(path, File.READ)
	load_state_from_file(file)
	file.close()


## Loads the state from the given file.
func load_state_from_file(file: File):
	if _story == null:
		_push_null_story_error()
		return

	if !file.is_open():
		return

	file.seek(0);
	if file.get_len() > 0:
		_story.state.load_json(file.get_as_text())


# ############################################################################ #
# Methods | Variables
# ############################################################################ #

## Returns the value of variable named 'name' or 'null' if it doesn't exist.
func get_variable(name: String):
	if _story == null:
		_push_null_story_error()
		return null

	return _story.variables_state.get(name)


## Sets the value of variable named 'name'.
func set_variable(name: String, value):
	if _story == null:
		_push_null_story_error()
		return

	_story.variables_state.set(name, value)


# ############################################################################ #
# Methods | Variable Observers
# ############################################################################ #

## Registers an observer for the given variables.
func observe_variables(variable_names: Array, object: Object, method_name: String):
	if _story == null:
		_push_null_story_error()
		return

	_story.observe_variables(variable_names, object, method_name)


## Registers an observer for the given variable.
func observe_variable(variable_name: String, object: Object, method_name: String):
	if _story == null:
		_push_null_story_error()
		return

	_story.observe_variable(variable_name, object, method_name)


## Removes an observer for the given variable name. This method is highly
## specific and will only remove one observer.
func remove_variable_observer(object: Object, method_name: String, specific_variable_name: String) -> void:
	if _story == null:
		_push_null_story_error()
		return

	_story.remove_variable_observer(object, method_name, specific_variable_name)


## Removes all observers registered with the couple object/method_name,
## regardless of which variable they observed.
func remove_variable_observer_for_all_variables(object: Object, method_name: String) -> void:
	if _story == null:
		_push_null_story_error()
		return

	_story.remove_variable_observer(object, method_name)


## Removes all observers observing the given variable.
func remove_all_variable_observers(specific_variable_name: String) -> void:
	if _story == null:
		_push_null_story_error()
		return

	_story.remove_variable_observer(null, null, specific_variable_name)


# ############################################################################ #
# Methods | External Functions
# ############################################################################ #

## Binds an external function.
func bind_external_function(
		func_name: String,
		object: Object,
		method_name: String,
		lookahead_safe = false
) -> void:
	if _story == null:
		_push_null_story_error()
		return

	_story.bind_external_function(func_name, object, method_name, lookahead_safe)


## Unbinds an external function.
func unbind_external_function(func_name: String) -> void:
	if _story == null:
		_push_null_story_error()
		return

	_story.unbind_external_function(func_name)


# ############################################################################ #
# Methods | Functions
# ############################################################################ #

func has_function(function_name: String) -> bool:
	return _story.has_function(function_name)

## Evaluate a given ink function, returning its return value (but not
## its output).
func evaluate_function(function_name: String, arguments = []) -> InkFunctionResult:
	if _story == null:
		_push_null_story_error()
		return null

	var result = _story.evaluate_function(function_name, arguments, true)

	if result != null:
		return InkFunctionResult.new(result["output"], result["result"])
	else:
		return null

# ############################################################################ #
# Methods | Ink List Creation
# ############################################################################ #

## Creates a new empty InkList that's intended to hold items from a particular
## origin list definition.
func create_ink_list_with_origin(single_origin_list_name: String) -> InkList:
	return InkList.new_with_origin(single_origin_list_name, _story)

## Creates a new InkList from the name of a preexisting item.
func create_ink_list_from_item_name(item_name: String) -> InkList:
	return InkList.from_string(item_name, _story)


# ############################################################################ #
# Private Methods | Signal Forwarding
# ############################################################################ #

func _exception_raised(message, stack_trace) -> void:
	emit_signal("exception_raised", message, stack_trace)


func _on_error(message, type) -> void:
	if get_signal_connection_list("error_encountered").size() == 0:
		_push_story_error(message, type)
	else:
		emit_signal("error_encountered", message, type)


func _on_did_continue() -> void:
	emit_signal("continued", self.current_text, self.current_tags)


func _on_make_choice(choice) -> void:
	emit_signal("choice_made", choice.text)


func _on_evaluate_function(function_name, arguments) -> void:
	emit_signal("function_evaluating", function_name, arguments)


func _on_complete_evaluate_function(function_name, arguments, text_output, return_value) -> void:
	var function_result = InkFunctionResult.new(text_output, return_value)
	emit_signal("function_evaluated", function_name, arguments, function_result)


func _on_choose_path_string(path, arguments) -> void:
	emit_signal("path_choosen", path, arguments)


# ############################################################################ #
# Private Methods
# ############################################################################ #

func _create_story(json_story) -> void:
	_story = InkStory.new(json_story)


func _async_create_story(json_story) -> void:
	_create_story(json_story)
	call_deferred("_async_creation_completed")


func _async_creation_completed() -> void:
	_thread.wait_to_finish()
	_thread = null

	_finalise_story_creation()


func _create_and_finalize_story(json_story) -> void:
	_create_story(json_story)
	_finalise_story_creation()


func _finalise_story_creation() -> void:
	_story.connect("on_error", self, "_on_error")
	_story.connect("on_did_continue", self, "_on_did_continue")
	_story.connect("on_make_choice", self, "_on_make_choice")
	_story.connect("on_evaluate_function", self, "_on_evaluate_function")
	_story.connect("on_complete_evaluate_function", self, "_on_complete_evaluate_function")
	_story.connect("on_choose_path_string", self, "_on_choose_path_string")

	var ink_runtime = _ink_runtime.get_ref()
	if ink_runtime == null:
		_push_null_runtime_error()
		emit_signal("loaded", false)
		return

	emit_signal("loaded", true)


func _add_runtime() -> void:
	# The InkRuntime is normaly an auto-loaded singleton,
	# but if it's not present, it's added here.
	var runtime: Node
	if get_tree().root.has_node("__InkRuntime"):
		runtime = get_tree().root.get_node("__InkRuntime")
	else:
		_manages_runtime = true
		runtime = InkRuntime.init(get_tree().root)

	runtime.connect("exception_raised", self, "_exception_raised")

	_ink_runtime = weakref(runtime)


func _remove_runtime() -> void:
	if _manages_runtime:
		InkRuntime.deinit(get_tree().root)


func _current_platform_supports_threads() -> bool:
	return OS.get_name() != "HTML5"


func _push_null_runtime_error() -> void:
	_push_error(
			"InkRuntime could not found, did you remove it from the tree?"
	)


func _push_null_story_error() -> void:
	_push_error("The _story is 'null', was it loaded properly?")


func _push_story_error(message: String, type: int) -> void:
	if Engine.editor_hint:
		match type:
			ErrorType.ERROR:
				printerr(message)
			ErrorType.WARNING, ErrorType.AUTHOR:
				print(message)
	else:
		match type:
			ErrorType.ERROR:
				push_error(message)
			ErrorType.WARNING, ErrorType.AUTHOR:
				push_warning(message)

func _push_error(message: String):
	if Engine.editor_hint:
		printerr(message)

		var i = 1
		for stack_element in get_stack():
			if i <= 2:
				i += 1
				continue

			printerr(
				"    ", (i - 2), " - ", stack_element["source"], ":",
				stack_element["line"], " - at function: ", stack_element["function"]
			)
	else:
		push_error(message)
