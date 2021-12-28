.. This class should be generated. But for now, it's written by hand.

.. _class_inkplayer:

InkPlayer
=========

**Inherits:** Node_

Description
-----------

A convenience node to run *inkgd*. Additional information on how to use it is
available in :doc:`../advanced/using_inkplayer`.

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
| bool_      | :ref:`do_not_save_default_values<class_inkplayer_do_not_save_default_values>`               | ``false`` |
+------------+---------------------------------------------------------------------------------------------+-----------+
| bool_      | :ref:`stop_execution_on_exception<class_inkplayer_stop_execution_on_exception>`             | ``false`` |
+------------+---------------------------------------------------------------------------------------------+-----------+
| bool_      | :ref:`stop_execution_on_error<class_inkplayer_stop_execution_on_error>`                     | ``false`` |
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

+---------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void                                              | :ref:`create_story<class_inkplayer_create_story>` **(** **)**                                                                                                        |
+---------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void                                              | :ref:`reset<class_inkplayer_reset>` **(** **)**                                                                                                                      |
+---------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void                                              | :ref:`destroy<class_inkplayer_destroy>` **(** **)**                                                                                                                  |
+---------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+


Story Flow
**********

+---------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| String_                                           | :ref:`continue_story<class_inkplayer_continue_story>`  **(** **)**                                                                                                   |
+---------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void                                              | :ref:`choose_choice_index<class_inkplayer_choose_choice_index>`  **(** int_ index **)**                                                                              |
+---------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void                                              | :ref:`choose_path_string<class_inkplayer_choose_path_string>`  **(** String_ path_string **)**                                                                       |
+---------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void                                              | :ref:`switch_flow<class_inkplayer_switch_flow>`  **(** String_ flow_name **)**                                                                                       |
+---------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void                                              | :ref:`switch_to_default_flow<class_inkplayer_switch_to_default_flow>`  **(** **)**                                                                                   |
+---------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void                                              | :ref:`remove_flow<class_inkplayer_remove_flow>`  **(** String_ flow_name **)**                                                                                       |
+---------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Array_                                            | :ref:`tags_for_content_at_path<class_inkplayer_tags_for_content_at_path>`  **(** String_ path **)**                                                                  |
+---------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| int_                                              | :ref:`visit_count_at_path_string<class_inkplayer_visit_count_at_path>`  **(** String_ path **)**                                                                     |
+---------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+


State Management
****************

+---------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| String_                                           | :ref:`get_state<class_inkplayer_get_state>` **(** **)**                                                                                                              |
+---------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void                                              | :ref:`set_state<class_inkplayer_set_state>` **(** String_ state **)**                                                                                                |
+---------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void                                              | :ref:`save_state_to_path<class_inkplayer_save_state_to_path>` **(** String_ path **)**                                                                               |
+---------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void                                              | :ref:`save_state_to_file<class_inkplayer_save_state_to_file>` **(** File_ file **)**                                                                                 |
+---------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void                                              | :ref:`load_state_from_path<class_inkplayer_load_state_from_path>` **(** String_ path **)**                                                                           |
+---------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void                                              | :ref:`load_state_from_file<class_inkplayer_load_state_from_file>` **(** File_ file **)**                                                                             |
+---------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+


Variables
*********

+---------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Variant_                                          | :ref:`get_variable<class_inkplayer_get_variable>` **(** String_ name **)**                                                                                           |
+---------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void                                              | :ref:`set_variable<class_inkplayer_set_variable>` **(** String_ name, Variant_ value **)**                                                                           |
+---------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void                                              | :ref:`observe_variables<class_inkplayer_observe_variables>` **(** Array_ variable_names, Object_ object, String_ method_name **)**                                   |
+---------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void                                              | :ref:`observe_variable<class_inkplayer_observe_variable>` **(** String_ variable_name, Object_ object, String_ method_name **)**                                     |
+---------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void                                              | :ref:`remove_variable_observer<class_inkplayer_remove_variable_observer>` **(** Object_ object, String_ method_name, String_ specific_variable_name **)**            |
+---------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void                                              | :ref:`remove_variable_observer_for_all_variable<class_inkplayer_remove_variable_observer_for_all_variable>` **(** Object_ object, String_ method_name **)**          |
+---------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void                                              | :ref:`remove_all_variable_observers<class_inkplayer_remove_all_variable_observers>` **(** String_ specific_variable_name **)**                                       |
+---------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+


Functions
*********

+---------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void                                              | :ref:`bind_external_function<class_inkplayer_bind_external_function>` **(** String_ func_name, Object_ object, String_ method_name, bool_ lookahead_safe=false **)** |
+---------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| void                                              | :ref:`unbind_external_function<class_inkplayer_unbind_external_function>` **(** String_ func_name **)**                                                              |
+---------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| :ref:`InkFunctionResult<class_inkfunctionresult>` | :ref:`evaluate_function<class_inkplayer_evaluate_function>` **(** String_ function_name, Array_ arguments **)**                                                      |
+---------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| :ref:`InkList<class_inklist>`                     | :ref:`create_ink_list_with_origin<class_inkplayer_create_ink_list_with_origin>` **(** String_ origin_list_name **)**                                                 |
+---------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| :ref:`InkList<class_inklist>`                     | :ref:`create_ink_list_from_item_name<class_inkplayer_create_ink_list_from_item_name>` **(** String_ item_name, **)**                                                 |
+---------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Signals
-------

.. _class_inkplayer_exception:

- **exception (** String_ message, PoolStringArray_ stack_trace **)**

Emitted when the Ink runtime encountered an exception. Exception are
usually not recoverable as they corrupt the state. ``stack_trace`` is
optional and contains each line of the stack trace leading to the
exception for logging purposes.

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

Emitted when the player should pick a choice. The choices are string values.

----

.. _class_inkplayer_choice_made:

- **choice_made (** String_ choice **)**

Emitted when a choice was reported back to the runtime.

----

.. _class_inkplayer_function_evaluating:

- **function_evaluating (** String_ function_name, Array_ arguments **)**

Emitted when an external function is about to evaluate.

----

.. _class_inkplayer_function_evaluated:

- **function_evaluated (** String_ function_name, Array_ arguments, :ref:`InkFunctionResult<class_inkfunctionresult>` function_result **)**

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

The compiled Ink file (.json) to play. While you can set this property to
any resource, it should be an instance of *InkResource*.

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
| *Default* | ``true``              |
+-----------+-----------------------+
| *Setter*  | set_aeff(value)       |
+-----------+-----------------------+
| *Getter*  | get_aeff()            |
+-----------+-----------------------+

``true`` to allow external function fallbacks, ``false`` otherwise. If this
property is ``false`` and the appropriate function hasn't been binded, the
story will output an error.

----

.. _class_inkplayer_do_not_save_default_values:

- bool_ **do_not_save_default_values**

+-----------+-----------------------+
| *Default* | ``true``              |
+-----------+-----------------------+
| *Setter*  | set_dnsdv(value)      |
+-----------+-----------------------+
| *Getter*  | get_dnsdv()           |
+-----------+-----------------------+

When set to ``true``, *inkgd* skips saving global values that remain
equal to the initial values that were declared in ink. This property matches
the static property declared in `VariablesState.cs`_.

----

.. _class_inkplayer_stop_execution_on_exception:

- bool_ **stop_execution_on_exception**

+-----------+-----------------------+
| *Default* | ``true``              |
+-----------+-----------------------+
| *Setter*  | set_speoex(value)     |
+-----------+-----------------------+
| *Getter*  | get_speoex()          |
+-----------+-----------------------+

When set to ``true``, *inkgd* uses ``assert()`` instead of ``push_error`` to
report exceptions, thus making them more explicit during development.

----

.. _class_inkplayer_stop_execution_on_error:

- bool_ **stop_execution_on_error**

+-----------+-----------------------+
| *Default* | ``true``              |
+-----------+-----------------------+
| *Setter*  | set_speoer(value)     |
+-----------+-----------------------+
| *Getter*  | get_speoer()          |
+-----------+-----------------------+

When set to ``true``, *inkgd* uses ``assert()`` instead of ``push_error`` to
report errors, thus making them more explicit during development.

----

.. _class_inkplayer_story:

- bool_ **story**

+-----------+-----------------------+
| *Default* | ``null``              |
+-----------+-----------------------+
| *Getter*  | get_can_story()       |
+-----------+-----------------------+

The underlying story, exposed for convenience. For instance, you may want
to create a new InkList, which in certain acses needs a reference to the
story to be constructed.

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

Reset the story back to its initial state as it was when it was
first constructed.

----

.. _class_inkplayer_destroy:

- void **destroy (** **)**

Destroys the current story. Always call this method first if you want to
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

- :ref:`InkFunctionResult<class_inkfunctionresult>` **evaluate_function (** String_ function_name, Array_ arguments **)**

Evaluate a given Ink function, returning both its return value and its text output.

----

.. _class_inkplayer_create_ink_list_with_origin:

- :ref:`InkList<class_inklist>` **create_ink_list_with_origin (** String_ origin_list_name, **)**

Creates a new empty InkList that's intended to hold items from a particular origin list definition.

----

.. _class_inkplayer_create_ink_list_from_item_name:

- :ref:`InkList<class_inklist>` **create_ink_list_from_item_name (** String_ item_name, **)**

Creates a new InkList from the name of a preexisting item.

----

.. _bool: https://docs.godotengine.org/en/stable/classes/class_bool.html
.. _int: https://docs.godotengine.org/en/stable/classes/class_int.html

.. _String: https://docs.godotengine.org/en/stable/classes/class_string.html
.. _Array: https://docs.godotengine.org/en/stable/classes/class_array.html
.. _Dictionary: https://docs.godotengine.org/en/stable/classes/class_dictionary.html
.. _PoolStringArray: https://docs.godotengine.org/en/stable/classes/class_poolstringarray.html

.. _Object: https://docs.godotengine.org/en/stable/classes/class_object.html

.. _File: https://docs.godotengine.org/en/stable/classes/class_file.html
.. _Variant: https://docs.godotengine.org/en/stable/classes/class_variant.html

.. _Node: https://docs.godotengine.org/en/stable/classes/class_node.html
.. _Resource:  https://docs.godotengine.org/en/stable/classes/class_resource.html

.. _`VariablesState.cs`: https://github.com/inkle/ink/blob/v1.0.0/ink-engine-runtime/VariablesState.cs
