# ![inkgd](https://i.imgur.com/QbLG9Xp.png)

[![build](https://github.com/ephread/inkgd/workflows/build/badge.svg)](https://github.com/ephread/inkgd/actions)
[![Documentation Status](https://readthedocs.org/projects/inkgd/badge/?version=latest)](https://inkgd.readthedocs.io/en/latest/?badge=latest)
![Version](https://img.shields.io/badge/version-0.2.3-orange.svg)
![Godot Version](https://img.shields.io/badge/godot-3.1+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

Implementation of [inkle's Ink] in pure GDScript, with editor support.

⚠️ **Note:** While the implementation of the runtime is feature-complete and passes the test suite, you may still encounter some weird behaviors and bugs that will need to be ironed out. The runtime is not yet considered production ready, but it's almost there.

[inkle's Ink]: https://github.com/inkle/ink

## Table of contents

  * [Features](#features)
  * [Requirements](#requirements)
  * [Contributing](#asking-questions--contributing)
      * [Asking Questions](#asking-questions)
      * [Contributing](#contributing)
  * [Installation](#installation)
  * [Usage](#usage)
      * [Runtime](#runtime)
      * [Editor](#editor)
  * [Compatibility Table](#compatibility-table)
  * [License](#license)

## Features
- [x] Fully featured Ink runtime
- [x] Automatic recompilation of the master Ink file on each build
- [ ] Story previewer integrated in the editor
- [ ] Multi-file support in the editor

## Requirements
- Godot 3.1+
- Inklecate 0.8.2+

## Asking Questions / Contributing

### Asking questions

If you need help with something in particular, open up an issue on this repository.

### Contributing

If you want to contribute, be sure to take a look at [the contributing guide].

[the contributing guide]: https://github.com/ephread/inkgd/blob/master/CONTRIBUTING.md

## Installation

### Godot Asset Library

_inkgd_ is available through the official Godot Asset Library.

1. Click on the AssetLib button at the top of the editor.
2. Search for "inkgd" and click on the resulting element.
3. In the dialog poppin up, click "Install".
4. Once the download completes, click on the second "Install" button that appeared.
5. Once more, click on the third "Install" button.
6. All done!

### Manually

You can also download an archive and install _inkgd_ manually. Head over to the [releases], and download the latest version. Then extract the downloaded zip and place the `inkgd` directory into the `addons` directory of your project. If you don't have an `addons` directory at the root of the project, you'll have to create one first.

[releases]: https://github.com/ephread/inkgd/releases

## Usage

### Runtime

The GDScript API is mostly compatible with the original C# one. It's a good idea to take a look at the [original documentation].

If you want to start from a template, the plugin adds templates that will show up when creating a new script. Add this script to a node that you want to use to control the story. These templates should disappear if you deactivate the plugin.

Additionally, feel free to take a look in the `example/` directory and run `ink_runner.tscn`, which will play The Intercept.

Note: _inkgd_ has a .gitattributes file which makes sure that only `addons/inkgd` is added to the Github archive. The only way to get the example folder (and a bunch of other important files) is to clone the project.

[original documentation]: https://github.com/inkle/ink/blob/master/Documentation/RunningYourInk.md

#### Differences with the C# API

There are subtle differences between the original C# runtime and the GDScript version.

#### 1. Style

Functions are all snake_cased rather than CamelCased. For instance `ContinueMaximally` becomes `continue_maximally`.

##### 2. `__InkRuntime`

Since GDScript doesn't support static properties, any static property was moved into a singleton node called `__InkRuntime` which needs to be added to the root object current tree before starting the story.

This singleton node is added to the AutoLoad list of your project automatically when the plugin is activated (bear in mind that deactivating the plugin will also remove the node from the list).

However, you may want to manage the singleton yourself in the code for efficiency. Since the tree is locked during notification calls (`_ready`, `_enter_tree`, `_exit_tree`), you will need to defer the calls adding/removing the runtime node.

```gdscript
var InkRuntime = load("res://addons/inkgd/runtime.gd")

func _ready():
    call_deferred("_add_runtime")

func _exit_tree():
    call_deferred("_remove_runtime")

func _add_runtime():
    InkRuntime.init(get_tree().root)

func _remove_runtime():
    InkRuntime.deinit(get_tree().root)
```

Alternatively, `__InkRuntime` can also be added as a singleton with [AutoLoad].

`__InkRuntime` contains a few configuration settings you may want to tweak. To that end,
`InkRuntime.init()` returns the `__InkRuntime` added to the tree. The two following settings
are enabled by default, but you can disable them if they interfere with your environment.

- `should_pause_execution_on_runtime_error`: pause the execution in debug when a runtime error is raised.
- `should_pause_execution_on_story_error`: pause the execution in debug when a story error is raised.

[AutoLoad]: https://docs.godotengine.org/en/stable/getting_started/step_by_step/singletons_autoload.html#autoload

##### 3. [Getting and setting variables](https://github.com/inkle/ink/blob/master/Documentation/RunningYourInk.md#settinggetting-ink-variables)

Since the `[]` operator can't be overloaded in GDScript, simple `get` and `set` calls replace it.

```gdscript
story.variables_state.get("player_health")
story.variables_state.set("player_health", 10)

# Original C# API
#
# _inkStory.VariablesState["player_health"]
# _inkStory.VariablesState["player_health"] = 10
```

##### 4. [Variable Observers](https://github.com/inkle/ink/blob/master/Documentation/RunningYourInk.md#variable-observers)

The event / delegate mechanism found in C# is translated into a signal-based logic in the GDScript runtime.

```gdscript
story.observe_variable("health", self, "_observe_health")

func _observe_health(variable_name, new_value):
    set_health_in_ui(int(new_value))

# Original C# API
#
# _inkStory.ObserveVariable("health", (string varName, object newValue) => {
#    SetHealthInUI((int)newValue);
# });
```

##### 5. [External Functions](https://github.com/inkle/ink/blob/master/Documentation/RunningYourInk.md#external-functions)

The event / delegate mechanism found in C# is again translated into a signal-based logic.

```gdscript
story.bind_external_function("multiply", self, "_multiply", true)

func _multiply(arg1, arg2):
    return arg1 * arg2

# Original C# API
#
# _inkStory.BindExternalFunction ("multiply", (int arg1, float arg2) => {
#     return arg1 * arg2;
# }, true);
```

##### 6. Getting the ouput of `evaluate_function`

`evaluate_function` evaluates an ink function from GDScript. Since it's not possible to have in-out variables in GDScript, if you want to retrieve the text output of the function, you need to pass `true` to `return_text_output`. `evaluate_function` will then return a dictionary containing both the return value and the outputed text.

```gdscript
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
```

##### 7. Handlers

Starting with Ink version 1.0.0, it's possible to attach different types of handlers to a story to receive callbacks. In C#, those handlers are implemented using events. In _inkgd_, those are implemented using signals.

```gdscript
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
```

It's recommended that you connect a handler to `on_error` to receive errors and warnings. If you don't, the story may stop unfolding when an error is encountered.

##### 8. Error Handling

The original implementation relies on C#'s exceptions to report and recover from inconsistent states.
Exceptions are not available in GDScript, so the runtime may behave slightly differently. In particular,
if an error is encountered during `story.continue()`, the story may be inconsistent state even though
it can still more forward after calling `story.reset_errors()`.

#### Loading the story from a background thread

For bigger stories, loading the compiled story into the runtime can take a long time (more than a second). To avoid blocking the main thread, you may want to load the story from a background thread and display a loading indicator.

A possible thread-based approach is implemented in `example/ink_runner.gd`. You can also find it by selecting Ink Template when creating your code.

### Editor

_inkgd_ ships with a small editor plugin, which main purpose is to automatically recompile your ink file on each build.

Note: you will need [inklecate] installed somewhere on your system.

Navigate to "Project" > "Project Settings" and then, in the "Plugins" tab, change the status of the "InkGD" to "active".

A new panel should pop up on the right side of your editor.

![Ink panel](https://i.imgur.com/oMkP4IW.png)

Here, you need to provide four (or three on Windows) different paths:

- *Mono*: path to mono _(note: doesn't appear on Windows)_.
- *Executable*: path to inklecate _(note: an absolute path is expected here)_.
- *Source File*: path to the ink file you want to compile.
- *Target File*: output path of the compiled story.

By clicking on "Test", you can test that the plugin can sucessfully run inklecate. You can also compile the story manually by clicking on "Compile".

The configuration is saved as two files inside the root directory of the project:

- `.inkgd_ink.cfg` stores the paths to both the source file and the target file.
- `.inkgd_compiler.cfg` stores the paths to inklecate and the mono runtime.

If you're working in a team, you may want to commit `.inkgd_ink.cfg` and keep `.inkgd_compiler.cfg` out of version control.

[inklecate]: https://github.com/inkle/ink/releases

## Compatibility Table

| _inkgd_ version | inklecate version |  Godot version  |
|:---------------:|:-----------------:|:---------------:|
|  0.1.0 – 0.1.4  |   0.8.2 – 0.8.3   |   3.1 – 3.2.1   |
|  0.2.0 – 0.2.1  |       0.9.0       |   3.1 – 3.2.1   |
|      0.2.2      |       0.9.0       |  3.2.1 – 3.2.3  |
|      0.2.3      |       0.9.0       |   3.2.1 – 3.4   |

## License

_inkgd_ is released under the MIT license. See LICENSE for details.
