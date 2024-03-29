Import Plugins
==============

The editor plugin bundles two import plugins. One can import *\*.ink* files
while the other can import *\*.json* files.


Ink Importer
------------

The *\*.ink* importer converts all **ink** files into dummy resources and is
only used to enable the automatic recompilation of managed stories. Internally,
the plugin gets notified any time an **ink** file has been reimported and can
trigger a recompilation when appropriate. For more information, refer to the
section about :ref:`automatic recompilation <watched-directory>`.

.. note::

    If you store **ink** files in your project, it's recommended that you exclude
    them from exports, as they serve no purpose in the final game.


JSON Importer
-------------

The *\*.json* importer converts compiled stories into instances of
*InkResource* that can be passed to :doc:`../../classes/class_inkplayer`.

After loading an *InkResource*, you can retrieve its JSON content through
the ``json`` property.

.. code-block:: gdscript

    var bytecode = load("res://examples/ink/the_intercept.ink.json")

    print(bytecode.json)

Since JSON files are very common and might be imported by multiple plugins,
make sure to use the appropriate importer when reimporting them.
