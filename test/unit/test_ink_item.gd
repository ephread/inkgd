# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://addons/gut/test.gd"

func test_serialisation():
	var list_item = InkListItem.new_with_origin_name("foo", "bar")
	var serialized_list_item = list_item.serialized()

	var deserialized_list_item = InkListItem.from_serialized_key(serialized_list_item)

	assert_eq(deserialized_list_item.origin_name, "foo")
	assert_eq(deserialized_list_item.item_name, "bar")
