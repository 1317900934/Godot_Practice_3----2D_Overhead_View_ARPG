class_name Heart_GUI
extends Control



@onready var sprite_2d: Sprite2D = $Sprite2D



var value: int = 2:
	# 设置value时，更新精灵帧，显示空心、半空心或实心
	set(_value):
		value = _value
		update_sprite()



func update_sprite():
	sprite_2d.frame = value
