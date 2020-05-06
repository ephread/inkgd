# warning-ignore-all:unused_class_variable
# ############################################################################ #
# Copyright © 2015-present inkle Ltd.
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends Node

# Expected to be added to the SceneTree as a singleton object.

# ############################################################################ #
# Imports
# ############################################################################ #

var StaticJson = load("res://addons/inkgd/runtime/static/json.gd")
var StaticNativeFunctionCall = load("res://addons/inkgd/runtime/static/native_function_call.gd")

# ############################################################################ #

var native_function_call = StaticNativeFunctionCall.new()
var json = StaticJson.new(native_function_call)

var should_interrupt = false

var dont_save_default_values = true

func _init():
    name = "__InkRuntime"
