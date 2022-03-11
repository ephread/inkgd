Using InkPlayer
===============

InkPlayer is a custom node that greatly simplifies the use of **ink** in Godot.

``story.gd`` is a direct port of ``Story.cs``, to use it in any engine, a bit
of boilerplate code is necessary. InkPlayer takes care of that boilerplate
so you can focus on building your game.

While it's possible to instantiate ``story.gd`` directly, it's highly
recommended that you use InkPlayer instead.

In addition to reading this document, feel free to glance at
`the_intercept.tscn`_ and `the_intercept.gd`_, which use InkPlayer to run
*The Intercept*.

.. tip::

    InkPlayer's API documentation is available
    :doc:`here <../classes/class_inkplayer>`.


Main differences with *story.gd*
--------------------------------

1. InkPlayer takes a resource as its input, rather than a string containing
   the JSON bytecode.

2. It unifies Ink's original handlers and *inkgd* custom signals under
   a same set of consistent signals.

3. It adds convenience methods to save and load the story state.

4. It simplifies certain APIs, such as
   :ref:`evaluate_function<class_inkplayer_evaluate_function>`
   or
   :ref:`remove_variable_observer<class_inkplayer_remove_variable_observer>`.


Loop-based vs. signal-based flow
--------------------------------

InkPlayer can be used in two different ways. The examples below are
incomplete, for a working example, refer to `the_intercept.gd`_.

.. warning::

    The example below are not complete. For a working example, refer to
    `the_intercept.gd`_.


Loop-based
**********

This is the traditional way to use Ink.

.. code-block:: gdscript

    onready var _ink_player = $InkPlayer


    func _ready():
        _ink_player.connect("loaded", self, "_story_loaded")
        _ink_player.create_story()


    func _story_loaded(successfully: bool):
        if !successfully:
            return

        _continue_story()


    func _continue_story():
        while _ink_player.can_continue:
            var text = _ink_player.continue_story()

            # This text is a line of text from the ink story.
            # Set the text of a Label to this value to display it in your game.
            print(text)

        if _ink_player.has_choices:
            # 'current_choices' contains a list of the choices, as strings.
            for choice in _ink_player.current_choices:
                print(choice)

            # '_select_choice' is a function that will take the index of
            # your selection and continue the story by calling again
            # `_continue_story()`.
            _select_choice(0)

        else:
            # This code runs when the story reaches it's end.
            print("The End")


Signal-based
************

Using signals makes the code a little bit more idiomatic for Godot. It's also
more flexible.

.. code-block:: gdscript

    onready var _ink_player = $InkPlayer


    func _ready():
        _ink_player.connect("loaded", self, "_story_loaded")
        _ink_player.connect("continued", self, "_continued")
        _ink_player.connect("prompt_choices", self, "_prompt_choices")
        _ink_player.connect("ended", self, "_ended")

        _ink_player.create_story()


    func _story_loaded(successfully: bool):
        if !successfully:
            return

        _ink_player.continue_story()


    func _continued(text, tags):
        print(text)
        _ink_player.continue_story()


    func _prompt_choices(choices):
        if !choices.empty():
            print(choices)

            # In a real world scenario, _select_choice' could be
            # connected to a signal, like 'Button.pressed'.
            _select_choice(0)


    func _ended():
        print("The End")


    func _select_choice(index):
        _ink_player.choose_choice_index(index)
        _continue_story()


Loading the story from a background thread
------------------------------------------

For bigger stories, loading the compiled story into the runtime can take a
long time (more than a second). To avoid blocking the main thread, you may
want to load the story from a background thread and display a loading indicator.

Fortunately, ``InkPlayer`` supports loading the story in a thread out of the
box. Either tick *Loads In Background* in the inspector or set
:ref:`loads_in_background<class_inkplayer_loads_in_background>` to ``true``
in code.

.. image:: img/ink_runner_threads.png
    :align: center
    :alt: Inspector panel showing an InkRunner node and pointing to "Loads in
          Background".
    :scale: 50 %

|

On platforms that don't support threads, the feature is automatically disabled
regardles of the value of
:ref:`loads_in_background<class_inkplayer_loads_in_background>`.

.. _`the_intercept.tscn`: https://github.com/ephread/inkgd/blob/main/examples/scenes/the_intercept.tscn
.. _`the_intercept.gd`: https://github.com/ephread/inkgd/blob/main/examples/scenes/the_intercept.gd
