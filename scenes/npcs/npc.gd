@tool
@icon("res://assets/npc_and_dialog/icons/npc.svg")


class_name NPC
extends CharacterBody2D


# NPC状态
var state: String = "idle"
# NPC移动方向
var direction: Vector2 = Vector2.DOWN
# 方向名称
var direction_name: String = "down"
# 是否可以进行某行为
var do_behavior: bool = true


# 行为开始信号
signal do_behavior_on



@export var npc_resource: NPC_Resource: set = _set_npc_resource


@onready var sprite: Sprite2D = $Sprite2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer





func _ready() -> void:
	
	setup_npc()
	
	if Engine.is_editor_hint():
		return
	
	gather_interactables()
	
	do_behavior_on.emit()






func _physics_process(_delta: float) -> void:
	move_and_slide()






# 更新动画
func update_anim():
	anim_player.play(state + "_" + direction_name)






# 更新方向
func update_dir(target_position: Vector2):
	
	direction = global_position.direction_to(target_position)
	
	update_dir_name()
	
	# 如果方向名是侧面，并且x轴小于0，就翻转图像
	if direction_name == "side" and direction.x < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false





# 更新方向名称
func update_dir_name():
	# 目标方向延迟阈值
	var threshold: float = 0.45
	
	if direction.y < -threshold:
		direction_name = "up"
	elif direction.y > threshold:
		direction_name = "down"
	elif direction.x > threshold or direction.x < -threshold:
		direction_name = "side"






# 设置npc数据
func setup_npc():
	# 如果有npc资源，就获取npc资源的精灵材质
	if npc_resource:
		if sprite:
			sprite.texture = npc_resource.sprite






# 绑定NPC资源
func _set_npc_resource(_npc: NPC_Resource):
	npc_resource = _npc
	setup_npc()



# 连接交互区域
func gather_interactables():
	for c in get_children():
		if c is Dialog_Interact:
			c.player_interacted.connect(_on_player_interacted)
			c.finished.connect(_on_interaction_finished)
	



# 玩家交互
func _on_player_interacted():
	# 使npc朝向玩家
	update_dir(PlayerManager.player.global_position)
	# 停止npc移动
	state = "idle"
	velocity = Vector2.ZERO
	update_anim()
	do_behavior = false
	

# 交互结束
func _on_interaction_finished():
	state = "idle"
	update_anim()
	do_behavior = true
	do_behavior_on.emit()
