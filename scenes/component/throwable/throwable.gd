class_name Throwable
extends Area2D


# 重力强度
@export var gravity_strength: float = 980
# 扔出的方向移速
@export var throw_speed: float = 400.0
# 扔出的最高高度
@export var throw_height_strength: float = 100.0
# 扔出的起始高度
@export var throw_starting_height: float = 50.0

# 是否可拿起
var pick_up: bool = false
# 可扔出的节点
var prop: Node2D
# 扔出的方向
var throw_direction: Vector2
# 扔出物的图像
var object_sprite: Sprite2D
# 垂直高度向量
var vertical_velocity: float = 0
# 地面高度位置
var graound_height: float = 0
# 扔出物的动画播放器
var anim_player: AnimationPlayer




@onready var hit_box: Hit_Box = $Hit_Box
@onready var wall_detect: Area2D = $Wall_Detect




func _ready() -> void:
	area_entered.connect(_on_area_enter)
	area_exited.connect(_on_area_exit)
	prop = get_parent()
	# 设置碰撞形状
	setup_collision_boxes()
	# 获取扔出物的图像
	object_sprite = prop.find_child("Sprite2D")
	# 获取扔出物在地面的位置
	graound_height = object_sprite.position.y
	# 获取扔出物的动画播放器
	anim_player = prop.find_child("AnimationPlayer")
	
	# 关闭物理函数
	set_physics_process(false)






func _physics_process(delta: float) -> void:
	
	# 给图像施加垂直运动模拟重力
	object_sprite.position.y += vertical_velocity * delta
	
	# 物品高度低于地面高度时销毁
	if object_sprite.position.y >= graound_height:
		hit_ground()
	
	# 垂直运动逐渐加快模拟重力
	vertical_velocity += gravity_strength * delta
	# 扔出时根据方向和扔出速度持续移动位置
	prop.position += throw_direction * throw_speed * delta









# 玩家进入可拿起区域
func _on_area_enter(_a: Area2D):
	if not PlayerManager.interact_pressed.is_connected(player_interact):
		PlayerManager.interact_pressed.connect(player_interact)



# 玩家退出可拿起区域
func _on_area_exit(_a: Area2D):
	if PlayerManager.interact_pressed.is_connected(player_interact):
		PlayerManager.interact_pressed.disconnect(player_interact)




# 障碍物碰到检测区域
func _on_body_entered(_n: Node2D):
	if _n is TileMapLayer:
		did_damage()







# 设置各种碰撞区域
func setup_collision_boxes():
	hit_box.monitoring = false
	
	for c in get_children():
		# 如果c是碰撞形状，就复制一个c节点的副本，添加为区域节点的碰撞区域
		if c is CollisionShape2D:
			var _col: CollisionShape2D = c.duplicate()
			hit_box.add_child(_col)
			_col.debug_color = Color.OLIVE
			var _col_2: CollisionShape2D = c.duplicate()
			wall_detect.add_child(_col_2)







# 玩家按下交互键
func player_interact():
	
	# 如果玩家交互按键事件已被处理，就返回
	if PlayerManager.interact_handle == true:
		return
	
	# 如果没有拿起，就拿起
	if pick_up == false:
		print("玩家举起物品")
		
		# 声明玩家交互按键事件已被处理
		PlayerManager.interact_handle = true
		
		# 禁用举起物品的碰撞
		disable_collisions(prop)
		
		# 如果可拿起的物品节点有父节点，就移除可拿起的物品节点
		if prop.get_parent():
			prop.get_parent().remove_child(prop)
		# 将可拿起的物品节点加入玩家的举起物节点
		PlayerManager.player.held_item.add_child(prop)
		prop.position = Vector2.ZERO
		
		PlayerManager.player.lift_item(self)
		area_entered.disconnect(_on_area_enter)
		area_exited.disconnect(_on_area_exit)



# 开始扔出物品
func throw():
	# 移除扔出物品节点
	prop.get_parent().remove_child(prop)
	# 添加扔出物到玩家父节点，延迟至下一帧防止玩家突然进入眩晕状态出错
	PlayerManager.player.get_parent().call_deferred("add_child", prop)
	# 设置扔出物在玩家的位置
	prop.position = PlayerManager.player.position
	# 设置图像位置到起始高度
	object_sprite.position.y = -throw_starting_height
	# 设置扔出瞬间的垂直高度向量
	if PlayerManager.player.direction == Vector2.DOWN:
		vertical_velocity = -throw_height_strength / 2
	else:
		vertical_velocity = -throw_height_strength
	# 启用物理函数
	set_physics_process(true)
	# 启用伤害框
	hit_box.set_deferred("monitoring", true)
	# 一碰到敌人就触发碰撞函数
	hit_box.did_damage.connect(did_damage)
	# 碰到物体时触发进入函数
	wall_detect.body_entered.connect(_on_body_entered)




# 扔出物未扔出，垂直掉落
func drop():
	# 延迟至下一针帧移除物品节点
	prop.get_parent().call_deferred("remove_child", prop)
	# 添加扔出物到玩家父节点，延迟至下一帧防止玩家突然进入眩晕状态出错
	PlayerManager.get_parent().call_deferred("add_child", prop)
	# 设置扔出物在玩家的位置
	prop.position = PlayerManager.player.position
	# 设置图像位置到起始高度
	object_sprite.position.y = -50
	# 设置垂直下落向量
	vertical_velocity = -200
	# 设置掉落速度
	throw_speed = 100
	# 启用物理函数
	set_physics_process(true)
	# 碰到物体时触发进入函数
	wall_detect.body_entered.connect(_on_body_entered)







# 物体触碰到地面
func hit_ground():
	destroy()







# 物品销毁
func destroy():
	# 关闭物理过程
	set_physics_process(false)
	# 关闭伤害判定
	hit_box.set_deferred("monitoring", false)
	
	# 播放销毁动画
	if anim_player:
		anim_player.play("destroy")
		await anim_player.animation_finished
	
	prop.queue_free()
	







# 投掷物碰撞
func did_damage():
	destroy()









# 遍历并递归搜索碰撞形状，然后禁用
func disable_collisions(_node: Node):
	
	for c in _node.get_children():
		# 如果c是自己，就跳过
		if c == self:
			continue
		# 如果是碰撞形状，就禁用
		if c is CollisionShape2D:
			c.disabled = true
		else:
			disable_collisions(c)
