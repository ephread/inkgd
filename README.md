# ![inkgd](https://i.imgur.com/QbLG9Xp.png)

[![build](https://github.com/ephread/inkgd/workflows/build/badge.svg)](https://github.com/ephread/inkgd/actions)
[![Documentation Status](https://readthedocs.org/projects/inkgd/badge/?version=latest)](https://inkgd.readthedocs.io/en/latest/?badge=latest)
![Version](https://img.shields.io/badge/version-0.6.0-orange.svg)
![Godot Version](https://img.shields.io/badge/godot-3.3+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

Implementation of [inkle’s Ink] in pure GDScript, with editor support.

📖 **Note:** _inkgd_ shines for rapid prototyping in GDScript and small games.
While the runtime implementation is feature-complete and passes the
test suite, it’s slower than the original C# implementation. It is used
in commercial games, but if you need a faster solution and don’t mind C#,
you should consider using [godot-ink].

> [!IMPORTANT]
> _inkgd_ is compatible with Godot 4.1+, but has not official release yet.
> To use _inkgd_ with Godot 4.1+, fetch the [`godot4`] branch.

[`godot4`]: https://github.com/ephread/inkgd/tree/godot4
[inkle’s Ink]: https://github.com/inkle/ink
[godot-ink]: https://github.com/paulloz/godot-ink

## Table of contents

  * [Features](#features)
  * [Requirements](#requirements)
  * [Contributing](#asking-questions--contributing)
      * [Asking Questions](#asking-questions)
      * [Contributing](#contributing)
  * [Installation & Getting Started](#installation--getting-started)
  * [Editor Plugin](#editor-plugin)
  * [Compatibility Table](#compatibility-table)
  * [Acknowledgement](#acknowledgement)
      * [Code](#code)
      * [Ink Stories](#ink-stories)
  * [License](#license)

## Features
- [x] Fully-featured Ink runtime
- [x] Advanced editor features
	- [x] Automatic recompilation of managed stories
	- [x] Integrated story previewer

## Requirements
- Godot 4.1.1+
- Inklecate 1.1.1+

## Asking Questions / Contributing

### Asking questions

If you need help with something, [start a discussion].
If you want to report a problem, [open an issue].

[start a discussion]: https://github.com/ephread/inkgd/discussions/new
[open an issue]: https://github.com/ephread/inkgd/issues/new/choose

### Contributing

If you want to contribute, be sure to take a look at [the contributing guide].

[the contributing guide]: https://github.com/ephread/inkgd/blob/master/CONTRIBUTING.md

## Installation & Getting Started

*inkgd* is available on Godot's [Asset Library]. The full documentation is
hosted on [Read The Docs].

[Asset Library]: http://godotengine.org/asset-library/asset/349
[Read The Docs]: https://inkgd.readthedocs.io/en/stable/

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
|  0.4.0 – 0.4.7  |       1.0.0       |    3.3 – 3.5    |
|      0.5.0      |       1.1.1       |    3.3 – 3.5    |
|      0.6.0      |       1.1.1       |      4.1.1      |

## Acknowledgement

### Code

- _inkgd_ is based on the [original C# implementation], released under the
  MIT license, copyright inkle Ltd.
- _inkgd_ uses code ported from [godot-ink], released under the MIT license,
  copyright Paul Joannon.

[original C# implementation]: https://github.com/inkle/ink/blob/master/LICENSE.txt
[godot-ink]: https://github.com/paulloz/godot-ink/blob/master/LICENSE

### Ink Stories

- [_The Intercept_] and [_Crime Scene_], released under the MIT license,
  copyright inkle Ltd. The sample project uses slightly modified versions of
  these two stories.
- [_LD41 Emoji_], released under the MIT license, copyright Pat Scott.
- [_Not a halloween game_], released under the MIT license, copyright Samuel
  Sarette and Zachary Sarette.

[_The Intercept_]: https://github.com/inkle/ink-library/tree/master/Stories/The%20Intercept
[_Crime Scene_]: https://github.com/inkle/ink/blob/master/Documentation/WritingWithInk.md#7-long-example-crime-scene
[_LD41 Emoji_]: https://github.com/inkle/ink-library/tree/master/Stories/LD41%20Emoji
[_Not a halloween game_]: https://github.com/lunarcloud/not-a-halloween-game

### Documentation & Tutorials

- @videlanicolas started the documentation project on ReadTheDocs.
- Nicholas O'Brien did a whole [video series] about inkgd & Godot.

[video series]: https://www.youtube.com/playlist?list=PLtepyzbiiwBrHoTloHJ2B-DWQxgrseuMB

## Sponsors

[![WILD WITS Games](docs/source/img/wild_wits_logo.webp)](https://wildwits.games)

## License

_inkgd_ is released under the MIT license. See LICENSE for details.
