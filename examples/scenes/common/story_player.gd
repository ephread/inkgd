# warning-ignore-all:return_value_discarded
# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

extends Node

# ############################################################################ #
# Imports
# ############################################################################ #

var ErrorType := preload("res://addons/inkgd/runtime/enums/error.gd").ErrorType
var InkPlayerFactory := preload("res://addons/inkgd/ink_player_factory.gd") as GDScript
var InkList := preload("res://addons/inkgd/runtime/lists/ink_list.gd") as GDScript

var ChoiceContainer := load("res://examples/scenes/common/choice_container.tscn") as PackedScene
var LineLabel := load("res://examples/scenes/common/label.tscn") as PackedScene

var InkGDProfiler := load("res://examples/scenes/common/profiler.gd") as GDScript


# ############################################################################ #
# Constants
# ############################################################################ #

const USE_SIGNALS = true


# ############################################################################ #
# Properties
# ############################################################################ #

# If you're trying to figure out how to use inkgd,
# you can ignore those exports. They just make overriding
# the story and creating multiple scenes easier.
# For context, see main.tscn.
export var ink_file: Resource
export var title: String
export var bind_externals: bool = false


# ############################################################################ #
# Private Properties
# ############################################################################ #

var _current_choice_container: ChoiceContainer
var _profiler: InkGDProfiler = InkGDProfiler.new()

# InkPlayer is created through the factory so that it returns the appropriate
# node depending on whether the project is using Mono or not.
#
# In your project you can also add it in the scene tree and use the inspector
# to set the variables.
var _ink_player = InkPlayerFactory.create()


# ############################################################################ #
# Node
# ############################################################################ #

onready var _story_margin_container = $StoryMarginContainer
onready var _story_vbox_container = $StoryMarginContainer/StoryScrollContainer/StoryVBoxContainer
onready var _loading_animation_player = $LoadingAnimationPlayer
onready var _title_label = $LoadingAnimationPlayer/CenterContainer/VBoxContainer/TitleLabel


# ############################################################################ #
# Lifecycle
# ############################################################################ #

func _ready():
	add_child(_ink_player)

	# Again, if you're just trying to figure out how to use
	# inkgd, you can ignore this call.
	_override_story()

	if USE_SIGNALS:
		_connect_optional_signals()

	_connect_signals()

	_profiler.start()
	_ink_player.create_story()


# ############################################################################ #
# Private Methods
# ############################################################################ #

func _continue_story():
	if USE_SIGNALS:
		_ink_player.continue_story()
	else:
		while _ink_player.can_continue:
			var text = _ink_player.continue_story()
			_add_label(text)

		if _ink_player.has_choices:
			_prompt_choices(_ink_player.current_choices)
		else:
			_ended()


# ############################################################################ #
# Signal Receivers
# ############################################################################ #

func _loaded(successfully: bool):
	if !successfully:
		return

	_profiler.stop()
	print("Created The Intercept in %d ms." % _profiler.milliseconds_elaspsed)

	_bind_externals()
	_evaluate_functions()
	_continue_story()
	_remove_loading_overlay()


func _continued(text, tags):
	_add_label(text)

	_ink_player.continue_story()


func _add_label(text):
	var label = LineLabel.instance()
	label.text = text

	_story_vbox_container.add_child(label)


func _prompt_choices(choices):
	if !choices.empty():
		_current_choice_container = ChoiceContainer.instance()
		_story_vbox_container.add_child(_current_choice_container)

		_current_choice_container.create_choices(choices)
		_current_choice_container.connect("choice_selected", self, "_choice_selected")


func _ended():
	# End of story: let's check whether you took the cup of tea.
	var teacup = _ink_player.get_variable("teacup")

	if teacup:
		print("Took the tea.")
	else:
		print("Didn't take the tea.")


func _choice_selected(index):
	_story_vbox_container.remove_child(_current_choice_container)
	_current_choice_container.queue_free()

	_ink_player.choose_choice_index(index)
	_continue_story()


func _exception_raised(message, stack_trace):
	# This method gives a chance to react to a story-breaking exception.
	printerr(message)
	for line in stack_trace:
		printerr(line)


func _error_encountered(message, type):
	match type:
		ErrorType.ERROR:
			printerr(message)
		ErrorType.WARNING:
			print(message)
		ErrorType.AUTHOR:
			print(message)


# ############################################################################ #
# Private Methods
# ############################################################################ #

## Overrides the title and resource loaded with the values set through
## exported properties. The sole purpose of this method is to faccilitate
## the creation of multiple examples. For context, see main.tscn.
func _override_story():
	if ink_file != null:
		_ink_player.ink_file = ink_file

	if !title.empty():
		_title_label.text = title


func _should_show_debug_menu(debug):
	# Contrived external function example, where
	# we just return the pre-existing value.
	print("_should_show_debug_menu called")
	return debug


func _observe_variables(variable_name, new_value):
	print("Variable '%s' changed to: %s" %[variable_name, new_value])


func _bind_externals():
	# Externals are contextual to the story. Here, variables
	# 'forceful' & 'evasive' as well asfunction 'should_show_debug_menu'
	# only exists in The Intercept.
	if !bind_externals:
		return

	_ink_player.observe_variables(["forceful", "evasive"], self, "_observe_variables")
	_ink_player.bind_external_function("should_show_debug_menu", self, "_should_show_debug_menu")


func _evaluate_functions():
	## An example of how to evaluate functions. Both Crime Scene and
	## the Intercept declare thse dummy functions.
	var result = _ink_player.evaluate_function("test_function", [3, 4])
	print(
			"function 'test_function': [Text Output: '%s'] [Return Value: %s]" % \
			[result.text_output.replace("\n", "\\n"), result.return_value]
	)

	var result_output = _ink_player.evaluate_function("test_function_output", [3, 4, 5])
	print(
			"function 'test_function_output': [Text Output: '%s'] [Return Value: %s]" % \
			[result_output.text_output.replace("\n", "\\n"), result_output.return_value]
	)


func _remove_loading_overlay():
	remove_child(_loading_animation_player)
	_story_margin_container.show()
	_loading_animation_player.queue_free()
	_loading_animation_player = null


func _connect_signals():
	_ink_player.connect("loaded", self, "_loaded")


func _connect_optional_signals():
	_ink_player.connect("continued", self, "_continued")
	_ink_player.connect("prompt_choices", self, "_prompt_choices")
	_ink_player.connect("ended", self, "_ended")

	_ink_player.connect("exception_raised", self, "_exception_raised")
	_ink_player.connect("error_encountered", self, "_error_encountered")
