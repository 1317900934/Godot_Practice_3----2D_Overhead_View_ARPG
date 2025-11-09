extends State

class_name Player_Charge_Attack

# 蓄力时间
@export var charge_duration: float = 1.0
# 移动速度
@export var move_speed: float = 160.0
# 蓄力完毕音效
@export var sfx_charged: AudioStream
# 蓄力后旋转攻击音效
@export var sfx_spin: AudioStream


var timer: float = 0

# 蓄力过程中是否行走
var walking: bool = false
# 是否旋转攻击
var is_attacking: bool = false
# 旋转攻击的粒子特效
var particles: ParticleProcessMaterial


@onready var idle: Player_Idle = $"../Idle"
@onready var charge_hit_box: Hit_Box = $"../../Charge_Hit_Box"
@onready var audio_player: AudioStreamPlayer2D = $"../../Audio/AudioStreamPlayer2D"
@onready var spin_anim_player: AnimationPlayer = $"../../Graphic/Spin_Effect/AnimationPlayer"
@onready var spin_effect: Sprite2D = $"../../Graphic/Spin_Effect/SpinEffect"
@onready var charge_particles: GPUParticles2D = $"../../Charge_Hit_Box/GPUParticles2D"





# 进入状态
func enter():
	# 设置蓄力时间计时器
	timer = charge_duration
	is_attacking = false
	walking = false





# 退出状态
func exit():
	charge_particles.emitting = false
	charge_particles.amount = 15
	charge_particles.explosiveness = 0
	if particles:
		particles.initial_velocity_min = 10
		particles.initial_velocity_max = 30





# 持续处理函数
func update(delta: float) -> State:
	
	# 根据左右朝向移动蓄力粒子的位置
	if character.direction == Vector2.LEFT:
		charge_particles.position = Vector2(-17, 6)
		charge_particles.rotation_degrees = -90
	elif character.direction == Vector2.RIGHT:
		charge_particles.position = Vector2(17, 6)
		charge_particles.rotation_degrees = -90
	
	
	# 如果计时器有时间，就逐渐减少
	if timer > 0:
		timer -= delta
		if timer <= 0:
			timer = 0
			charge_complete()
	
	
	if is_attacking == false:
		# 如果没有移动，就更新状态与动画
		if character.move_direction == Vector2.ZERO:
			walking = false
			character.update_animation("charge")
		# 如果方向改变或没有行走，就更新蓄力移动动画
		elif character.set_direction() or walking == false:
			walking = true
			character.update_animation("charge_walk")
	
	
	# 设置玩家移动
	character.velocity = character.move_direction * move_speed
	
	return null




# 物理持续处理函数
func physics_update(_delta: float) -> State:
	return null




# 处理输入事件
func handle_input(_event: InputEvent) -> State:
	
	if _event.is_action_released("attack"):
		if timer > 0:
			return idle
		elif is_attacking == false:
			charge_attacked()
	
	return null




# 蓄力完毕攻击
func charge_attacked():
	is_attacking = true
	
	charge_particles.amount = 50
	charge_particles.explosiveness = 0
	particles.initial_velocity_min = 80
	particles.initial_velocity_max = 80
	
	if character.direction == Vector2.LEFT:
		spin_effect.scale.x = -1
	else:
		spin_effect.scale.x = 1
	
	# 从对应方向开始播放动画并启用攻击框
	character.animation_player.play("charge_attack")
	character.animation_player.seek(get_spin_frame())
	charge_hit_box.monitoring = true
	attack_box_spin()
	play_audio(sfx_spin)
	
	spin_anim_player.play("spin")
	
	
	# 设置攻击动画时间
	var _duration: float = character.animation_player.current_animation_length * 2
	# 过程中使玩家无敌
	character.make_invulnerable(_duration)
	
	# 经过攻击动画时间后进入空闲状态
	await get_tree().create_timer(_duration).timeout
	charge_hit_box.monitoring = false
	state_machine.change_state(idle)
	
	



# 获取蓄力攻击不同朝向对应的开始帧
func get_spin_frame() -> float:
	# 帧数间隔
	var interval: float = 0.05
	
	match character.direction:
		Vector2.DOWN:
			return interval * 0
		Vector2.UP:
			return interval * 4
		_:
			return interval * 6






func play_audio(_audio: AudioStream):
	audio_player.stream = _audio
	audio_player.play()




# 蓄力完毕
func charge_complete():
	play_audio(sfx_charged)
	
	particles = charge_particles.process_material as ParticleProcessMaterial
	
	# 设置粒子爆发效果
	charge_particles.emitting = true
	charge_particles.amount = 30
	charge_particles.explosiveness = 1
	particles.initial_velocity_min = 50
	particles.initial_velocity_max = 100
	
	# 粒子爆发后减缓
	await get_tree().create_timer(0.2).timeout
	charge_particles.amount = 15
	charge_particles.explosiveness = 0
	particles.initial_velocity_min = 10
	particles.initial_velocity_max = 30




# 旋转攻击的特定方向修正
func attack_box_spin():
	var tween = get_tree().create_tween()
	
	if character.direction == Vector2.LEFT:
		charge_hit_box.rotation_degrees = 360
		tween.tween_property(charge_hit_box,"rotation_degrees", -360, 0.7)

	else:
		charge_hit_box.rotation_degrees = -360
		tween.tween_property(charge_hit_box,"rotation_degrees", 360, 0.7)
