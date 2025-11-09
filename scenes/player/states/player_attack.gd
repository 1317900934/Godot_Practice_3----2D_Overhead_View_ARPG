extends State

class_name Player_Attack

# 移动状态引用
@export var state_move: State
# 空闲状态引用
@export var state_idle: State
# 蓄力攻击状态引用
@export var charge_attack: State
# 攻击音效引用
@export var attack_sound: AudioStream

# 攻击时的减速
@export_range(1, 20, 0.5) var decelerate_speed = 15.0


var attacking: bool = false

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var attack_effect_anim: AnimationPlayer = $"../../Graphic/Attack_Effect/AnimationPlayer"
@onready var audio: AudioStreamPlayer2D = $"../../Audio/AudioStreamPlayer2D"
@onready var hit_box: Hit_Box = $"../../Hit_Box"




# 进入状态
func enter():
	# 调用绑定的角色的更新动画方法，传入attack状态名
	character.update_animation("attack")
	
	# 将攻击声音传入音效播放器
	audio.stream = attack_sound
	# 在一定范围内随机声音的音调
	audio.pitch_scale = randf_range(0.9, 1.1)
	# 播放音效
	audio.play()
	
	# 获取角色对应方向并播放攻击特效动画
	attack_effect_anim.play("attack_" + character.anim_direction())
	
	# 将动画结束播放的信号连接停止攻击的函数
	animation_player.animation_finished.connect(end_attack)
	# 标明正在攻击中
	attacking = true
	




# 退出状态
func exit():
	# 将动画结束播放的信号与停止攻击的函数断开连接
	animation_player.animation_finished.disconnect(end_attack)
	# 结束攻击
	attacking = false
	
	# 关闭攻击框
	hit_box.set_deferred("monitoring", false)


# 持续处理函数
func update(delta: float) -> State:
	
	
	# 将角色的速度向量进行减速,使角色在攻击时快速停止移动，但不会瞬间停止
	character.velocity -= character.velocity * decelerate_speed * delta
	
	# 如果攻击结束，那么根据是否有移动向量来进入空闲或移动状态
	if not attacking:
		if character.move_direction == Vector2.ZERO:
			return state_idle
		else:
			return state_move
	
	return null



# 物理持续处理函数
func physics_update(_delta: float) -> State:
	return null




# 处理输入事件
func handle_input(_event: InputEvent) -> State:
	return null



# 结束攻击
func end_attack(_anim_name: String):
	# 如果结束攻击时正在按着攻击键，就进入蓄力攻击状态
	if Input.is_action_pressed("attack"):
		state_machine.change_state(charge_attack)
	
	# 将攻击中的标志设为false，表示结束攻击
	attacking = false
