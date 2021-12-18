.. This class should be generated. But for now, it's written by hand.

.. _class_inkruntime:

InkRuntime
==========

**Inherits:** Node_


Description
-----------

A node encapsulating static properties of the runtime and managing
exceptions.


Properties
----------

+-------+--------------------------------------------------------------------------------------------------+----------+
| bool_ | :ref:`should_pause_execution_on_exception<class_inkruntime_should_pause_execution_on_exception>` | ``true`` |
+-------+--------------------------------------------------------------------------------------------------+----------+
| bool_ | :ref:`should_pause_execution_on_error<class_inkruntime_should_pause_execution_on_error>`         | ``true`` |
+-------+--------------------------------------------------------------------------------------------------+----------+
| bool_ | :ref:`dont_save_default_values<class_inkruntime_dont_save_default_values>`                       | ``true`` |
+-------+--------------------------------------------------------------------------------------------------+----------+


Signals
-------

.. _class_inkruntime_exception_raised:

- **exception_raised (** String_ message, PoolStringArray_ stack_trace **)**

Emitted when the runtime encounters an exception. Exceptions are not recoverable
and may corrupt the state. They are the consequence of either a programmer error
or a bug in the runtime.


Property Descriptions
---------------------

.. _class_inkruntime_should_pause_execution_on_exception:

- bool_ **should_pause_execution_on_exception**

+-----------+----------+
| *Default* | ``true`` |
+-----------+----------+

When set to ``true``, *inkgd* uses ``assert()`` instead of ``push_error`` to
report exceptions, thus making them more explicit during development.

----

.. _class_inkruntime_should_pause_execution_on_error:

- bool_ **should_pause_execution_on_error**

+-----------+----------+
| *Default* | ``true`` |
+-----------+----------+

When set to ``true``, *inkgd* uses ``assert()`` instead of ``push_error`` to
report errors, thus making them more explicit during development.

----

.. _class_inkruntime_dont_save_default_values:

- bool_ **dont_save_default_values**

+-----------+----------+
| *Default* | ``true`` |
+-----------+----------+

When set to ``true``, *inkgd* skips saving global values that remain
equal to the initial values that were declared in ink. This property matches
the static property declared in `VariablesState.cs`_.

.. _`VariablesState.cs`: https://github.com/inkle/ink/blob/v1.0.0/ink-engine-runtime/VariablesState.cs

.. _bool: https://docs.godotengine.org/en/stable/classes/class_bool.html

.. _String: https://docs.godotengine.org/en/stable/classes/class_string.html
.. _PoolStringArray: https://docs.godotengine.org/en/stable/classes/class_poolstringarray.html

.. _Node: https://docs.godotengine.org/en/stable/classes/class_node.html