
Differences between the GDScript and C# APIs
============================================

There are subtle differences between the original C# runtime and the GDScript
version, but since the two APIs are mostly compatible, it's a good idea to take
a look at the `original documentation`_.

.. _`original documentation`: https://github.com/inkle/ink/blob/master/Documentation/RunningYourInk.md

Style
*****

Functions are all snake_cased rather than CamelCased. For instance
``ContinueMaximally`` becomes ``continue_maximally``.

.. _ink-runtime:

*inkgd*'s runtime node
**********************

Since GDScript doesn't support static properties, any static property was moved
into a singleton node called *__InkRuntime* which needs to be added to the root
object current tree before starting the story.

This singleton node is added to the AutoLoad list of your project automatically
when the plugin is activated (bear in mind that deactivating the plugin will
also remove the node from the list). If you don't want to use the plugin, the
runtime node can also be added manually, see :ref:`here <autoload-singletons>`
for more information.

Alternatively, you may want to manage the singleton manually. Import
``res://addons/inkgd/runtime/static/ink_runtime.gd`` in your script, then call
the appropriate methods in ``_ready()`` and ``_exit_tree()``

.. code-block:: gdscript

    var InkRuntime = load("res://addons/inkgd/runtime.gd")


    # Since the tree is locked during '_enter_tree' and '_exit_tree',
    # the node has to be added and removed through deferred calls.
    func _ready():
        call_deferred("_add_runtime")


    func _exit_tree():
        call_deferred("_remove_runtime")


    func _add_runtime():
        InkRuntime.init(get_tree().root)


    func _remove_runtime():
        InkRuntime.deinit(get_tree().root)

``__InkRuntime`` contains a few configuration settings you may want to tweak. To
that end, ``InkRuntime.init()`` returns the node added to the tree. The two
following settings are enabled by default, but you can disable them if they
interfere with your environment.

-  ``should_pause_execution_on_runtime_error``: pause the execution in
   debug when a runtime error is raised.
-  ``should_pause_execution_on_story_error``: pause the execution in
   debug when a story error is raised.

.. note::

    When using ``InkPlayer``, you don't need to manually add the runtime node to
    the tree. The two properties described above are also available on
    *InkPlayer*, use them instead if you did not instantiate the node by
    yourself.

`Getting and setting variables`_
********************************

.. _`Getting and setting variables`: https://github.com/inkle/ink<https://github.com/inkle/ink/blob/master/Documentation/RunningYourInk.md#settinggetting-ink-variables>

Since the ``[]`` operator can't be overloaded in GDScript, simple ``get`` and
``set`` calls replace it.

.. code:: gdscript

   story.variables_state.get("player_health")
   story.variables_state.set("player_health", 10)

   # Original C# API
   #
   # _inkStory.VariablesState["player_health"]
   # _inkStory.VariablesState["player_health"] = 10

`Variable Observers`_
*********************

.. _`Variable Observers`: https://github.com/inkle/ink/blob/master/Documentation/RunningYourInk.md#variable-observers

The event / delegate mechanism found in C# is translated into a signal-based
logic in the GDScript runtime.

.. code:: gdscript

   story.observe_variable("health", self, "_observe_health")

   func _observe_health(variable_name, new_value):
       set_health_in_ui(int(new_value))

   # Original C# API
   #
   # _inkStory.ObserveVariable("health", (string varName, object newValue) => {
   #    SetHealthInUI((int)newValue);
   # });

`External Functions`_
*********************

.. _`External Functions`: https://github.com/inkle/ink/blob/master/Documentation/RunningYourInk.md#external-functions

The event / delegate mechanism found in C# is again translated into a
signal-based logic.

.. code:: gdscript

   story.bind_external_function("multiply", self, "_multiply", true)

   func _multiply(arg1, arg2):
       return arg1 * arg2

   # Original C# API
   #
   # _inkStory.BindExternalFunction ("multiply", (int arg1, float arg2) => {
   #     return arg1 * arg2;
   # }, true);

`Handlers`_
***********

.. _`Handlers`: https://github.com/inkle/ink/blob/master/Documentation/RunningYourInk.md#error-handling

Starting with Ink version 1.0.0, it's possible to attach different types of
handlers to a story to receive callbacks. In C#, those handlers are implemented
using events. In *inkgd*, those are implemented using signals.

.. code:: gdscript

   # GDScript API

   signal on_error(message, type)
   signal on_did_continue()
   signal on_make_choice(choice)
   signal on_evaluate_function(function_name, arguments)
   signal on_complete_evaluate_function(function_name, arguments, text_output, result)
   signal on_choose_path_string(path, arguments)

   story.connect("on_did_continue", self, "_handle_did_continue")

   # Original C# API
   #
   # public event Ink.ErrorHandler onError;
   # public event Action onDidContinue;
   # public event Action<Choice> onMakeChoice;
   # public event Action<string, object[]> onEvaluateFunction;
   # public event Action<string, object[], string, object> onCompleteEvaluateFunction;
   # public event Action<string, object[]> onChoosePathString;

It's recommended that you connect a handler to ``on_error`` to receive errors
and warnings. If you don't, the story may stop unfolding when an error is
encountered.

.. note::

    When using ``InkPlayer``, the list of handler is a bit different, see
    :doc:`/getting_started/using_ink_player` for more information.

Getting the ouput of ``evaluate_function``
******************************************

``evaluate_function`` evaluates an ink function from GDScript. Since it's not
possible to have in-out variables in GDScript, if you want to retrieve the text
output of the function, you need to pass ``true`` to ``return_text_output``.
``evaluate_function`` will then return a dictionary containing both the return
value and the outputed text.

.. code:: gdscript

   # story.ink
   #
   # === function multiply(x, y) ===
   #     Hello World
   #     ~ return x * y
   #

   var result = story.evaluate_function("multiply", [5, 3])
   # result == 15

   var result = story.evaluate_function("multiply", [5, 3], true)
   # result == {
   #     "result": 15,
   #     "output": "Hello World"
   # }

.. note::

    ``InkPlayer`` uses two different functions, instead of a boolean flag:
    ``evaluate_function`` and ``evaluate_function_and_get_output``.

Error Recovery
**************

The original implementation relies on C#'s exceptions to report and recover from
inconsistent states. Exceptions are not available in GDScript, so the runtime
may behave slightly differently. In particular, if an error is encountered
during ``story.continue()``, the story may be inconsistent state even though it
can still move forward after calling ``story.reset_errors()``.
