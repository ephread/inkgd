# This version of the template uses a while loop to have the code continue
# the story until it reaches the choice point. It then checks for choices and,
# on getting a choice, recursively calls the continue_story function to continue
# the story.

extends %BASE%

const SHOULD_LOAD_IN_BACKGROUND = true

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
%TS%call_deferred("start_story")

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
%TS%%TS%continue_story()


func continue_story():
%TS%while story.can_continue:
%TS%%TS%var text = story.continue()
%TS%%TS%# This text is a line of text from the ink story.
%TS%%TS%# Set the text of a Label to this value to display it in your game.
%TS%%TS%print(text)
%TS%if story.current_choices.size() > 0:
%TS%%TS%# current_choices contains a list of the choices.
%TS%%TS%# Each choice has a text property that contains the text of the choice.

%TS%%TS%for choice in story.current_choices:
%TS%%TS%%TS%print(choice.text)
%TS%
%TS%%TS%# _choice_selected is a function that will take the index of your selection
%TS%%TS%# and continue the story.

%TS%%TS%_choice_selected(0)
%TS%else:
%TS%%TS%# This code runs when the story reaches it's end.
%TS%
%TS%%TS%print("The End")

# ############################################################################ #
# Private Methods
# ############################################################################ #

func _should_show_debug_menu(debug):
%TS%# Contrived external function example, where we just return the pre-existing value.
%TS%return debug

func _observe_variables(variable_name, new_value):
%TS%print(str("Variable '", variable_name, "' changed to: ", new_value))

func _choice_selected(index):
%TS%story.choose_choice_index(index)
%TS%continue_story()

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
%TS%continue_story()
