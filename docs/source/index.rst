*inkgd* Docs – |release|
========================

.. image:: img/inkgd.png
    :align: center
    :alt: inkgd logo

|

Welcome to the official documentation of *inkgd*, an implementation of Ink's
runtime for Godot, in pure GDScript.

The table of contents below, as well as the sidebar, should let you easily find
the topic you're looking for. If it's your first time using *inkgd*, we
recommend you start with :doc:`getting_started/introduction` first.

If you prefer a more hands-on approach, feel free to tinker with the
`example project`_ (*inkgd*'s repository is the example project itself).

.. _`example project`: https://github.com/ephread/inkgd/

.. The version is hardcoded for now. The inability to nest markup in reST is
.. really annoying. Hopefully MyST can solve some of those issues.
.. _here: https://github.com/ephread/inkgd/releases/download/0.5.0/inkgd-example-0.5.0.zip

While looking for an implementation of **ink** in Godot, you may have come across
godot-ink_. *inkgd* and *godot-ink* have different philosophies and purposes. If
you are not certain which one you should use,
:doc:`advanced/choosing_between_inkgd_and_godot_ink` offers a breakdown of their
differences.

.. _godot-ink: https://github.com/paulloz/godot-ink

.. .......................................................................... ..

.. toctree::
   :maxdepth: 1
   :caption: Getting started

   getting_started/introduction
   getting_started/installation
   getting_started/configuration

.. toctree::
   :maxdepth: 1
   :caption: Advanced

   advanced/choosing_between_inkgd_and_godot_ink
   advanced/using_inkplayer
   advanced/editor_plugin/index
   advanced/differences_between_api
   advanced/error_management
   advanced/performance

.. toctree::
   :maxdepth: 1
   :caption: Migrations

   migrating_from_godot_3_to_godot_4
   advanced/migrating_to_godot_mono

.. toctree::
   :maxdepth: 2
   :caption: Class reference

   classes/index
