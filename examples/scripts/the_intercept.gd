# warning-ignore-all:return_value_discarded
# ############################################################################ #
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

extends Node

# ############################################################################ #
# Imports
# ############################################################################ #

var ChoiceContainer = load("res://examples/scenes/choice_container.tscn")
var LineLabel = load("res://examples/scenes/label.tscn")


# ############################################################################ #
# Constants
# ############################################################################ #

const USE_SIGNALS = false


# ############################################################################ #
# Private Properties
# ############################################################################ #

var _current_choice_container: ChoiceContainer


# ############################################################################ #
# Node
# ############################################################################ #

onready var _story_margin_container = $StoryMarginContainer
onready var _story_vbox_container = $StoryMarginContainer/StoryScrollContainer/StoryVBoxContainer
onready var _loading_animation_player = $LoadingAnimationPlayer
onready var _ink_player = $InkPlayer


# ############################################################################ #
# Lifecycle
# ############################################################################ #

func _ready():
	if USE_SIGNALS:
		_connect_optional_signals()

	_connect_signals()
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

	_bind_externals()
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

func _exception_raised(message):
	# This method gives a chance to react to a story-breaking exception.
	pass

# ############################################################################ #
# Private Methods
# ############################################################################ #

func _should_show_debug_menu(debug):
	# Contrived external function example, where
	# we just return the pre-existing value.
	print("_should_show_debug_menu called")
	return debug


func _observe_variables(variable_name, new_value):
	print("Variable '%s' changed to: %s" %[variable_name, new_value])


func _bind_externals():
	_ink_player.observe_variables(["forceful", "evasive"], self, "_observe_variables")
	_ink_player.bind_external_function("should_show_debug_menu", self, "_should_show_debug_menu")


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
