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
%TS%_ink_player.connect("continued", self, "_continued")
%TS%_ink_player.connect("prompt_choices", self, "_prompt_choices")
%TS%_ink_player.connect("ended", self, "_ended")

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

%TS%# Here, the story is started immediately, but it could be started
%TS%# at a later time.
%TS%_ink_player.continue_story()


func _continued(text, tags):
%TS%print(text)
%TS%# Here you could yield for an hypothetical signal, before continuing.
%TS%# yield(self, "event")
%TS%_ink_player.continue_story()


# ############################################################################ #
# Private Methods
# ############################################################################ #

func _prompt_choices(choices):
%TS%if !choices.empty():
%TS%%TS%print(choices)

%TS%%TS%# In a real world scenario, _select_choice' could be
%TS%%TS%# connected to a signal, like 'Button.pressed'.
%TS%%TS%_select_choice(0)


func _ended():
%TS%print("The End")


func _select_choice(index):
%TS%_ink_player.choose_choice_index(index)
%TS%_ink_player.continue_story()


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
