# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://addons/gut/test.gd"

func test_paths():
	var path1 = InkPath.new_with_components_string("hello.1.world")
	var path2 = InkPath.new_with_components_string("hello.1.world")

	var path3 = InkPath.new_with_components_string(".hello.1.world")
	var path4 = InkPath.new_with_components_string(".hello.1.world")

	assert_true(path1.equals(path2))
	assert_true(path3.equals(path4))
	assert_false(path1.equals(path3))
