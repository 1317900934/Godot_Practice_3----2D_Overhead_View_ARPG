class_name Barred_Door
extends Node2D


@onready var animation_player: AnimationPlayer = $AnimationPlayer







func open_door():
	animation_player.play("open_door")




func close_door():
	animation_player.play("close_door")
