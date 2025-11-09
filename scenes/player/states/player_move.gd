extends State

class_name Player_Walk

# 移动速度
@export var move_speed: float = 200.0
# 空闲状态引用
@export var state_idle: State
# 攻击状态引用
@export var state_attack: State
# 冲刺状态引用
@export var state_dash: State




var equipment_speed: float = 0


# 进入状态
func enter():
	# 调用绑定的角色的更新动画方法，传入move状态名
	character.update_animation("move")
	# 获取装备移速加成
	equipment_speed =  float(character.move_speed_bonus)



# 退出状态
func exit():
	pass




# 持续处理函数
func update(_delta: float) -> State:
	# 如果角色的方向向量为0，就返回空闲状态
	if character.move_direction == Vector2.ZERO:
		return state_idle
	
	# 持续将角色的移动向量乘以移动速度赋值给角色的速度向量，施加移动
	character.velocity = character.move_direction * (move_speed + equipment_speed)
	
	# 如果设置方向函数返回true，就更新动画
	if character.set_direction():
		character.update_animation("move")
	
	
	return null




# 物理持续处理函数
func physics_update(_delta: float) -> State:
	return null




# 处理输入事件
func handle_input(_event: InputEvent) -> State:
	
	# 如果按下攻击键，返回攻击状态
	if _event.is_action_pressed("attack"):
		return state_attack
	# 如果按下交互键，就发射交互信号
	elif _event.is_action_pressed("interact"):
		PlayerManager.emit_interact_pressed()
	# 如果按下冲刺键，就进入冲刺状态
	elif _event.is_action_pressed("dash"):
		return state_dash
	
	
	
	return null
