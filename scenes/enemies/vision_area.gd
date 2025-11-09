class_name Vision_Area
extends Area2D


signal  player_entered()
signal  player_exited()



func _ready() -> void:
	body_entered.connect(_on_area_enter)
	body_exited.connect(_on_area_exit)
	
	var p = get_parent()
	
	if p is Enemy:
		p.direction_changed.connect(_on_direction_change)





func _on_area_enter(_b: Node2D):
	
	if _b is Player:
		player_entered.emit()
	





func _on_area_exit(_b: Node2D):
	
	
	if _b is Player:
		player_exited.emit()
		





func _on_direction_change(new_dir: Vector2):
	match new_dir:
		Vector2.DOWN:
			rotation_degrees = 0
		Vector2.UP:
			rotation_degrees = 180
		Vector2.LEFT:
			rotation_degrees = 90
		Vector2.RIGHT:
			rotation_degrees = -90
		_:
			rotation_degrees = 0
