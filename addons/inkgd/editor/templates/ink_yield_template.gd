# This version of the template uses yield and signals, so the story is always
# running, and after a line of text or when it reaches a choice, it waits for
# a signal. You may prefer this as a more modular version of the ink template.

extends %BASE%

const SHOULD_LOAD_IN_BACKGROUND = true

signal prompt_continue
signal prompt_choice_made(choice_index)

# ############################################################################ #
# Imports
# ############################################################################ #

var Story = load("res://addons/inkgd/runtime/story.gd")

# ############################################################################ #
# Public Properties
# ############################################################################ #

var story
export(String, FILE, "*.json") var exported_story_location

# ############################################################################ #
# Private Properties
# ############################################################################ #

var _loading_thread

# ############################################################################ #
# Lifecycle
# ############################################################################ #

func _ready():
	call_deferred("start_story")

# ############################################################################ #
# Public Methods
# ############################################################################ #

func start_story():
%TS%if SHOULD_LOAD_IN_BACKGROUND:
%TS%%TS%_loading_thread = Thread.new()
%TS%%TS%_loading_thread.start(self, "_async_load_story", exported_story_location)
%TS%else:
%TS%%TS%_load_story(exported_story_location)
%TS%%TS%_bind_externals()
%TS%%TS%run_story()

func run_story():

%TS%while story.can_continue:
%TS%%TS%var text = story.continue()
%TS%%TS%# The story will pause until the prompt signal is emmited.
%TS%%TS%yield(self, "prompt_continue")
%TS%%TS%if story.current_choices.size() > 0:
%TS%%TS%%TS%# current_choices contains a list of the choices.
%TS%%TS%%TS%# Each choice has a text property that contains the text of the choice.
%TS%%TS%%TS%for choice in story.current_choices:
%TS%%TS%%TS%	print(choice.text)
%TS%%TS%%TS%# However you make the choice, either through a button or another method, you
%TS%%TS%%TS%# can have this node emit the "prompt_choice_made" signal, with the index
%TS%%TS%%TS%# of the choice as the argument.
%TS%%TS%%TS%story.choose_choice_index(yield(self, "prompt_choice_made"))

%TS%#This code runs when the story reaches it's end.
%TS%print("The End")

# ############################################################################ #
# Private Methods
# ############################################################################ #

func _should_show_debug_menu(debug):
%TS%# Contrived external function example, where we just return the pre-existing value.
%TS%return debug

func _observe_variables(variable_name, new_value):
%TS%print(str("Variable '", variable_name, "' changed to: ", new_value))

func _async_load_story(ink_story_path):
%TS%_load_story(ink_story_path)
%TS%call_deferred("_async_load_completed")

func _load_story(ink_story_path):
%TS%var ink_story = File.new()
%TS%ink_story.open(ink_story_path, File.READ)
%TS%var content = ink_story.get_as_text()
%TS%ink_story.close()

%TS%self.story = Story.new(content)

func _bind_externals():
%TS%# Uncomment the line below to observe the variables from your ink story.
%TS%# You can observe multiple variables by putting them into the list as the first argument.
%TS%# story.observe_variables(["variable1", "variable2"], self, "_observe_variables")
%TS%story.bind_external_function("should_show_debug_menu", self, "_should_show_debug_menu")

func _async_load_completed():
%TS%_loading_thread.wait_to_finish()
%TS%_loading_thread = null

%TS%_bind_externals()
%TS%run_story()
