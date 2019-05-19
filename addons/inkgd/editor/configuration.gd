# ############################################################################ #
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

extends Object

const _ROOT_DIR = "res://addons/inkgd/"
const _EDITOR_ROOT_DIR = _ROOT_DIR + "editor/"

# ############################################################################ #
# Properties
# ############################################################################ #

var mono_path: String = ""
var inklecate_path: String = ""
var source_file_path: String = ""
var target_file_path: String = ""

# ############################################################################ #
# Private Properties
# ############################################################################ #

var _config_file = ConfigFile.new()

# ############################################################################ #
# Overrides
# ############################################################################ #

func _init():
    retrieve()

# ############################################################################ #
# Public Methods
# ############################################################################ #

func retrieve():
    var config_path = _EDITOR_ROOT_DIR + "inkgd.cfg"

    var err = _config_file.load(config_path)
    if err != OK:
        # Assuming it doesn't exist.
        mono_path = ""
        inklecate_path = ""
        source_file_path = ""
        target_file_path = ""
        return


    mono_path = _config_file.get_value("ink", "mono_path", "")
    inklecate_path = _config_file.get_value("ink", "inklecate_path", "")
    source_file_path = _config_file.get_value("ink", "source_file_path", "")
    target_file_path = _config_file.get_value("ink", "target_file_path", "")

func persist():
    _config_file.set_value("ink", "mono_path", mono_path)
    _config_file.set_value("ink", "inklecate_path", inklecate_path)
    _config_file.set_value("ink", "source_file_path", source_file_path)
    _config_file.set_value("ink", "target_file_path", target_file_path)

    var config_path = _EDITOR_ROOT_DIR + "inkgd.cfg"
    var err = _config_file.save(config_path)
    if err != OK:
        printerr("Could not save: " + config_path)
