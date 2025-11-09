extends Node


# 引用玩家场景
const PLAYER = preload("uid://ry4g7xdmxql3")
# 引用玩家库存数据
const INVENTORY_DATA: Inventory_Data = preload("uid://x1vs02173ex0")




@warning_ignore("unused_signal")
# 交互键按下信号
signal interact_pressed
# 镜头摇晃信号
signal camera_shook(trauma: float)
# 玩家升级信号
signal player_leveled_up
# 设置玩家位置到出生点信号
@warning_ignore("unused_signal")
signal set_player_pos_to_spawn


# 交互按键事件是否被处理
var interact_handle: bool = false


# 玩家
var player: Player
# 玩家是否已生成
var player_spawned: bool = false



# 设定各个等级所需经验值
var level_requirements = [0, 20, 40, 80, 120, 180, 240, 360, 600, 1000]





func _ready() -> void:
	add_player_instance()
	await get_tree().create_timer(0.2).timeout
	player_spawned = true







# 添加玩家实例
func add_player_instance():
	
	# 实例化玩家场景，赋值给玩家变量
	player = PLAYER.instantiate()
	# 添加子节点
	add_child(player)










# 设置玩家生命值
func set_player_hp(hp: int, max_hp:int):
	player.max_hp = max_hp
	player.hp = hp
	# 更新玩家生命值UI
	player.update_hp(0)





# 玩家获得经验值，并检查是否可以升级
func reward_xp(_xp: int):
	player.xp += _xp
	check_for_level_advance()





# 递归检查是否可以升级
func check_for_level_advance():
	
	# 如果已满级，就返回
	if player.level >= level_requirements.size():
		return
	
	if player.xp >= level_requirements[player.level]:
		player.level += 1
		player.attack_power += 1
		player.defense_power += 1
		if player.level > 5:
			player.max_hp += 2
		player_leveled_up.emit()
		check_for_level_advance()








# 设置玩家的位置
func set_player_position(pos: Vector2):
	player.global_position = pos




# 设置玩家的父节点
func set_as_parent(p: Node2D):
	# 如果玩家有父节点，就移除此节点的玩家
	if player.get_parent():
		player.get_parent().remove_child(player)
	# 添加玩家为目标节点的子节点
	p.add_child(player)





# 移除某节点中的玩家
func unparent_player(p: Node2D):
	if p != null:
		p.remove_child(player)





# 设置玩家音频播放器的音效并播放
func play_audio(_audio: AudioStream):
	player.audio_player.stream = _audio
	player.audio_player.play()




# 发射交互按下信号
func emit_interact_pressed():
	interact_handle = false
	interact_pressed.emit()




# 摇晃摄像机镜头
func shake_camera(t: float = 1):
	camera_shook.emit(clampf(t, 0, 3))





# 将相机拉回到玩家身上
func reset_camera_on_player(tween_duration: float = 0.5):
	var camera: Camera2D = get_viewport().get_camera_2d()
	
	if camera:
		if camera.get_parent() == player: return
		
		camera.reparent(player)
		
		var tween: Tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_QUAD)
		tween.tween_property(camera, "position", Vector2.ZERO, tween_duration)
