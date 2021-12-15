# ![inkgd](https://i.imgur.com/QbLG9Xp.png)

[![build](https://github.com/ephread/inkgd/workflows/build/badge.svg)](https://github.com/ephread/inkgd/actions)
[![Documentation Status](https://readthedocs.org/projects/inkgd/badge/?version=latest)](https://inkgd.readthedocs.io/en/latest/?badge=latest)
![Version](https://img.shields.io/badge/version-0.3.0-orange.svg)
![Godot Version](https://img.shields.io/badge/godot-3.1+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

Implementation of [inkle’s Ink] in pure GDScript, with editor support.

⚠️ **Note:** While the implementation of the runtime is feature-complete and
passes the test suite, it’s unlikely to ever be considered “production-ready”.
_inkgd_ shines for rapid-prototyping in GDScript and small games, but for bigger
projects it’s likely to be too slow. If you need a more bulletproof solution
and don’t mind C#, you should consider using [godot-ink].

[inkle’s Ink]: https://github.com/inkle/ink
[godot-ink]: https://github.com/paulloz/godot-ink

## Table of contents

  * [Features](#features)
  * [Requirements](#requirements)
  * [Contributing](#asking-questions--contributing)
      * [Asking Questions](#asking-questions)
      * [Contributing](#contributing)
  * [Installation](#installation)
  * [Usage](#usage)
      * [Example Project](#runtime)
      * [Editor Plugin](#editor)
  * [Compatibility Table](#compatibility-table)
  * [Acknowledgment](#acknowledgment)
      * [Code](#code)
      * [Stories](#stories)
  * [License](#license)

## Features
- [x] Fully-featured Ink runtime
- [x] Advanced editor features
	- [x] Automatic recompilation of managed stories
	- [x] Integrated story previewer

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

## Installation & Getting Started

*inkgd* is available on Godot's [Asset Library]. The full documentation is hosted on [Read The Docs].

[Asset Library]: http://godotengine.org/asset-library/asset/349
[Read The Docs]: https://inkgd.readthedocs.io/en/latest/

## Editor Plugin

![Ink panel demo](docs/source/advanced/editor_plugin/img/ink_panel/ink_panel.gif)

## Compatibility Table

| _inkgd_ version | inklecate version |  Godot version  |
|:---------------:|:-----------------:|:---------------:|
|  0.1.0 – 0.1.4  |   0.8.2 – 0.8.3   |   3.1 – 3.2.1   |
|  0.2.0 – 0.2.1  |       0.9.0       |   3.1 – 3.2.1   |
|      0.2.2      |       0.9.0       |   3.2 – 3.2.3   |
|      0.2.3      |       0.9.0       |    3.2 – 3.4    |
|      0.3.0      |       1.0.0       |    3.2 – 3.4    |

## Acknowledgement

### Code

- _inkgd_ is based on the [original C# implementation], released under the
  MIT license, copyright inkle Ltd.
- _inkgd_ uses code ported from [godot-ink], released under the MIT license,
  copyright Paul Joannon.

[original C# implementation]: https://github.com/inkle/ink/blob/master/LICENSE.txt
[godot-ink]: https://github.com/paulloz/godot-ink/blob/master/LICENSE

### Ink Stories

- [_The Intercept_] is released under the MIT license, copyright inkle Ltd.
  The sample project uses a slightly modified version.
- [_LD41 Emoji_] is released under the MIT license, copyright Pat Scott.
- [_Not a halloween game_] is released under the MIT license, copyright Samuel
  Sarette and Zachary Sarette.

[_The Intercept_]: https://github.com/inkle/ink-library/tree/master/Stories/The%20Intercept
[_LD41 Emoji_]: https://github.com/inkle/ink-library/tree/master/Stories/LD41%20Emoji
[_Not a halloween game_]: https://github.com/lunarcloud/not-a-halloween-game

## License

_inkgd_ is released under the MIT license. See LICENSE for details.




