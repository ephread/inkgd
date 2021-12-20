Initial configuration
=====================

One of the divergences in API mentioned above relates to *static members*.
The orignal C# implementation makes heavy use of static variables, but since
GDScript don't support them, it uses a singleton node called
:doc:`/classes/class_inkruntime` instead. This runtime node must be added to
the scene tree before executing any of the methods of the GDScript API.

.. _autoload-singletons:

The singleton node is autoconfigured an AutoLoad singleton as long as the editor
plugin is enabled.

It's also possible to add ``res://addons/inkgd/runtime.gd`` to the AutoLoad list
manually if it doesn't appear in the list or was previously removed.

.. image:: img/introduction/auto_load_file_button.png
    :align: center
    :alt: The AutoLoad tab in the project settings.

|

.. image:: img/introduction/auto_load_add.png
    :align: center
    :alt: The AutoLoad tab in the project settings, with the add button emphasized.

|

.. image:: img/introduction/auto_load_runtime_added.png
    :align: center
    :alt: The AutoLoad tab with 'runtime.gd' added as a singleton.

|

When added as an AutoLoad singleton, the node will remain in the scene tree even
when the current scene changes.

--------------------------------------------------------------------------------

That's it! You can now start using *inkgd* in your Godot scripts. From here you
can:

- learn how to add :doc:`InkPlayer<../advanced/using_inkplayer>` to your
  projets;
- learn how to use all the features offered by the
  :ref:`editor plugin<editor_plugin>`.

.. Jump over to the next section to create your first game with *inkgd*.
