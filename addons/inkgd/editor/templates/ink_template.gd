# warning-ignore-all:return_value_discarded

extends %BASE%

# ############################################################################ #
# Imports
# ############################################################################ #

var InkPlayer = load("res://addons/inkgd/ink_player.gd")

# ############################################################################ #
# Public Nodes
# ############################################################################ #

# Alternatively, it could also be retrieved from the tree.
# onready var _ink_player = $InkPlayer
onready var _ink_player = InkPlayer.new()

# ############################################################################ #
# Lifecycle
# ############################################################################ #

func _ready():
%TS%# Adds the player to the tree.
%TS%add_child(_ink_player)

%TS%# Replace the example path with the path to your story.
%TS%# Remove this line if you set 'ink_file' in the inspector.
%TS%_ink_player.ink_file = load("res://path/to/file.ink.json")

%TS%# It's recommended to load the story in the background. On platforms that
%TS%# don't support threads, the value of this variable is ignored.
%TS%_ink_player.loads_in_background = true

%TS%_ink_player.connect("loaded", self, "_story_loaded")

%TS%# Creates the story. 'loaded' will be emitted once Ink is ready
%TS%# continue the story.
%TS%_ink_player.create_story()


# ############################################################################ #
# Signal Receivers
# ############################################################################ #

func _story_loaded(successfully: bool):
%TS%if !successfully:
%TS%%TS%return

%TS%# _observe_variables()
%TS%# _bind_externals()

%TS%_continue_story()


# ############################################################################ #
# Private Methods
# ############################################################################ #

func _continue_story():
%TS%while _ink_player.can_continue:
%TS%%TS%var text = _ink_player.continue_story()
%TS%%TS%# This text is a line of text from the ink story.
%TS%%TS%# Set the text of a Label to this value to display it in your game.
%TS%%TS%print(text)
%TS%if _ink_player.has_choices:
%TS%%TS%# 'current_choices' contains a list of the choices, as strings.
%TS%%TS%for choice in _ink_player.current_choices:
%TS%%TS%%TS%print(choice)
%TS%%TS%# '_select_choice' is a function that will take the index of
%TS%%TS%# your selection and continue the story.
%TS%%TS%_select_choice(0)
%TS%else:
%TS%%TS%# This code runs when the story reaches it's end.
%TS%%TS%print("The End")


func _select_choice(index):
%TS%_ink_player.choose_choice_index(index)
%TS%_continue_story()


# Uncomment to bind an external function.
#
# func _bind_externals():
# %TS%_ink_player.bind_external_function("<function_name>", self, "_external_function")
#
#
# func _external_function(arg1, arg2):
# %TS%pass


# Uncomment to observe the variables from your ink story.
# You can observe multiple variables by putting adding them in the array.
# func _observe_variables():
# %TS%_ink_player.observe_variables(["var1", "var2"], self, "_variable_changed")
#
#
# func _variable_changed(variable_name, new_value):
# %TS%print("Variable '%s' changed to: %s" %[variable_name, new_value])
