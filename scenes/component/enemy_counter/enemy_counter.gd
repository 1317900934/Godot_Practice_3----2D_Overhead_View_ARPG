class_name Enemy_Counter
extends Node2D



signal enemies_defeated





func _ready() -> void:
	
	child_exiting_tree.connect(_on_enemy_destroyed)




# 所有敌人都被击败
func _on_enemy_destroyed(e: Node2D):
	
	if e is Enemy:
		if enemy_count() <= 1:
			enemies_defeated.emit()
			print("所有敌人都被击杀！")




# 获取敌人数量
func enemy_count() -> int:
	
	var _count = 0
	
	for c in get_children():
		if c is Enemy:
			_count += 1
	
	return _count
