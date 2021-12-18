Initial configuration
=====================

One of the divergences in API mentioned above relates to *static members*.
The orignal C# implementation makes heavy use of static variables, but since
GDScript don't support them, it uses a singleton node instead. This runtime
node must be added to the scene tree before executing any of the methods
of the GDScript API.

By default, the singleton node is autoconfigured an AutoLoad singleton,
but there are other methods you may want to explore depending on your needs.

.. _autoload-singletons:

Project-wide AutoLoad singletons
--------------------------------

As said above, this is the default configuration. The runtime node is added in
your project automatically as long as the editor plugin is enabled.

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


InkPlayer
---------

:ref:`InkPlayer<class_inkplayer>` is a custom node provided by the plugin. It
will also add the runtime node automatically if it's not already present in the
scene tree. When added by InkPlayer, the runtime node will be removed as soon as
InkPlayer is itself removed from the scene tree.


Adding the runtime node manually
--------------------------------

If you don't want to use the editor plugin, you will have to manage the runtime
node manually. The simplest way is to add the node to the list of AutoLoad
singletons as described above, but it's also possible to add the node through
scripting. See :ref:`here <ink-runtime>` for more information.

--------------------------------------------------------------------------------

That's it! You can now start using *inkgd* in your Godot scripts. From here you
can:

- take a look at documentation of :ref:`InkPlayer<class_inkplayer>`;
- learn how to use all the features offered by the :ref:`editor plugin<editor_plugin>`.

.. Jump over to the next section to create your first game with *inkgd*.