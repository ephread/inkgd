# How to contribute

We're very happy to hear that you wish to contribute! 🎊

_inkgd__ is a fairly small project, so the rules aren't particularly tight.
There are a few things to know, however. For one, the current project maintainer
is usually not very responsive and wishes to extend their apologies in that
regard.

## Asking question / Reporting issues / Getting in touch

### I have a question

1. Check whether it has been asked before or not. You can either search through
   [issues].
2. If it hasn't been asked before, open an issue.

If it's about getting help, please avoid sending e-mails directly to the project
maintainer. It's better to ask out in the open, the community greatly benefits
when questions and answers are readily available.

Don't forget, asking questions is nothing to be ashamed of.

[issues]: https://github.com/ephread/inkgd/issues

### I encountered a bug

Open an issue or fix the bug yourself and submit a pull request!

### I think _inkgd_ would be better with feature X

If you want to improve the editor plugin, it's better to notify the project
maintainer beforehand. You don't want to put in a significant amount of work and
see your pull request refused because it doesn't fit the project's vision. To
get in touch with the project manager, you can either open a issue, poke them on
Gitter or send them an email, they will try to respond as quickly as possible!

On the other hand, if you want to improve the runtime, remember that _inkgd_
follows the features provided by the original C# version. Thus, it's unlikely
your feature idea will be accepted if it's present in the original version.

## Adding code to _inkgd_

If you're working on a pull request, here are a few things to remember.

**Don't be afraid to ask questions!** If anything seems unclear, ask away! We
need to make sure that everyone is on the same page.

### Style guide, testing & debugging

#### Style guide

_inkgd_ tries to follow the [official style guide], though it's not there yet
due to its C# ancestry.

There are two important rules to follow:

1. Whenever accessing an instance property, it should be done through `self`.
   This ensures that setter and getter will always be called.
2. When converting a C# `struct`, which is value type, make sure you implement a
   `duplicate()` method and use it appropriately.

[official style guide]: http://docs.godotengine.org/en/latest/getting_started/scripting/gdscript/gdscript_styleguide.html

##### Type System

1. The String type can't be used in most cases, because unlike C#, Strings are
value types and. Only add the String type when you're certain the value can't or
shouldn't be null.

#### Testing

Make sure all the tests are all green! _inkgd_ uses [Gut] to run tests. Adding
tests to your PR is not expected, but feel free to do so 😉.

[Gut]: https://github.com/bitwes/Gut

#### Debugging

When debugging through the example project, don't forget to set
`InkPlayer.loads_in_background` to `false` in `ink_runner.gd` since Godot's
debugger doesn't work when threads are involved.

### Git branching model & pull requests

_inkgd_ has a very loose branching model. All improvements and fixes happen in
`main`, since there isn't a real need to support different versions. Branches
are created for two reasons:

1. to deal with new features or large fixes, these will eventually be merged
   back into master;
2. to keep legacy code working with older versions of Godot

Pull requests need to focus on specific new features, changes or fixes. Keep
them short and try to keep the number of files involved as low as possible, to
ensure that the code review will be manageable.

If you are making a non-trivial changes, which will require back and forth
exchanges on the PR, the maintainer will often ask you to create (or move) your
PR against a specific branch. The feature can then be dealt with in isolation.
Therefore, you shouldn't merge any subsequent commit added to `main` into your
PR without discussing it first with the maintainer.

### License & contribution

_inkgd_ is licensed under the MIT License. Please use follow the header style
(which mentions the license) when creating new files.

Please don't be shy and credit yourself when you make a pull request. 👏
