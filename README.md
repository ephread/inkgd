# ![inkgd](https://i.imgur.com/QbLG9Xp.png)

[![build](https://github.com/ephread/inkgd/workflows/build/badge.svg)](https://github.com/ephread/inkgd/actions)
[![Documentation Status](https://readthedocs.org/projects/inkgd/badge/?version=latest)](https://inkgd.readthedocs.io/en/latest/?badge=latest)
![Version](https://img.shields.io/badge/version-0.3.0-orange.svg)
![Godot Version](https://img.shields.io/badge/godot-3.1+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

Implementation of [inkle's Ink] in pure GDScript, with editor support.

⚠️ **Note:** While the implementation of the runtime is feature-complete and
passes the test suite, it's unlikely to ever be considered “production-ready”.
_inkgd_ shines for rapid-prototyping in GDScript and small games, but for bigger
projects it's likely to be too slow. If you need a more bulletproof solution
and don't mind C#, you should consider using [godot-ink].

[inkle's Ink]: https://github.com/inkle/ink
[godot-ink]: https://github.com/paulloz/godot-ink

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
- [x] Automatic recompilation of managed ink files
- [x] Story previewer integrated in the editor
- [x] Multi-file support in the editor

## Requirements
- Godot 3.4+
- Inklecate 1.0.0+

## Asking Questions / Contributing

### Asking questions

If you need help with something in particular, [start a discussion].
If you want to report a problem, [open an issue].

[start a discussion]: https://github.com/ephread/inkgd/discussions/new
[open an issue]: https://github.com/ephread/inkgd/issues/new/choose

### Contributing

If you want to contribute, be sure to take a look at [the contributing guide].

[the contributing guide]: https://github.com/ephread/inkgd/blob/master/CONTRIBUTING.md

## Installation

### Godot Asset Library

_inkgd_ is available through the official Godot Asset Library.

1. Click on the AssetLib button at the top of the editor.
2. Search for "inkgd" and click on the resulting element.
3. In the dialog poppin up, click "Install".
4. Once the download completes, click on the second "Install" button
   that appeared.
5. Once more, click on the third "Install" button.
6. All done!

### Manually

You can also download an archive and install _inkgd_ manually. Head over to the
[releases], and download the latest version. Then extract the downloaded zip and
place the `inkgd` directory into the `addons` directory of your project. If you
don't have an `addons` directory at the root of the project, you'll have to
create one first.

[releases]: https://github.com/ephread/inkgd/releases

### Getting Started

*inkgd*'s documentation is hosted on [Read The Docs].

Feel free to take a look in the `example/` directory and run
`the_intercept.tscn`, which will play The Intercept.

Note: _inkgd_ has a .gitattributes file which makes sure that only
`addons/inkgd` is added to the Github archive. The only way to get the example
folder (and a bunch of other important files) is to clone the project.

[Read The Docs]: https://inkgd.readthedocs.io/en/latest/

## Compatibility Table

| _inkgd_ version | inklecate version |  Godot version  |
|:---------------:|:-----------------:|:---------------:|
|  0.1.0 – 0.1.4  |   0.8.2 – 0.8.3   |   3.1 – 3.2.1   |
|  0.2.0 – 0.2.1  |       0.9.0       |   3.1 – 3.2.1   |
|      0.2.2      |       0.9.0       |   3.2 – 3.2.3   |
|      0.2.3      |       0.9.0       |    3.2 – 3.4    |
|      0.3.0      |       1.0.0       |    3.2 – 3.4    |

## License

_inkgd_ is released under the MIT license. See LICENSE for details.
