@tool
extends NPC_Behavior


const DIRECTIONS = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]


# 漫游范围
@export var wander_range: int = 2: set = _set_wander_range
# 漫游速度
@export var wander_speed: float = 40.0
# 漫游时间
@export var wander_duration: float = 1.0
# 空闲时间
@export var idle_duration: float = 1.0





@onready var collision_shape: CollisionShape2D = $CollisionShape2D






# 节点初始位置
var original_pos: Vector2







func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	super()
	
	collision_shape.queue_free()
	
	original_pos = npc.global_position







func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	# 如果npc离开圈定范围，就朝相反方向移动，使npc返回
	#if abs(global_position.distance_to(original_pos)) > wander_range * 32:
		#npc.velocity *= -1
		#npc.direction *= -1
		#npc.update_dir(global_position + npc.direction)
		#npc.update_anim()









func start():
	
	# 空闲阶段
	if npc.do_behavior == false:
		return
	
	npc.state = "idle"
	npc.velocity = Vector2.ZERO
	npc.update_anim()
	# 等待一定时间再进入下一个状态阶段
	await get_tree().create_timer(randf() * idle_duration + idle_duration * 0.5).timeout
	
	
	
	
	
	# 漫游阶段
	if npc.do_behavior == false:
		return
	
	npc.state = "walk"
	var _dir: Vector2 = DIRECTIONS[randi_range(0, 3)]
	
	# 如果npc离开圈定范围,就朝最佳方向返回
	if abs(global_position.distance_to(original_pos)) > wander_range * 32:
		var dir_to_area: Vector2 = global_position.direction_to(original_pos)
		var best_dir: Array[float]
		# 遍历所有移动方向，添加到最佳方向数组，数值最大的就是最佳方向
		for d in DIRECTIONS:
			best_dir.append(d.dot(dir_to_area))
		# 更新方向为最佳方向
		_dir = DIRECTIONS[best_dir.find(best_dir.max())]
	
	npc.direction = _dir
	npc.velocity = _dir * wander_speed
	npc.update_dir(global_position + _dir)
	npc.update_anim()
	# 等待一定时间再进入下一个状态阶段
	await get_tree().create_timer(randf() * wander_duration + wander_duration * 0.5).timeout
	
	
	
	
	
	# 重复阶段
	if npc.do_behavior == false:
		return
	
	start()









# 设置漫游范围时同步修改碰撞区域范围
func _set_wander_range(value: int):
	wander_range = value
	if collision_shape:
		collision_shape.shape.radius = value * 32.0
