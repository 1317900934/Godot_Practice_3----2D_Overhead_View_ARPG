class_name Path_Finder
extends Node2D



# 顺时针设定8个可以走的方向向量
var vectors: Array[Vector2] = [
	Vector2(0, -1),
	Vector2(1, -1),
	Vector2(1, 0),
	Vector2(1, 1),
	Vector2(0, 1),
	Vector2(-1, 1),
	Vector2(-1, 0),
	Vector2(-1, -1)
]

# 可能朝哪个点移动的兴趣大小
var interests: Array[float]
# 障碍物判定分
var obstacles: Array[float] = [0, 0, 0, 0, 0, 0, 0, 0]
# 最终结果得分
var outcomes: Array[float] = [0, 0, 0, 0, 0, 0, 0, 0]
# 所有障碍检测射线
var rays: Array[RayCast2D]

#移动方向
var move_dir: Vector2 = Vector2.ZERO
#最佳移动方向
var best_path: Vector2 = Vector2.ZERO




@onready var timer: Timer = $Timer





func _ready() -> void:
	
	# 获取所有障碍检测射线
	for c in get_children():
		if c is RayCast2D:
			rays.append(c)
	
	# 归一化所有方向向量
	for v in vectors:
		v.normalized()
	
	set_path()
	
	# 每隔一段时间更新一下路径数据
	timer.timeout.connect(set_path)







func _process(delta: float) -> void:
	# 线性插值使移动方向逐渐变为最佳方向，而不是立刻变为最佳方向
	move_dir = lerp(move_dir, best_path, 10 * delta)







# 更新方向
func set_path():
	
	# 获取朝向玩家的向量
	var player_dir: Vector2 = global_position.direction_to(PlayerManager.player.global_position)
	
	# 重置障碍物距离和结果距离
	for i in 8:
		obstacles[i] = 0
		outcomes[i] = 0
	
	# 遍历所有射线，如果某方向射线碰撞到障碍，就给此方向加4分，并给临近的两个方向加1分
	for i in 8:
		if rays[i].is_colliding():
			obstacles[i] += 4
			obstacles[get_next_i(i)] += 1
			obstacles[get_prev_i(i)] += 1
	
	# 如果最大障碍物判定分为0，说明没有障碍物，那么设置最佳方向为朝向玩家的向量并直接返回
	if obstacles.max() == 0:
		best_path = player_dir
		return
	
	
	# 清空兴趣点
	interests.clear()
	
	# 遍历所有向量，根据玩家方向添加对应朝向的兴趣大小
	for v in vectors:
		interests.append(v.dot(player_dir))
	
	# 某方向的结果得分等于兴趣大小减去障碍物判定分
	for i in 8:
		outcomes[i] = interests[i] - obstacles[i]
	
	# 设置结果中最高得分索引位的方向为最佳移动方向
	best_path = vectors[outcomes.find(outcomes.max())]
	













# 获取下一个i值，不大于8
func get_next_i(i: int) -> int:
	var n_i: int = i+1
	if n_i >= 8:
		return 0
	else:
		return n_i



# 获取上一个i值，不小于0
func get_prev_i(i: int) -> int:
	var n_i: int = i-1
	if n_i < 0:
		return 7
	else:
		return n_i
