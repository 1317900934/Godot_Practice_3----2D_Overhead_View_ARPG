extends State

class_name Player_Carry

# 扔出音效
@export var throw_audio: AudioStream
# 举着时的移动速度
@export var move_speed: float = 150.0


var walking: bool = false
var throwable: Throwable

@onready var idle: Player_Idle = $"../Idle"
@onready var stun: Player_Stun = $"../Stun"




# 进入状态
func enter():
	character.update_animation("carry")
	walking = false




# 退出状态
func exit():
	# 如果玩家没有移动，就将扔出方向设为玩家朝向，否则设为玩家移动方向
	if character.move_direction == Vector2.ZERO:
		throwable.throw_direction = character.direction
	else:
		throwable.throw_direction = character.move_direction
	
	
	if throwable:
		# 如果下一个状态是受击，就朝反方向掉落物品，否则投掷物品并播放音效
		if state_machine.next_state == stun:
			throwable.throw_direction = throwable.throw_direction.rotated(PI)
			throwable.drop()
		else:
			character.audio_player.stream = throw_audio
			character.audio_player.play()
			throwable.throw()




# 持续处理函数
func update(_delta: float) -> State:
	
	return null



# 物理持续处理函数
func physics_update(_delta: float) -> State:
	
	# 如果玩家没有行走，就更新举起动画和行走标志变量
	if character.move_direction == Vector2.ZERO:
		walking = false
		character.update_animation("carry")
	# 如果玩家更新了朝向或开始行走，就更新举着行走动画和行走标志变量
	elif character.set_direction() or walking == false:
		character.update_animation("carry_walk")
		walking = true
	
	
	character.velocity = character.move_direction * move_speed
	return null




# 处理输入事件
func handle_input(_event: InputEvent) -> State:
	
	# 如果按下交互键，就进入空闲状态
	if ( 
		_event.is_action_pressed("attack") or
		_event.is_action_pressed("interact") 
	):
		return idle
	
	return null
