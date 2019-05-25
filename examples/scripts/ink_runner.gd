# ############################################################################ #
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

extends Node

const SHOULD_LOAD_IN_BACKGROUND = true

# ############################################################################ #
# Imports
# ############################################################################ #

var InkRuntime = load("res://addons/inkgd/runtime.gd");
var Story = load("res://addons/inkgd/runtime/story.gd");

var ChoiceContainer = load("res://examples/scenes/choice_container.tscn");
var LineLabel = load("res://examples/scenes/label.tscn");

# ############################################################################ #
# Node
# ############################################################################ #

onready var StoryMarginContainer = get_node("StoryMarginContainer")
onready var StoryScrollContainer = StoryMarginContainer.get_node("StoryScrollContainer")
onready var StoryVBoxContainer = StoryScrollContainer.get_node("StoryVBoxContainer")
onready var LoadingAnimationPlayer = get_node("LoadingAnimationPlayer")

# ############################################################################ #
# Public Properties
# ############################################################################ #

var story

# ############################################################################ #
# Private Properties
# ############################################################################ #

var _current_choice_container
var _loading_thread

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

    if SHOULD_LOAD_IN_BACKGROUND:
        _loading_thread = Thread.new()
        _loading_thread.start(self, "_async_load_story", "res://examples/ink/the_intercept.ink.json")
    else:
        _load_story("res://examples/ink/the_intercept.ink.json")
        _bind_externals()
        continue_story()
        _remove_loading_overlay()

func continue_story():
    while story.can_continue:
        var text = story.continue()

        var label = LineLabel.instance()
        label.text = text

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
    _current_choice_container.queue_free()

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
    story.observe_variables(["forceful", "evasive"], self, "_observe_variables")
    story.bind_external_function("should_show_debug_menu", self, "_should_show_debug_menu")

func _async_load_completed():
    _loading_thread.wait_to_finish()
    _loading_thread = null

    _bind_externals()
    continue_story()
    _remove_loading_overlay()

func _remove_loading_overlay():
    remove_child(LoadingAnimationPlayer)
    StoryMarginContainer.show()
    LoadingAnimationPlayer.queue_free()
    LoadingAnimationPlayer = null

func _add_runtime():
    InkRuntime.init(get_tree().root)

func _remove_runtime():
    InkRuntime.deinit(get_tree().root)
