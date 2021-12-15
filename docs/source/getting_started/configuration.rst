Initial configuration
=====================

One of the divergences in API mentioned above relates to *static members*.
The orignal C# implementation makes heavy use of static variables, but since
GDScript don't support them, it uses a singleton node instead. This runtime
node must be added to the scene tree before executing any of the methods
of the GDScript API.

There are three major ways to deal with the runtime node.

.. _autoload-singletons:

Project-wide AutoLoad singletons
--------------------------------

If you enabled the editor plugin, the runtime node will be added as an
AutoLoad singleton in your project automatically (unless you manually removed
it afterwards). It's also possible to manually add
``res://addons/inkgd/runtime.gd`` to the AutoLoad list.

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

When added as an AutoLoad singleton, the node will remain present int the scene
tree even when the current scene is changed.

InkPlayer Node
--------------

``InkPlayer`` is a custom node provided by the plugin. It will also add the
runtime node automatically if it's not already present in the scene tree. When
added by ``InkPlayer``, the runtime node will be removed as soon as the node is
itself removed from the scene tree.

Adding the runtime node manually
--------------------------------

If you don't want to use the editor plugin, you will have to manage the runtime
node manually. The simplest way is to add the node to the list of AutoLoad
singletons as described above, but it's also possible to add the node through
scripting. See :ref:`here <ink-runtime>` for more information.

----------

That's it! You can now start using *inkgd* in your Godot scripts.

.. Jump over to the next section to create your first game with *inkgd*.