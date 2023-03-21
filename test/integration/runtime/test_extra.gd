# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://test/integration/runtime/test_base.gd"

# ############################################################################ #

func test_list_comparison():
	var story = InkStory.new(load_file("list_comparison"))

	assert_eq(story.continue_maximally(), "Hey, my name is Philippe. What about yours?\nI am Andre and I need my rheumatism pills!\nWould you like me, Philippe, to get some more for you?\n")

# ############################################################################ #

func _prefix():
	return "runtime/extra/"
