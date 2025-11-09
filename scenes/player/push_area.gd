extends Area2D




func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)






func _on_body_entered(b: Node2D):
	if b is Pushable_Statue:
		b.push_direction = PlayerManager.player.direction



func _on_body_exited(b: Node2D):
	if b is Pushable_Statue:
		b.push_direction = Vector2.ZERO
