class_name Quest_Step_Item
extends Control


@onready var label: Label = $Label
@onready var sprite: Sprite2D = $Sprite2D



func initialize(step: String, is_complete: bool):
	label.text = step
	if is_complete == true:
		sprite.frame = 1
	else:
		sprite.frame = 0
