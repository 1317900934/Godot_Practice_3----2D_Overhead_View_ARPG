extends State

class_name Player_Idle

# 移动状态引用
@export var state_move: State
# 攻击状态引用
@export var state_attack: State
# 冲刺状态引用
@export var state_dash: State


# 进入状态
func enter():
	# 调用绑定的角色的更新动画方法，传入idle状态名
	character.update_animation("idle")



# 退出状态
func exit():
	pass




# 持续处理函数
func update(_delta: float) -> State:
	
	# 如果角色的移动向量不为0，就返回移动状态
	if character.move_direction != Vector2.ZERO:
		return state_move
	
	# 清空已有的速度向量
	character.velocity = Vector2.ZERO
	
	return null



# 物理持续处理函数
func physics_update(_delta: float) -> State:
	return null




# 处理输入事件
func handle_input(_event: InputEvent) -> State:
	
	# 如果按下攻击键，就返回攻击状态
	if _event.is_action_pressed("attack"):
		return state_attack
	# 如果按下交互键，就发射交互信号
	elif _event.is_action_pressed("interact"):
		PlayerManager.emit_interact_pressed()
	# 如果按下冲刺键，就进入冲刺状态
	elif _event.is_action_pressed("dash"):
		return state_dash
	
	
	return null
