# ############################################################################ #
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

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
	if SHOULD_LOAD_IN_BACKGROUND:
		_loading_thread = Thread.new()
		_loading_thread.start(self, "_async_load_story", exported_story_location)
	else:
		_load_story(exported_story_location)
		_bind_externals()
		run_story()

func run_story():
	
	while story.can_continue:
		var text = story.continue()
		# The story will pause until the prompt signal is emmited.  
		yield(self, "prompt_continue")
		if story.current_choices.size() > 0:
			# current_choices contains a list of the choices.
			# Each choice has a text property that contains the text of the choice.
			for choice in story.current_choices:
				print(choice.text)
			# However you make the choice, either through a button or another method, you 
			# can have this node emit the "prompt_choice_made" signal, with the index
			# of the choice as the argument. 
			story.choose_choice_index(yield(self, "prompt_choice_made"))
	
	#This code runs when the story reaches it's end. 
	print("The End")

# ############################################################################ #
# Private Methods
# ############################################################################ #

func _should_show_debug_menu(debug):
	# Contrived external function example, where we just return the pre-existing value.
	return debug

func _observe_variables(variable_name, new_value):
	print(str("Variable '", variable_name, "' changed to: ", new_value))

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
	# Uncomment the below line to observe the variables from your ink story.
	# You can observe multiple variables by putting them into the list as the first argument.
	# story.observe_variables(["variable1", "variable2"], self, "_observe_variables")
	story.bind_external_function("should_show_debug_menu", self, "_should_show_debug_menu")

func _async_load_completed():
	_loading_thread.wait_to_finish()
	_loading_thread = null

	_bind_externals()
	run_story()

