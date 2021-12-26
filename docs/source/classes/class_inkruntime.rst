.. This class should be generated. But for now, it's written by hand.

.. _class_inkruntime:

InkRuntime
==========

**Inherits:** Node_


Description
-----------

A node encapsulating the static properties of the runtime and managing
exceptions.

Exceptions don't exists in GDScript, but they are *emulated* by the runtime
and reported through :ref:`exception_raised<class_inkruntime_exception_raised>`.


Properties
----------

+-------+----------------------------------------------------------------------------------+-----------+
| bool_ | :ref:`do_not_save_default_values<class_inkruntime_do_not_save_default_values>`   | ``false`` |
+-------+----------------------------------------------------------------------------------+-----------+
| bool_ | :ref:`stop_execution_on_exception<class_inkruntime_stop_execution_on_exception>` | ``false`` |
+-------+----------------------------------------------------------------------------------+-----------+
| bool_ | :ref:`stop_execution_on_error<class_inkruntime_stop_execution_on_error>`         | ``false`` |
+-------+----------------------------------------------------------------------------------+-----------+


Signals
-------

.. _class_inkruntime_exception_raised:

- **exception_raised (** String_ message, PoolStringArray_ stack_trace **)**

Emitted when the runtime encounters an exception. Exceptions are not recoverable
and may corrupt the state. They are the consequence of either a programmer error
or a bug in the runtime.


Property Descriptions
---------------------

.. _class_inkruntime_do_not_save_default_values:

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

.. _class_inkruntime_stop_execution_on_exception:

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

.. _class_inkruntime_stop_execution_on_error:

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

.. Those links are duplicated.
.. TODO: Use sphinx.ext.extlinks?

.. _`VariablesState.cs`: https://github.com/inkle/ink/blob/v1.0.0/ink-engine-runtime/VariablesState.cs

.. _bool: https://docs.godotengine.org/en/stable/classes/class_bool.html

.. _String: https://docs.godotengine.org/en/stable/classes/class_string.html
.. _PoolStringArray: https://docs.godotengine.org/en/stable/classes/class_poolstringarray.html

.. _Node: https://docs.godotengine.org/en/stable/classes/class_node.html