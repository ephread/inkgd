Choosing between *inkgd* and *godot-ink*
========================================

.. important::
    The decision to pick *inkgd* over *godot-ink* boils down to the programming
    language you want to use in your game. If your game uses Godot Mono and is
    primarily written in C#, you should use *godot-ink*. On the other hand, if
    you have a GDScript codebase, *inkgd* is the best option. For more
    information, see below.

There are two ports of the **ink** runtime for Godot, *godot-ink* and *inkgd*.

*godot-ink* wraps the original C# runtime and is geared towards Godot Mono.
*inkgd* is written in GDScript and is more at home in Godot vanilla.

Differences, strengths and weaknesses
*************************************

*godot-ink* provides a C# API that can be awkward when used in GDScript. For
instance, methods are written in PascalCase. Additionally, some types —such as
InkList— can't be easily bridged to GDScript.

*inkgd* provides a snake-cased API that integrates well with other GDScript
scripts, but suffers from poor performances. The GDScript implementation is
about 50 times slower than *godot-ink*. These performance limitations are
detailed in :doc:`/advanced/performance`.

If the poor performances are too limiting and you don't mind packaging a Mono
runtime in your game, *inkgd* also supports wrapping the original C# runtime,
while keeping the same GDScript API. :doc:`/advanced/migrating_to_godot_mono`
describes the process of using the official runtime in inkgd.

--------------------------------------------------------------------------------

If you're still interested in using *inkgd*, head over to the
:doc:`/getting_started/introduction`. Otherwise, godot-ink_ is an excelent
choice!

.. _godot-ink: https://github.com/paulloz/godot-ink
