# ############################################################################ #
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

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
	call_deferred("start_story")

# ############################################################################ #
# Public Methods
# ############################################################################ #

func start_story():
	if SHOULD_LOAD_IN_BACKGROUND:
		_loading_thread = Thread.new()
		_loading_thread.start(self, "_async_load_story", exported_story_location)
	else:
		_load_story(exported_story_location)
		_bind_externals()
		continue_story()


func continue_story():
	while story.can_continue:
		var text = story.continue()
		# This text is a line of text from the ink story.
		# Set the text of a Label to this value to display it in your game.
		print(text)
	if story.current_choices.size() > 0:
		# current_choices contains a list of the choices.
		# Each choice has a text property that contains the text of the choice.

		for choice in story.current_choices:
			print(choice.text)

		# _choice_selected is a function that will take the index of your selection
		# and continue the story.

		_choice_selected(0)
	else:
		# This code runs when the story reaches it's end.

		print("The End")

# ############################################################################ #
# Private Methods
# ############################################################################ #

func _should_show_debug_menu(debug):
	# Contrived external function example, where we just return the pre-existing value.
	return debug

func _observe_variables(variable_name, new_value):
	print(str("Variable '", variable_name, "' changed to: ", new_value))

func _choice_selected(index):
	story.choose_choice_index(index)
	continue_story()

func _async_load_story(ink_story_path):
	_load_story(ink_story_path)
	call_deferred("_async_load_completed")

func _load_story(ink_story_path):
	var ink_story = File.new()
	ink_story.open(ink_story_path, File.READ)
	var content = ink_story.get_as_text()
	ink_story.close()

	self.story = Story.new(content)

func _bind_externals():
	# Uncomment the line below to observe the variables from your ink story.
	# You can observe multiple variables by putting them into the list as the first argument.
	# story.observe_variables(["variable1", "variable2"], self, "_observe_variables")
	story.bind_external_function("should_show_debug_menu", self, "_should_show_debug_menu")

func _async_load_completed():
	_loading_thread.wait_to_finish()
	_loading_thread = null

	_bind_externals()
	continue_story()

