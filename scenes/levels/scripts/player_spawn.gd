extends Node2D




func _ready() -> void:
	
	visible = false
	
	PlayerManager.set_player_pos_to_spawn.connect(set_player_pos)
	
	# 如果玩家未生成，就设置玩家的生成位置为自己的位置，并声明玩家已生成
	if not PlayerManager.player_spawned:
		set_player_pos()
		PlayerManager.player_spawned = true
	




func set_player_pos():
	PlayerManager.set_player_position(global_position)
