Differences between the GDScript and C# APIs
============================================

There are subtle differences between the original C# runtime and the GDScript
version, but since the two APIs are mostly compatible, it's a good idea to take
a look at the `original documentation`_.

.. _`original documentation`: https://github.com/inkle/ink/blob/master/Documentation/RunningYourInk.md

Style
-----

Functions are all snake_cased rather than CamelCased. For instance
``ChooseCoiceIndex`` becomes ``choose_choice_index``.

.. _ink-runtime:

*inkgd*'s runtime node
----------------------

Since GDScript doesn't support static properties, any static property was moved
into a singleton node called :doc:`/classes/class_inkruntime` which needs to be
added to the current tree before starting the story.

This singleton node is added to the AutoLoad list of your project automatically
when the editor plugin is activated. If you don't want to use the plugin, the
runtime node can be registered manually, see :ref:`here <autoload-singletons>`
for more information.

Alternatively, you can also manage the singleton in code. Import
``res://addons/inkgd/runtime.gd`` in your script, then call
the appropriate methods in ``_ready()`` and ``_exit_tree()`` to add/remove
``res://addons/inkgd/runtime/static/ink_runtime.gd`` to/from the tree.

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

InkRuntime contains a few configuration settings you may want to tweak, see the
:doc:`API documentation</classes/class_inkruntime>`.

.. note::

    When using InkPlayer, you don't need to manually add the runtime node to
    the tree. All the properties defined on InkRuntime are also available on
    InkPlayer, use them instead if you did not instantiate the node by
    yourself.

`Continuing the story`_
--------------------------------

Since ``continue`` is a protected keywords in GDScript, ``Story.Continue()``
becomes ``Story.continue_story()``. The maximal and async versions also
used the updated terminology to keep things consistent.

GDScript API
************

.. code:: gdscript

    story.continue_story()
    story.continue_story_maximally()
    story.continue_story_async(10)

Original C# API
***************

.. code:: csharp

    story.Continue()
    story.ContinueMaximally()
    story.ContinueAsync(10)


`Getting and setting variables`_
--------------------------------

.. _`Getting and setting variables`: https://github.com/inkle/ink<https://github.com/inkle/ink/blob/master/Documentation/RunningYourInk.md#settinggetting-ink-variables>

Since the ``[]`` operator can't be overloaded in GDScript, simple ``get_variable`` and
``set_variable`` calls replace it. ``get`` and ``set`` are protected keywords.

GDScript API
************

.. code:: gdscript

    story.variables_state.get_variable("player_health")
    story.variables_state.set_variable("player_health", 10)

Original C# API
***************

.. code:: csharp

    _inkStory.VariablesState["player_health"]
    _inkStory.VariablesState["player_health"] = 10

`Variable Observers`_
---------------------

.. _`Variable Observers`: https://github.com/inkle/ink/blob/master/Documentation/RunningYourInk.md#variable-observers

The event/delegate mechanism found in C# is translated into a signal-based
logic in the GDScript runtime.

GDScript API
************

.. code:: gdscript

    story.observe_variable("health", self, "_observe_health")

    func _observe_health(variable_name, new_value):
        set_health_in_ui(int(new_value))

Original C# API
***************

.. code:: csharp

    _inkStory.ObserveVariable("health", (string varName, object newValue) => {
       SetHealthInUI((int)newValue);
    });

`External Functions`_
---------------------

.. _`External Functions`: https://github.com/inkle/ink/blob/master/Documentation/RunningYourInk.md#external-functions

The event/delegate mechanism found in C# is again translated into a
signal-based logic.

GDScript API
************

.. code:: gdscript

    # GDScript API

    story.bind_external_function("multiply", self, "_multiply", true)

    func _multiply(arg1, arg2):
        return arg1 * arg2

Original C# API
***************

.. code:: csharp

    // Original C# API

    _inkStory.BindExternalFunction ("multiply", (int arg1, float arg2) => {
        return arg1 * arg2;
    }, true);

`Handlers`_
-----------

.. _`Handlers`: https://github.com/inkle/ink/blob/master/Documentation/RunningYourInk.md#error-handling

Starting with **ink** version 1.0.0, it's possible to attach different types of
handlers to a story to receive callbacks. In C#, they are implemented using
events. In *inkgd*, they are again implemented using signals.

GDScript API
************

.. code:: gdscript

    signal on_error(message, type)
    signal on_did_continue()
    signal on_make_choice(choice)
    signal on_evaluate_function(function_name, arguments)
    signal on_complete_evaluate_function(function_name, arguments, text_output, result)
    signal on_choose_path_string(path, arguments)

Original C# API
***************

.. code:: csharp

    public event Ink.ErrorHandler onError;
    public event Action onDidContinue;
    public event Action<Choice> onMakeChoice;
    public event Action<string, object[]> onEvaluateFunction;
    public event Action<string, object[], string, object> onCompleteEvaluateFunction;
    public event Action<string, object[]> onChoosePathString;

The new handler system also supports reporting errors and warnings. It's
recommended that you connect a handler to ``on_error`` to receive them.


Error Management
----------------

The original implementation relies on C#'s exceptions to report and recover from
inconsistent states. Exceptions are not available in GDScript, so the runtime
may behave slightly differently. In particular, if an error or an exception is
encountered during ``story.continue_story()``, the story may be inconsistent state
even though it can still move forward after calling ``story.reset_errors()``.

Runtime exceptions are emitted through
:ref:`exception_raised<class_inkruntime_exception_raised>`. For more
information, refer to :doc:`this document</advanced/error_management>`.

.. note::

    :doc:`/classes/class_inkplayer` has a different API regarding handlers and
    signals and fowards
    :ref:`exception_raised<class_inkruntime_exception_raised>`.


Getting the output of ``evaluate_function``
------------------------------------------

``evaluate_function`` evaluates an **ink** function from GDScript. Since it's
not possible to have in-out variables in GDScript you need to pass ``true`` to
``return_text_output`` to retrieve the text output of the function.
``evaluate_function`` will then return a dictionary containing both the return
value and the output text.

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

    :doc:`/classes/class_inkplayer` splits this function into two different
    functions, ``evaluate_function`` and ``evaluate_function_and_get_output``,
    instead of a boolean flag.

Observing Variables
-------------------

To be added.
