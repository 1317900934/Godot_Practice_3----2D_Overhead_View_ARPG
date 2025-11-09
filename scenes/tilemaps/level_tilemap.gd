class_name  Level_Tilemap
extends TileMapLayer


@export var tile_size: int = 32


func _ready() -> void:
	
	# 初始化时，计算地图范围，然后调用全局脚本的改变地图返回函数

	LevelManager.change_tilemap_bounds( get_tilemap_bounds() )





# 获取瓦片地图边界范围
func get_tilemap_bounds() -> Array[Vector2]:
	
	var bounds: Array[Vector2] = []
	
	
	# 添加第一个向量(瓦片地图左上角)
	bounds.append(
		Vector2(get_used_rect().position * tile_size) + position
	)
	
	# 添加第二个向量(瓦片地图右下角)
	bounds.append(
		Vector2(get_used_rect().end * tile_size) + position
	)
	 
	return bounds
