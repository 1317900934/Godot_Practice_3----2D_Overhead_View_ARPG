extends Enemy_State

class_name Slime_Wander

# 动画名称引用
@export var anim_name: String = "move"
# 游荡速度
@export var wander_speed: float = 30.0

# 为后续导出属性设置为AI类别
@export_category("AI")
# 状态的持续时间
@export var state_anim_duration: float = 0.7
# 最大和最小状态循环次数(史莱姆跳跃移动的次数)
@export var state_cycles_min: int = 2;
@export var state_cycles_max: int = 5;
# 下一个状态
@export var next_state: Enemy_State


var _timer: float

var _direction: Vector2



# 初始化
func init() -> void:
	pass



# 进入状态
func enter():
	
	# 获取一个范围内的随机游荡次数
	_timer = randi_range(state_cycles_min, state_cycles_max) * state_anim_duration
	
	# 获取一个随机游荡方向
	var rand = randi_range(0, 3)
	
	# 将随机游荡方向赋值给方向变量
	_direction = enemy.DIR_4[rand]
	
	# 设置速度向量
	enemy.velocity = _direction * wander_speed
	
	# 设置随机方向
	enemy.set_direction(_direction)
	
	# 更新动画
	enemy.update_animation(anim_name)





# 退出状态
func exit():
	pass




# 持续处理函数
func update(_delta: float) -> Enemy_State:
	
	# 根据时间减少timer值
	_timer -= _delta
	
	# 如果计时器为0，等待处理帧后返回下一个状态
	if _timer <= 0:
		return next_state
	
	return null



# 物理持续处理函数
func physics_update(_delta: float) -> Enemy_State:
	return null
