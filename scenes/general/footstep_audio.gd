class_name Footstep_Audio
extends AudioStreamPlayer2D


@export var footstep_sfx: Array[AudioStream]


var stream_randomizer: AudioStreamRandomizer





func _ready() -> void:
	stream_randomizer = stream





func play_footstep():
	get_footstep_type()
	play()



# 获取分组中的图块集并调整当前脚步声类型
func get_footstep_type():
	
	for t in get_tree().get_nodes_in_group("tilemaps"):
		if t is TileMapLayer:
			# 如果图块集没有脚步声类型数据，就跳过
			if t.tile_set.get_custom_data_layer_by_name("footstep_type") == -1:
				continue
			# 获取图块的全局坐标
			var cell: Vector2i = t.local_to_map(t.to_local(global_position))
			# 获取目标图块的信息
			var data: TileData = t.get_cell_tile_data(cell)
			
			if data != null:
				var type = data.get_custom_data("footstep_type")
				if type == null:
					continue
				stream_randomizer.set_stream(0, footstep_sfx[type])
