*inkgd* Docs – *main* branch
============================

.. image:: img/inkgd.png
    :align: center
    :alt: inkgd logo

|

Welcome to the official documentation of *inkgd*, an implementation of Ink's
runtime in pure GDScript for Godot.

The table of contents below as well as the sidebar should let you easily find
the topic you are looking for. If it's your first time using *inkgd*, we
recommend you start with :doc:`getting_started/introduction` first.

Feel free to take a look in the `example directory`_ and run
``the_intercept.tscn``, which plays *The Intercept*.

.. _`example directory`: https://github.com/ephread/inkgd/tree/main/examples

.. note::

   *inkgd* has a .gitattributes file which makes sure that only ``addons/inkgd``
   is added to the Github archive. The only way to get the example folder (and
   a bunch of other important files) is to clone the project.

.. toctree::
   :maxdepth: 1
   :caption: Getting started

   getting_started/introduction
   getting_started/installation
   getting_started/configuration

.. toctree::
   :maxdepth: 1
   :caption: Advanced

   advanced/differences_between_api
   advanced/ink_player_node
   advanced/editor_plugin/index

.. toctree::
   :maxdepth: 1
   :caption: Class reference

   classes/index
