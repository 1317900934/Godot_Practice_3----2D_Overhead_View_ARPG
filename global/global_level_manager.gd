extends Node

# 加载关卡开始信号
signal level_load_started
# 加载关卡完毕信号
signal level_loaded
# 地图边界范围改变信号
signal tilemap_bound_change(bounds: Array[Vector2])
# 场景开始转换信号
signal level_transform_start


# 当前瓦片地图边界范围
var current_tilemap_bounds: Array[Vector2]
# 目标过渡区域
var target_transform: String
# 目标位置偏移量
var position_offset: Vector2




func _ready() -> void:
	# 等待处理帧
	await get_tree().process_frame
	# 发射关卡加载完毕信号
	level_loaded.emit()





# 进入地图场景时调用，更新边界范围并发射范围信号
func change_tilemap_bounds(bounds: Array[Vector2]):
	current_tilemap_bounds = bounds
	tilemap_bound_change.emit(bounds)




# 准备加载新关卡
func load_new_level(
	level_path: String,
	_target_transform: String,
	_position_offset: Vector2
):
	
	# 发射场景开始转换信号
	level_transform_start.emit()
	
	# 关闭boss生命条
	PlayerHud.hide_boss_bar()
	
	# 暂停游戏避免切换场景时出错
	get_tree().paused = true
	
	# 获取传入的目标区域和位置偏移量
	target_transform = _target_transform
	position_offset = _position_offset
	
	# 等待转场开始动画播放完毕
	await SceneTransition.transform_start()
	
	# 发射加载开始信号
	level_load_started.emit()
	
	# 等待处理帧结束
	await get_tree().process_frame
	
	# 切换场景为路径场景
	get_tree().change_scene_to_file(level_path)
	
	# 等待转场结束动画播放完毕
	SceneTransition.transform_end()
	await SceneTransition.transform_finish
	
	# 继续运行游戏
	get_tree().paused = false
	
	# 等待处理帧结束
	await get_tree().process_frame
	
	# 发射加载完毕信号
	level_loaded.emit()
