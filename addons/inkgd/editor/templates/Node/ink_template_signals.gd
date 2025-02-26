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
_TS__ink_player.connect("continued", Callable(self, "_continued"))
_TS__ink_player.connect("prompt_choices", Callable(self, "_prompt_choices"))
_TS__ink_player.connect("ended", Callable(self, "_ended"))

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

_TS_# Here, the story is started immediately, but it could be started
_TS_# at a later time.
_TS__ink_player.continue_story()


func _continued(text, tags):
_TS_print(text)
_TS_# Here you could yield for an hypothetical signal, before continuing.
_TS_# await self.event
_TS__ink_player.continue_story()


# ############################################################################ #
# Private Methods
# ############################################################################ #

func _prompt_choices(choices):
_TS_if !choices.is_empty():
_TS__TS_print(choices)

_TS__TS_# In a real world scenario, _select_choice' could be
_TS__TS_# connected to a signal, like 'Button.pressed'.
_TS__TS__select_choice(0)


func _ended():
_TS_print("The End")


func _select_choice(index):
_TS__ink_player.choose_choice_index(index)
_TS__ink_player.continue_story()


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
