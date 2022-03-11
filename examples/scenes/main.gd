# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

extends Control

func _ready():
	pass

func _switch_to_the_intercept():
	get_tree().change_scene("res://examples/scenes/the_intercept.tscn")

func _switch_to_crime_scene():
	get_tree().change_scene("res://examples/scenes/crime_scene.tscn")

func _switch_to_performance():
	get_tree().change_scene("res://test/performance/performance_test.tscn")

func _switch_to_gut():
	get_tree().change_scene("res://test/tests.tscn")
