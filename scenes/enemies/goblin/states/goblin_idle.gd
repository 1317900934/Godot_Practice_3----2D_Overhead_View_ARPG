extends Enemy_State

class_name Goblin_Idle

# 动画名称引用
@export var anim_name: String = "idle"
# 为后续导出属性设置为AI类别
@export_category("AI")
# 状态的最小持续时间
@export var state_duration_min: float = 0.5
# 状态的最大持续时间
@export var state_duration_max: float = 2.0
# 空闲状态结束后应该进入的状态
@export var after_idle_state: Enemy_State


var _timer: float




# 初始化
func init() -> void:
	pass



# 进入状态
func enter():
	# 停止移动
	enemy.velocity = Vector2.ZERO
	# 取一个范围内的随机时间
	_timer = randf_range(state_duration_min, state_duration_max)
	# 更新敌人动画，传入动画名称
	enemy.update_animation(anim_name)




# 退出状态
func exit():
	pass




# 持续处理函数
func update(_delta: float) -> Enemy_State:
	
	# 根据时间减少timer值
	_timer -= _delta
	
	# 如果计时器为0，返回空闲状态结束后应该进入的状态
	if _timer <= 0:
		return after_idle_state
	
	return null



# 物理持续处理函数
func physics_update(_delta: float) -> Enemy_State:
	return null
