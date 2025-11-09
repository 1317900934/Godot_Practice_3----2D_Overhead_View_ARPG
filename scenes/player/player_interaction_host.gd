class_name Player_Interaction_Host
extends Node2D



@onready var player: Player = $".."
@onready var grapple_ray_cast: RayCast2D = %Grapple_RayCast



func _ready() -> void:
	# 连接玩家的方向改变信号
	player.direction_changed.connect(_update_derection)



# 更新交互方向
func _update_derection(new_dir: Vector2):
	
	match new_dir:
		Vector2.DOWN:
			rotation_degrees = 0
			grapple_ray_cast.position = Vector2.ZERO
		Vector2.UP:
			rotation_degrees = 180
			grapple_ray_cast.position = Vector2.ZERO
		Vector2.LEFT:
			rotation_degrees = 90
			grapple_ray_cast.position.x = -5
		Vector2.RIGHT:
			rotation_degrees = -90
			grapple_ray_cast.position.x = 5
	
