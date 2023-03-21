# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends "res://test/integration/player/test_base.gd"

# These tests serve little purpose in classic Godot but are critical in
# Godot Mono to ensure Ink Lists and Paths are properly converted back and
# forth between GDScript and C#.

# ############################################################################ #
# Methods
# ############################################################################ #

func test_ink_list_simple_roundtrip() -> void:
	await _load_story("ink_list_roundtrip")

	_test_simple_list_validity()

	var newTastyBreads = InkList.new_with_ink_list(_ink_player.get_variable("tastyBreads"))
	var newTastyPastas = InkList.new_with_ink_list(_ink_player.get_variable("tastyPastas"))
	var newTastyMealItems = InkList.new_with_ink_list(_ink_player.get_variable("tastyMealItems"))

	_ink_player.set_variable("tastyBreads", newTastyBreads)
	_ink_player.set_variable("tastyPastas", newTastyPastas)
	_ink_player.set_variable("tastyMealItems", newTastyMealItems)

	_test_simple_list_validity()


func test_ink_path_simple_roundtrip() -> void:
	await _load_story("ink_list_roundtrip")

	_test_ink_path_validity()

	var coolPath = _ink_player.get_variable("coolDivert") as InkPath
	var newCoolPath: InkPath = InkPath.new_with_components_string(coolPath.components_string)
	_ink_player.set_variable("coolDivert", newCoolPath)

	_test_ink_path_validity()


# ############################################################################ #
# Private Methods
# ############################################################################ #

func _test_simple_list_validity():
	var tastyBreads = _ink_player.get_variable("tastyBreads") as InkList
	var tastyPastas = _ink_player.get_variable("tastyPastas") as InkList
	var tastyMealItems = _ink_player.get_variable("tastyMealItems") as InkList

	assert_eq(tastyBreads.origins.size(), 1)
	assert_eq(tastyBreads.origins[0].name, "breads")

	assert_eq(tastyBreads.ordered_items[0].key.full_name, "breads.Brioche")
	assert_eq(tastyBreads.ordered_items[0].value, 3)
	assert_eq(tastyBreads.ordered_items[1].key.full_name, "breads.Fougasse")
	assert_eq(tastyBreads.ordered_items[1].value, 4)
	assert_eq(tastyBreads.ordered_items[2].key.full_name, "breads.PainDeCampagne")
	assert_eq(tastyBreads.ordered_items[2].value, 5)

	assert_eq(tastyPastas.origins.size(), 1)
	assert_eq(tastyPastas.origins[0].name, "pastas")

	assert_eq(tastyPastas.ordered_items[0].key.full_name, "pastas.Penne")
	assert_eq(tastyPastas.ordered_items[0].value, 1)
	assert_eq(tastyPastas.ordered_items[1].key.full_name, "pastas.Spaghetti")
	assert_eq(tastyPastas.ordered_items[1].value, 2)
	assert_eq(tastyPastas.ordered_items[2].key.full_name, "pastas.Ravioli")
	assert_eq(tastyPastas.ordered_items[2].value, 5)

	assert_eq(tastyMealItems.origins.size(), 3)
	assert_true(["breads", "pastas", "drinks"].has(tastyMealItems.origins[0].name))
	assert_true(["breads", "pastas", "drinks"].has(tastyMealItems.origins[1].name))
	assert_true(["breads", "pastas", "drinks"].has(tastyMealItems.origins[2].name))

	assert_eq(tastyMealItems.ordered_items[0].key.full_name, "breads.Baguette")
	assert_eq(tastyMealItems.ordered_items[0].value, 1)
	assert_eq(tastyMealItems.ordered_items[1].key.full_name, "drinks.StillWater")
	assert_eq(tastyMealItems.ordered_items[1].value, 1)
	assert_eq(tastyMealItems.ordered_items[2].key.full_name, "drinks.SparklingWater")
	assert_eq(tastyMealItems.ordered_items[2].value, 2)
	assert_eq(tastyMealItems.ordered_items[3].key.full_name, "pastas.Macaroni")
	assert_eq(tastyMealItems.ordered_items[3].value, 4)
	assert_eq(tastyMealItems.ordered_items[4].key.full_name, "pastas.Ravioli")
	assert_eq(tastyMealItems.ordered_items[4].value, 5)


func _test_ink_path_validity():
	var coolPath = _ink_player.get_variable("coolDivert") as InkPath
	assert_eq(coolPath.components_string, "knot1.stitch1.0.gather1")
