# Change Log
Important changes to _inkgd_ will be documented in this file.

## [0.6.0](https://github.com/ephread/inkgd/releases/tag/0.6.0)
Released on 2023-XX-XX.

### Added
- Added support for Godot 4.1.1+

### Changed

#### ⚠️ **BREAKING CHANGE**
- Reorganized files internally and updated type names.
- [`InkStory`] Renamed `continue`, `continue_async` and `continue_maximally` to
  `continue_story`, `continue_story_async` and `continue_story_maximally` due to keyword conflicts.
- [`InkVariableStates`] Renamed `get` and `set` to `get_variable` and `set_variable` due to keyword conflicts.
- [`InkPlayer`] Renamed `continue`, `continue_async`, `continue_maximally`, `get` and `set` to
  `continue_story`, `continue_story_async`, `continue_story_maximally`, `get_variable` and `set_variable` due to keyword conflicts.

## [0.5.0](https://github.com/ephread/inkgd/releases/tag/0.5.0)
Released on 2023-08-28.

### Changed
- Added support for inklecate 1.1.1.
- Exposed new properties on InkPlayer (`alive_flow_names` & `current_flow_is_default_flow`).

#### ⚠️ **BREAKING CHANGE**
- [`InkPlayer`] The `prompt_choices` and `choice_made` signals as well as the `current_choices`
  property now use instances of `InkChoice` instead of strings. Use the `text` property of `InkChoice`
  to access the text representation.

## [0.4.7](https://github.com/ephread/inkgd/releases/tag/0.4.7)
Released on 2022-08-07.

### Fixed
- Added missing `add_child` call in templates.

## [0.4.6](https://github.com/ephread/inkgd/releases/tag/0.4.6)
Released on 2022-07-31.

### Added
- Added new tests for InkPlayer.
- Error management in documentation.

### Changed
- Remove `examples/` from the list of excluded directory when archiving from GitHub.

### Fixed
- Fixed [#58] – InkRuntime not found when exporting for the web. (thanks [@GreenCloversGames]!)
- Fixed [#60] – Rename `choose_path_string` to `choose_path` in documentation. (thanks [@bram-dingelstad]!)

[#58]: https://github.com/ephread/inkgd/issues/58
[#60]: https://github.com/ephread/inkgd/issues/60
[@GreenCloversGames]: https://github.com/GreenCloversGames
[@bram-dingelstad]: https://github.com/bram-dingelstad

## [0.4.5](https://github.com/ephread/inkgd/releases/tag/0.4.5)
Released on 2022-03-11.

### Added
- Exposed more ink APIs in InkPlayer.
- Added 'current_path' getter in InkPlayer, thanks [@francoisdlt]!
- Added inkgd vs. godot-ink documentation page.

[@francoisdlt]: https://github.com/francoisdlt

## [0.4.4](https://github.com/ephread/inkgd/releases/tag/0.4.4)
Released on 2022-01-26.

### Fixed
- Fixed numerous typos and minor issues in the editor plugin.
- Fixed incorrect runtime paths in documentation.
- Fixed incorrect type annotation causing crashes.

## [0.4.3](https://github.com/ephread/inkgd/releases/tag/0.4.3)
Released on 2022-01-08.

### Fixed
- Broken file dialog in configuration panel.
- Broken progress dialog when the editor is run at <200% scales.

## [0.4.2](https://github.com/ephread/inkgd/releases/tag/0.4.2)
Released on 2022-01-03.

### Changed
- Changed InkPlayer's API.
- Improved example project by adding a navigation hub.
- Made InkPointer immutable rather than duplicating all the time.

### Added
- Added ability to create an InkList from InkPlayer.
- Added new tests.
- Added support for Godot Mono, turning inkgd into a thin wrapper over the
  original C# implementation. The feature is experimental and not yet
  documented, it will be documented in 0.5.0.

## [0.4.1](https://github.com/ephread/inkgd/releases/tag/0.4.1)
Released on 2021-12-26.

### Fixed
- Fixed an issue preventing custom nodes from being unregistered upon
  deactivation of the plugin.

### Changed
- Improved the naming of InkRuntime's properties.
- Improved error reporting.
- Improved InkPlayer's API by introducing a new type, InkFunctionResult.

## [0.4.0](https://github.com/ephread/inkgd/releases/tag/0.4.0)
Released on 2021-12-20.

### Changed
- Rewrote the editor plugin.
- Moved the panel to the bottom panel.

### Added
- Added `InkPlayer` a new convenience node to play Ink stories.
- Added a preview tab in the editor panel.
- Added support for multiple stories.
- Added support for JSON files, treating them as resources.
- Added a new documentation hosted on ReadTheDocs, thanks [@videlanicolas]!

[@videlanicolas]: https://github.com/videlanicolas

### Fixed
- Fixed [#51] – Typo in *story_state.gd* (`Path` -> `InkPath`),
  thanks [@cesarizu]!

[#51]: https://github.com/ephread/inkgd/pull/51
[@cesarizu]: https://github.com/cesarizu

## [0.3.0](https://github.com/ephread/inkgd/releases/tag/0.3.0)
Released on 2021-11-27.

### Changed
- Added support for inklecate 1.0.0

## [0.2.3](https://github.com/ephread/inkgd/releases/tag/0.2.3)
Released on 2021-11-14.

### Fixed
- Partially fixed [#29] – Loading a story state doesn't rollback the error stack.
- Fixed [#36] – Mutiple problems in setting panel. (Huge thanks @videlanicolas!)
- Fixed [#38] – Crash in example project. (Huge thanks @videlanicolas!)

[#29]: https://github.com/ephread/inkgd/issues/29
[#36]: https://github.com/ephread/inkgd/issues/36
[#38]: https://github.com/ephread/inkgd/issues/28

## [0.2.2](https://github.com/ephread/inkgd/releases/tag/0.2.2)
Released on 2021-01-31.

### Changed
- Made runtime & story error more explicit.

## [0.2.1](https://github.com/ephread/inkgd/releases/tag/0.2.1)
Released on 2020-06-17.

### Fixed
- Multiple memory leaks have been plugged.

## [0.2.0](https://github.com/ephread/inkgd/releases/tag/0.2.0)
Released on 2020-05-07.

### Changed
- Added support for inklecate 0.9.0

## [0.1.4](https://github.com/ephread/inkgd/releases/tag/0.1.4)
Released on 2020-04-11.

### Fixed
- Fixed [#12] – Combined lists and functions don't work as intended.
- Fixed [#13] – Multiline functions are executed all at once.

[#12]: https://github.com/ephread/inkgd/issues/12
[#13]: https://github.com/ephread/inkgd/issues/13

## [0.1.3](https://github.com/ephread/inkgd/releases/tag/0.1.3)
Released on 2019-10-10.

### Fixed
- Fixed [#10] – Node not found error InkRuntime.init(). (Huge thanks @MageJohn!)

[#10]: https://github.com/ephread/inkgd/issues/10

## [0.1.2](https://github.com/ephread/inkgd/releases/tag/0.1.2)
Released on 2019-05-23.

### Fixed
- Fixed [#2] – Missing code preventing ink compilation from working on Windows.

[#2]: https://github.com/ephread/inkgd/issues/2

## [0.1.1](https://github.com/ephread/inkgd/releases/tag/0.1.1)
Released on 2019-05-19.

### Changed
- Changed the configuration system in two ways: store local paths when it makes sense and split the configuration into two files.

## [0.1.0](https://github.com/ephread/inkgd/releases/tag/0.1.0)
Released on 2019-05-19.

### Added
- Initial release of _inkgd_.
