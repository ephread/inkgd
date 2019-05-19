# ############################################################################ #
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

extends Node

# ############################################################################ #
# Imports
# ############################################################################ #

var InkRuntime = load("res://addons/inkgd/runtime.gd");
var Story = load("res://addons/inkgd/runtime/story.gd");

var ChoiceContainer = load("res://examples/choice_container.tscn");

# ############################################################################ #
# Node
# ############################################################################ #

onready var StoryVBoxContainer = get_node("MarginContainer/StoryScrollContainer/StoryVBoxContainer")

# ############################################################################ #
# Public Properties
# ############################################################################ #

var story

# ############################################################################ #
# Private Properties
# ############################################################################ #

var _current_choice_container

# ############################################################################ #
# Lifecycle
# ############################################################################ #

func _ready():
    call_deferred("start_story")

func _exit_tree():
    call_deferred("_remove_runtime")

# ############################################################################ #
# Public Methods
# ############################################################################ #

func start_story():
    _add_runtime()
    _load_story("res://examples/ink/the_intercept.ink.json")

    story.observe_variables(["forceful", "evasive"], self, "_observe_variables")
    story.bind_external_function("should_show_debug_menu", self, "_should_show_debug_menu")

    self.continue_story()

func continue_story():
    while story.can_continue:
        var text = story.continue()

        var label = Label.new()
        label.text = text
        label.align = Label.ALIGN_CENTER

        StoryVBoxContainer.add_child(label)

    if story.current_choices.size() > 0:
        _current_choice_container = ChoiceContainer.instance()
        StoryVBoxContainer.add_child(_current_choice_container)

        _current_choice_container.create_choices(story.current_choices)
        _current_choice_container.connect("choice_selected", self, "_choice_selected")
    else:
        # End of story: let's check whether you took the cup of tea.
        var teacup = story.variables_state.get("teacup")

        if teacup:
            print("Took the tea.")
        else:
            print("Didn't take the tea.")

# ############################################################################ #
# Private Methods
# ############################################################################ #

func _should_show_debug_menu(debug):
    # Contrived external function example, where we just return the pre-existing value.
    return debug

func _observe_variables(variable_name, new_value):
    print(str("Variable '", variable_name, "' changed to: ", new_value))

func _choice_selected(index):
    StoryVBoxContainer.remove_child(_current_choice_container)
    story.choose_choice_index(index)
    continue_story()

func _load_story(ink_story_path):
    var ink_story = File.new()
    ink_story.open(ink_story_path, File.READ)
    var content = ink_story.get_as_text()
    ink_story.close()

    self.story = Story.new(content)

func _add_runtime():
    InkRuntime.init(get_tree().root)

func _remove_runtime():
    InkRuntime.deinit(get_tree().root)
