class_name Boss_Wizard
extends Node2D



const ENERGY_EXPLOSION_SCENE: PackedScene = preload("res://scenes/enemies/boss_wizard/energy_explosion.tscn")
const ENERGY_BALL: PackedScene = preload("res://scenes/enemies/boss_wizard/energy_orb.tscn") 


@export var max_hp: int = 10


var hp: int

# 当前索引位置
var current_index_pos: int = 0
# 所有位置点的数组
var positions: Array[Vector2]
# 所有激光攻击的数组
var beam_attacks: Array[Energy_Beam]

# 受伤音效
var hurt_audio: AudioStream = preload("res://assets/wizard_boss/boss_hurt.wav")
# 发射能量球音效
var shoot_audio: AudioStream = preload("res://assets/wizard_boss/boss_fireball.wav")

# 受伤计数
var damaged_count: int = 0



@onready var anim_player: AnimationPlayer = $Wizard/AnimationPlayer
@onready var audio_player: AudioStreamPlayer2D = $Wizard/AudioStreamPlayer2D
@onready var boss_dead: Persistent_Data_Handler = $Persistent_Data_Handler
@onready var hurt_box: Hurt_Box = $Wizard/Hurt_Box
@onready var hit_box: Hit_Box = $Wizard/Hit_Box
@onready var damaged_player: AnimationPlayer = $Wizard/Damaged_Player
@onready var wizard: Node2D = $Wizard
@onready var cloak_anim_player: AnimationPlayer = $Wizard/Cloak/AnimationPlayer


@onready var hand_1: Sprite2D = $Wizard/Cloak/Hand1
@onready var hand_2: Sprite2D = $Wizard/Cloak/Hand2
@onready var hand_1_up: Sprite2D = $Wizard/Cloak/Hand1_up
@onready var hand_2_up: Sprite2D = $Wizard/Cloak/Hand2_up
@onready var hand_1_side: Sprite2D = $Wizard/Cloak/Hand1_side
@onready var hand_2_side: Sprite2D = $Wizard/Cloak/Hand2_side

@onready var ban_door: Level_Tilemap = $"../Ban_Door"

@onready var item_dropper: Item_Dropper = $Item_Dropper





func _ready() -> void:
	
	boss_dead.get_value()
	if boss_dead.data_value == true:
		ban_door.enabled = false
		queue_free()
		return
	
	hp = max_hp
	
	PlayerHud.show_boss_bar("老巫师")
	
	hurt_box.hurt.connect(wizard_hurt)
	
	
	
	# 遍历获取所有位置点的数据
	for c in $Pos_Targets.get_children():
		positions.append(c.global_position)
	
	# 遍历获取所有激光节点
	for b in $Beam_Attacks.get_children():
		beam_attacks.append(b)
	
	
	
	# 隐藏位置点图案
	$Pos_Targets.visible = false
	
	# 使boss在第一个位置点出现
	teleport(0)







func _process(_delta: float) -> void:
	hand_1_up.position = hand_1.position
	hand_1_up.frame = hand_1.frame + 4
	hand_2_up.position = hand_2.position
	hand_2_up.frame = hand_2.frame + 4
	
	hand_1_side.position = hand_1.position
	hand_1_side.frame = hand_1.frame + 8
	hand_2_side.position = hand_2.position
	hand_2_side.frame = hand_2.frame + 12





# 激光攻击
func beam_attack():
	var _b: Array[int]
	
	# 根据当前所在位置加入对应位置的激光，并随机加入一条额外的激光
	match current_index_pos:
		0:
			_b.append(1)
			_b.append(2)
			var numbers: Array[int] = [0, 3, 4]
			var random_number = numbers[randi() % numbers.size()]
			_b.append(random_number)
		
		1:
			_b.append(0)
			_b.append(4)
			var numbers: Array[int] = [1, 2, 3]
			var random_number = numbers[randi() % numbers.size()]
			_b.append(random_number)
		
		2:
			_b.append(0)
			_b.append(3)
			var numbers: Array[int] = [1, 2, 4]
			var random_number = numbers[randi() % numbers.size()]
			_b.append(random_number)
		
		3:
			_b.append(2)
			_b.append(3)
			var numbers: Array[int] = [0, 1, 4]
			var random_number = numbers[randi() % numbers.size()]
			_b.append(random_number)
		
		4:
			_b.append(1)
			_b.append(4)
			var numbers: Array[int] = [0, 2, 3]
			var random_number = numbers[randi() % numbers.size()]
			_b.append(random_number)
	
	# 释放所有加入的激光
	for b in _b:
		beam_attacks[b].attack()




# 发射能量球
func shoot_orb():
	
	if hp < 1:
		return
	
	var eb: Node2D = ENERGY_BALL.instantiate()
	eb.global_position = wizard.global_position + Vector2(0, -15)
	get_parent().add_child.call_deferred(eb)
	play_audio(shoot_audio)






# 受伤函数
func wizard_hurt(_hit_box: Hit_Box):
	
	# 如果当前正在播放受伤动画或伤害值为0。就避免造成伤害
	if damaged_player.current_animation == "damaged" or _hit_box.damage == 0:
		return
	
	
	hp = clampi(hp - _hit_box.damage, 0, max_hp)
	
	# 更新生命条UI显示
	PlayerHud.update_boss_hp(hp, max_hp)
	
	# 增加一次受伤计数
	damaged_count += 1
	
	play_audio(hurt_audio)
	damaged_player.play("damaged")
	# 将动画定位到开头
	damaged_player.seek(0)
	# 将默认动画加入播放队列，准备下一个播放
	damaged_player.queue("default")
	
	
	
	if hp < 1:
		wizard_die()





# 死亡函数
func wizard_die():
	set_boxes(false)
	anim_player.play("destroy")
	PlayerHud.hide_boss_bar()
	# 添加被击败的持久数据
	boss_dead.set_value()
	
	await anim_player.animation_finished
	
	# 生成掉落物
	item_dropper.position = wizard.position
	item_dropper.drop_item()
	item_dropper.drop_collected.connect(open_door)




func open_door():
	ban_door.enabled = false






# 是否启用伤害框和攻击框
func set_boxes(_v: bool = true):
	hit_box.set_deferred("monitoring", _v)
	hurt_box.set_deferred("monitorable", _v)






# 传送到某个位置点
func teleport(_location: int):
	
	
	# 消失并关闭打击框
	anim_player.play("disappear")
	set_boxes(false)
	# 重置受伤计数
	damaged_count = 0
	
	shoot_orb()
	
	await get_tree().create_timer(1.0).timeout
	
	# 设置boss位置为目标索引位置点
	wizard.global_position = positions[_location]
	current_index_pos = _location
	
	update_anim()
	
	# 再次出现
	anim_player.play("appear")
	await anim_player.animation_finished
	
	if hp < 10:
		shoot_orb()
	
	
	# 进入空闲状态
	idle()







# 空闲状态
func idle():
	set_boxes()
	
	
	# 获取一个0到1的随机数，生命值越大，播放空闲动画的概率越大
	if randf() <= float(hp) / float(max_hp):
		anim_player.play("idle")
		await anim_player.animation_finished
		if hp < 1:
			return
	
	if damaged_count < 1:
		beam_attack()
		anim_player.play("cast_spell")
		await anim_player.animation_finished
		if hp < 1:
			return
	
	if hp < 1:
			return
	
	shoot_orb()
	
	var _t: int = current_index_pos
	
	while _t == current_index_pos:
		_t = randi_range(0, 4)
	
	# 有一半概率多停留一会
	if randf() >= 0.5:
		anim_player.play("idle")
		await anim_player.animation_finished
	
	teleport(_t)





# 更新动画方向
func update_anim():
	wizard.scale.x = 1
	
	hand_1.visible = false
	hand_2.visible = false
	hand_1_up.visible = false
	hand_2_up.visible = false
	hand_1_side.visible = false
	hand_2_side.visible = false
	
	if current_index_pos == 1:
		cloak_anim_player.play("side")
		hand_1_side.visible = true
		hand_2_side.visible = true
	elif current_index_pos == 2:
		cloak_anim_player.play("side")
		hand_1_side.visible = true
		hand_2_side.visible = true
		wizard.scale.x = -1
	elif current_index_pos == 3 or current_index_pos == 4:
		cloak_anim_player.play("up")
		hand_1_up.visible = true
		hand_2_up.visible = true
	else:
		cloak_anim_player.play("down")
		hand_1.visible = true
		hand_2.visible = true







# 播放音频
func play_audio(_a = AudioStream):
	audio_player.stream = _a
	audio_player.play()



# 生成并播放爆炸动画
func explode(_pos: Vector2 = Vector2.ZERO):
	var e: Node2D = ENERGY_EXPLOSION_SCENE.instantiate()
	e.global_position = wizard.global_position + _pos
	get_parent().add_child.call_deferred(e)
