# warning-ignore-all:return_value_discarded

extends _BASE_

# ############################################################################ #
# Imports
# ############################################################################ #

var InkPlayer = load("res://addons/inkgd/ink_player.gd")

# ############################################################################ #
# Public Nodes
# ############################################################################ #

# Alternatively, it could also be retrieved from the tree.
# onready var _ink_player = $InkPlayer
@onready var _ink_player = InkPlayer.new()

# ############################################################################ #
# Lifecycle
# ############################################################################ #

func _ready():
_TS_# Adds the player to the tree.
_TS_add_child(_ink_player)

_TS_# Replace the example path with the path to your story.
_TS_# Remove this line if you set 'ink_file' in the inspector.
_TS__ink_player.ink_file = load("res://path/to/file.ink.json")

_TS_# It's recommended to load the story in the background. On platforms that
_TS_# don't support threads, the value of this variable is ignored.
_TS__ink_player.loads_in_background = true

_TS__ink_player.connect("loaded", Callable(self, "_story_loaded"))

_TS_# Creates the story. 'loaded' will be emitted once Ink is ready
_TS_# continue the story.
_TS__ink_player.create_story()


# ############################################################################ #
# Signal Receivers
# ############################################################################ #

func _story_loaded(successfully: bool):
_TS_if !successfully:
_TS__TS_return

_TS_# _observe_variables()
_TS_# _bind_externals()

_TS__continue_story()


# ############################################################################ #
# Private Methods
# ############################################################################ #

func _continue_story():
_TS_while _ink_player.can_continue:
_TS__TS_var text = _ink_player.continue_story()
_TS__TS_# This text is a line of text from the ink story.
_TS__TS_# Set the text of a Label to this value to display it in your game.
_TS__TS_print(text)
_TS_if _ink_player.has_choices:
_TS__TS_# 'current_choices' contains a list of the choices, as strings.
_TS__TS_for choice in _ink_player.current_choices:
_TS__TS__TS_print(choice.text)
_TS__TS__TS_print(choice.tags)
_TS__TS_# '_select_choice' is a function that will take the index of
_TS__TS_# your selection and continue the story.
_TS__TS__select_choice(0)
_TS_else:
_TS__TS_# This code runs when the story reaches it's end.
_TS__TS_print("The End")


func _select_choice(index):
_TS__ink_player.choose_choice_index(index)
_TS__continue_story()


# Uncomment to bind an external function.
#
# func _bind_externals():
# _TS__ink_player.bind_external_function("<function_name>", self, "_external_function")
#
#
# func _external_function(arg1, arg2):
# _TS_pass


# Uncomment to observe the variables from your ink story.
# You can observe multiple variables by putting adding them in the array.
# func _observe_variables():
# _TS__ink_player.observe_variables(["var1", "var2"], self, "_variable_changed")
#
#
# func _variable_changed(variable_name, new_value):
# _TS_print("Variable '%s' changed to: %s" %[variable_name, new_value])
