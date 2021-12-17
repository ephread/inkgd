.. Ideally, this class should be generated. But for now, it's written by hand.

InkPlayer
=========

**Inherits:** Node_

A convenience node to run *inkgd*.

Description
-----------

Activating the editor plugin will register a custom node that greatly simplifies
the use of Ink in Godot. While it's possible to instantiate ``story.gd``
directly, it's highly recommended that you use InkPlayer instead.

``story.gd`` is a direct port of ``Story.cs``, to use it in any engine, a bit
of boilerplate code is necessary. InkPlayer takes care of that boilerplate
so you can focus on building your game.

``the_intercept.tscn`` and ``the_intercept.gd`` contain a real world example of
how InkPlayer can be used. They are found in the `example directory`_.

Main differences between *InkPlayer* and *story.gd*
***************************************************

1. The node takes a resource as its input, rather than a string containing
   the JSON bytecode.

2. The node unifies Ink's original handlers and *inkgd* custom signals under
   a same set of consistent signals.

3. The node adds convenience methods to save and load the story state.

4. The node simplifies certain APIs.

5. Finally, the node can easily be added to a scene!

Loop-based vs. signal-based flow
********************************

InkPlayer can be used in two different ways. The example below are
incomplete and assume the story is already loaded. For a working example,
take a look at ``the_intercept.gd`` in the `example directory`_.

Loop-based
''''''''''

This is the traditional way, recommended by the creator of Ink.

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
''''''''''''

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
******************************************

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

.. _`example directory`: https://github.com/ephread/inkgd/tree/main/examples


Properties
----------

Read/Write Properties
*********************

+------------+---------------------------------------------------------------------------------------------+-----------+
| Resource_  | :ref:`ink_player<class_inkplayer_ink_file>`                                                 |           |
+------------+---------------------------------------------------------------------------------------------+-----------+
| bool_      | :ref:`loads_in_background<class_inkplayer_loads_in_background>`                             | ``true``  |
+------------+---------------------------------------------------------------------------------------------+-----------+
| bool_      | :ref:`allow_external_function_fallbacks<class_inkplayer_allow_external_function_fallbacks>` | ``false`` |
+------------+---------------------------------------------------------------------------------------------+-----------+


Read Only Properties
********************

+------------+---------------------------------------------------------------------------------------------+-----------+
| bool_      | :ref:`can_continue<class_inkplayer_can_continue>`                                           | ``false`` |
+------------+---------------------------------------------------------------------------------------------+-----------+
| String_    | :ref:`current_text<class_inkplayer_current_text>`                                           |  ``""``   |
+------------+---------------------------------------------------------------------------------------------+-----------+
| Array_     | :ref:`current_choices<class_inkplayer_current_choices>`                                     |  ``[]``   |
+------------+---------------------------------------------------------------------------------------------+-----------+
| Array_     | :ref:`current_tags<class_inkplayer_current_tags>`                                           |  ``[]``   |
+------------+---------------------------------------------------------------------------------------------+-----------+
| Array_     | :ref:`global_tags<class_inkplayer_global_tags>`                                             |  ``[]``   |
+------------+---------------------------------------------------------------------------------------------+-----------+
| bool_      | :ref:`has_choices<class_inkplayer_has_choices>`                                             | ``false`` |
+------------+---------------------------------------------------------------------------------------------+-----------+


Methods
-------

Story Creation
**************

+-------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void        | :ref:`create_story<class_inkplayer_create_story>` **(** **)**                                                                                                        |
+-------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void        | :ref:`reset<class_inkplayer_reset>` **(** **)**                                                                                                                      |
+-------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+


Story Flow
**********

+-------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| String_     | :ref:`continue_story<class_inkplayer_continue_story>`  **(** **)**                                                                                                   |
+-------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void        | :ref:`choose_choice_index<class_inkplayer_choose_choice_index>`  **(** int_ index **)**                                                                              |
+-------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void        | :ref:`choose_path_string<class_inkplayer_choose_path_string>`  **(** String_ path_string **)**                                                                       |
+-------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void        | :ref:`switch_flow<class_inkplayer_switch_flow>`  **(** String_ flow_name **)**                                                                                       |
+-------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void        | :ref:`switch_to_default_flow<class_inkplayer_switch_to_default_flow>`  **(** **)**                                                                                   |
+-------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void        | :ref:`remove_flow<class_inkplayer_remove_flow>`  **(** String_ flow_name **)**                                                                                       |
+-------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Array_      | :ref:`tags_for_content_at_path<class_inkplayer_tags_for_content_at_path>`  **(** String_ path **)**                                                                  |
+-------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| int_        | :ref:`visit_count_at_path_string<class_inkplayer_visit_count_at_path>`  **(** String_ path **)**                                                                     |
+-------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+


State Management
****************

+-------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| String_     | :ref:`get_state<class_inkplayer_get_state>` **(** **)**                                                                                                              |
+-------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void        | :ref:`set_state<class_inkplayer_set_state>` **(** String_ state **)**                                                                                                |
+-------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void        | :ref:`save_state_to_path<class_inkplayer_save_state_to_path>` **(** String_ path **)**                                                                               |
+-------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void        | :ref:`save_state_to_file<class_inkplayer_save_state_to_file>` **(** File_ file **)**                                                                                 |
+-------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void        | :ref:`load_state_from_path<class_inkplayer_load_state_from_path>` **(** String_ path **)**                                                                           |
+-------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void        | :ref:`load_state_from_file<class_inkplayer_load_state_from_file>` **(** File_ file **)**                                                                             |
+-------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+


Variables
*********

+-------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Variant_    | :ref:`get_variable<class_inkplayer_get_variable>` **(** String_ name **)**                                                                                           |
+-------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void        | :ref:`set_variable<class_inkplayer_set_variable>` **(** String_ name, Variant_ value **)**                                                                           |
+-------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void        | :ref:`observe_variables<class_inkplayer_observe_variables>` **(** Array_ variable_names, Object_ object, String_ method_name **)**                                   |
+-------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void        | :ref:`observe_variable<class_inkplayer_observe_variable>` **(** String_ variable_name, Object_ object, String_ method_name **)**                                     |
+-------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void        | :ref:`remove_variable_observer<class_inkplayer_remove_variable_observer>` **(** Object_ object, String_ method_name, String_ specific_variable_name **)**            |
+-------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void        | :ref:`remove_variable_observer_for_all_variable<class_inkplayer_remove_variable_observer_for_all_variable>` **(** Object_ object, String_ method_name **)**          |
+-------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void        | :ref:`remove_all_variable_observers<class_inkplayer_remove_all_variable_observers>` **(** String_ specific_variable_name **)**                                       |
+-------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+


Functions
*********

+-------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void        | :ref:`bind_external_function<class_inkplayer_bind_external_function>` **(** String_ func_name, Object_ object, String_ method_name, bool_ lookahead_safe=false **)** |
+-------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void        | :ref:`unbind_external_function<class_inkplayer_unbind_external_function>` **(** String_ func_name **)**                                                              |
+-------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void        | :ref:`evaluate_function<class_inkplayer_evaluate_function>` **(** String_ function_name, Array_ arguments **)**                                                      |
+-------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Dictionary_ | :ref:`evaluate_function_and_get_output<class_inkplayer_evaluate_function_and_get_output>` **(** String_ function_name, Array_ arguments **)**                        |
+-------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+


Signals
-------

.. _class_inkplayer_exception:

- **exception (** String_ message **)**

Emitted when the Ink runtime encountered an exception. Exception are
usually not recoverable as they corrupt the state.

----

.. _class_inkplayer_story_error:

- **story_error (** String_ message, int_ type **)**

Emitted when the story encountered an error. These errors are usually
recoverable.

----

.. _class_inkplayer_loaded:

- **loaded (** bool_ successfully **)**

Emitted with ``true`` when the runtime had loaded the JSON content and
created the story. If an error was encountered, ``successfully`` will be
``false`` and error will appear in Godot's output.

----

.. _class_inkplayer_continued:

- **continued (** String_ text, Array_ tags **)**

Emitted with the text and tags of the current line when the story
successfully continued.

----

.. _class_inkplayer_prompt_choices:

- **prompt_choices (** Array_ choices **)**

Emitted when the player should pick a choice.

----

.. _class_inkplayer_choice_made:

- **choice_made (** Array_ choice **)**

Emitted when a choice was reported back to the runtime.

----

.. _class_inkplayer_function_evaluating:

- **function_evaluating (** String_ function_name, Array_ arguments **)**

Emitted when an external function is about to evaluate.

----

.. _class_inkplayer_function_evaluated:

- **function_evaluated (** String_ function_name, Array_ arguments, String_ text_output, Variant_ result **)**

Emitted when an external function evaluated.

----

.. _class_inkplayer_path_string_choosen:

- **path_string_choosen (** String_ path, Array_ arguments **)**

Emitted when an external function evaluated.

----

.. _class_inkplayer_ended:

- **ended (** **)**

Emitted when the story ended.


Property Descriptions
---------------------

.. _class_inkplayer_ink_file:

- Resource_ **ink_file**

The compiled Ink file (.json) to play.

----

.. _class_inkplayer_loads_in_background:

- bool_ **loads_in_background**

+-----------+-----------------------+
| *Default* | ``true``              |
+-----------+-----------------------+

When ``true`` the story will be created in a separate threads, to prevent the UI
from freezing if the story is too big. Note that on platforms where threads
aren't available, the value of this property is ignored.

----

.. _class_inkplayer_allow_external_function_fallbacks:

- bool_ **allow_external_function_fallbacks**

+-----------+-----------------------+
| *Default* | ``false``             |
+-----------+-----------------------+
| *Setter*  | set_aeff(value)       |
+-----------+-----------------------+
| *Getter*  | get_aeff()            |
+-----------+-----------------------+

``true`` to allow external function fallbacks, ``false`` otherwise. If this
property is ``false`` and the appropriate function hasn't been binded, the story
will output an error.

----

.. _class_inkplayer_can_continue:

- bool_ **can_continue**

+-----------+-----------------------+
| *Default* | ``false``             |
+-----------+-----------------------+
| *Getter*  | get_can_continue()    |
+-----------+-----------------------+

``true`` if the story can continue (i. e. is not expecting a choice to be
choosen and hasn't reached the end).

----

.. _class_inkplayer_current_text:

- String_ **current_text**

+-----------+-----------------------+
| *Default* | ``""``                |
+-----------+-----------------------+
| *Getter*  | get_current_text()    |
+-----------+-----------------------+

The content of the current line.

----

.. _class_inkplayer_current_choices:

- Array_ **current_choices**

+-----------+-----------------------+
| *Default* | ``""``                |
+-----------+-----------------------+
| *Getter*  | get_current_choices() |
+-----------+-----------------------+

The current choices. Empty is there are no choices for the current line.

----

.. _class_inkplayer_current_tags:

- Array_ **current_tags**

+-----------+-----------------------+
| *Default* | ``[]``                |
+-----------+-----------------------+
| *Getter*  | get_current_tags()    |
+-----------+-----------------------+

The current tags. Empty is there are no tags for the current line.

----

.. _class_inkplayer_global_tags:

- Array_ **global_tags**

+-----------+-----------------------+
| *Default* | ``[]``                |
+-----------+-----------------------+
| *Getter*  | get_global_tags()     |
+-----------+-----------------------+

The global tags for the story. Empty if none have been declared.

----

.. _class_inkplayer_has_choices:

- bool_ **has_choices**

+-----------+-----------------------+
| *Default* | ``false``             |
+-----------+-----------------------+

``true`` if the story currently has choices, ``false`` otherwise.

Method Descriptions
-------------------

.. _class_inkplayer_create_story:

- void **create_story (** **)**

Creates the story, based on the value of
:ref:`ink_player<class_inkplayer_ink_file>`. The result of this method is
reported through :ref:`loaded<class_inkplayer_loaded>`.

----

.. _class_inkplayer_reset:

- void **reset (** **)**

Destroys the current story. ALways call this method first if you want to
recreate the story.

----

.. _class_inkplayer_continue_story:

- String_ **continue_story (** **)**

Continues the story.

----

.. _class_inkplayer_choose_choice_index:

- void **choose_choice_index (** int_ index **)**

Chooses a choice. If the story is not currently expected choices or the index is
out of bounds, this method does nothing.

----

.. _class_inkplayer_choose_path_string:

- void **choose_path_string (** String_ path_string **)**

Moves the story to the specified knot/stitch/gather. This method will throw an
error through :ref:`exception<class_inkplayer_exception>` if the path string
does not match any known path.

----

.. _class_inkplayer_switch_flow:

- void **switch_flow (** String_ flow_name **)**

Switches the flow, creating a new flow if it doesn't exist.

----

.. _class_inkplayer_switch_to_default_flow:

- void **switch_to_default_flow (** **)**

Switches the the default flow.

----

.. _class_inkplayer_remove_flow:

- void **remove_flow (** String_ flow_name **)**

Remove the given flow.

----

.. _class_inkplayer_tags_for_content_at_path:

- Array_ **tags_for_content_at_path (** String_ path **)**

Returns the tags declared at the given path.

----

.. _class_inkplayer_visit_count_at_path:

- int_ **visit_count_at_path (** String_ path **)**

Returns the visit count of the given path.

----

.. _class_inkplayer_get_state:

- String_ **get_state (** **)**

Gets the current state as a JSON string. It can then be saved somewhere.

----

.. _class_inkplayer_set_state:

- void **set_state (** String_ state **)**

Sets the state from a JSON string.

----

.. _class_inkplayer_save_state_to_path:

- void **save_state_to_path (** String_ path **)**

Saves the current state to the given path.

----

.. _class_inkplayer_save_state_to_file:

- void **save_state_to_file (** File_ file **)**

Saves the current state to the file.

----

.. _class_inkplayer_load_state_from_path:

- void **load_state_from_path (** String_ path **)**

Loads the state from the given path.

----

.. _class_inkplayer_load_state_from_file:

- void **load_state_from_file (** File_ file **)**

Loads the state from the given file.

----

.. _class_inkplayer_get_variable:

- Variant **get_variable (** String_ name **)**

Returns the value of variable named 'name' or 'null' if it doesn't exist.

----

.. _class_inkplayer_set_variable:

- void **set_variable (** String_ name, Variant_ value **)**

Sets the value of variable named 'name'.

----

.. _class_inkplayer_observe_variables:

- void **observe_variables (** Array_ variable_names, Object_ object, String_ method_name **)**

Registers an observer for the given variables.

----

.. _class_inkplayer_observe_variable:

- void **observe_variable (** String_ variable_name, Object_ object, String_ method_name **)**

Registers an observer for the given variable.

----

.. _class_inkplayer_remove_variable_observer:

- void **remove_variable_observer (** Object_ object, String_ method_name, String_ specific_variable_name **)**

Removes an observer for the given variable name. This method is highly specific
and will only remove one observer.

----

.. _class_inkplayer_remove_variable_observer_for_all_variable:

- void **remove_variable_observer_for_all_variable (** Object_ object, String_ method_name **)**

Removes all observers registered with the couple object/method_name,
regardless of which variable they observed.

----

.. _class_inkplayer_remove_all_variable_observers:

- void **remove_all_variable_observers (** String_ specific_variable_name **)**

Removes all observers observing the given variable.

----

.. _class_inkplayer_bind_external_function:

- void **bind_external_function (** String_ func_name, Object_ object, String_ method_name, bool_ lookahead_safe=false **)**

Binds an external function.

----

.. _class_inkplayer_unbind_external_function:

- void **unbind_external_function (** String_ func_name **)**

Unbinds an external function.

----

.. _class_inkplayer_evaluate_function:

- void **evaluate_function (** String_ function_name, Array_ arguments **)**

Evaluate a given Ink function, returning its return value (but not its output).

----

.. _class_inkplayer_evaluate_function_and_get_output:

- Dictionary_ **evaluate_function_and_get_output (** String_ function_name, Array_ arguments **)**

Evaluate a given Ink function, returning both its return value and text output
in a dictionary of the form:

.. code-block:: json

    {
        "result": "<return_value>",
        "output": "<text_output>"
    }

.. _bool: https://docs.godotengine.org/en/stable/classes/class_bool.html
.. _int: https://docs.godotengine.org/en/stable/classes/class_int.html

.. _String: https://docs.godotengine.org/en/stable/classes/class_string.html
.. _Array: https://docs.godotengine.org/en/stable/classes/class_array.html
.. _Dictionary: https://docs.godotengine.org/en/stable/classes/class_dictionary.html

.. _Object: https://docs.godotengine.org/en/stable/classes/class_object.html

.. _File: https://docs.godotengine.org/en/stable/classes/class_file.html
.. _Variant: https://docs.godotengine.org/en/stable/classes/class_variant.html

.. _Node: https://docs.godotengine.org/en/stable/classes/class_node.html
.. _Resource:  https://docs.godotengine.org/en/stable/classes/class_resource.html
