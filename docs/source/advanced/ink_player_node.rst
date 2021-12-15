
*InkPlayer* node
================

Activating the editor plugin will register a custom node that greatly simplifies
the use of Ink within Godot.

Loading the story from a background thread
******************************************

For bigger stories, loading the compiled story into the runtime can take a
long time (more than a second). To avoid blocking the main thread, you may
want to load the story from a background thread and display a loading indicator.

Fortunately, `InkPlayer` supports loading the story in a thread out of the box.