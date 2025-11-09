@tool
class_name Item_Pickup
extends CharacterBody2D


@onready var area: Area2D = $Area2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var count_label: Label = %Count_Label


@export var item_data: Item_Data: set = _set_item_data
@export var item_count: int = 1: set = _set_item_count



signal picked_up





func _ready() -> void:
	
	_update_texture()
	_update_count_label()
	
	if Engine.is_editor_hint():
		return
	
	# 将物体进入信号连接函数
	area.body_entered.connect(_on_body_entered)






func _physics_process(delta: float) -> void:
	
	# 获取碰撞信息
	var collision_info = move_and_collide(velocity * delta)
	
	if collision_info:
		# 向碰撞方向反弹
		velocity.bounce(collision_info.get_normal())
	
	# 逐渐减速
	velocity -= velocity * delta * 4






# 玩家进入拾取区域
func _on_body_entered(object):
	# 如果进入者是玩家，并且此物品有数据，就调用玩家库存数据中的物品添加函数，如果可以添加，就调用拾取函数
	if object is Player:
		if item_data:
			
			if item_data.name == "炸弹":
				PlayerManager.player.bomb_count += item_count
				item_picked_up()
			elif item_data.name == "箭矢":
				PlayerManager.player.arrow_count += item_count
				item_picked_up()
			elif PlayerManager.INVENTORY_DATA.add_item(item_data, item_count) == true:
				item_picked_up()






# 物品拾取
func item_picked_up():
	# 断开区域连接，防止多次拾取
	area.body_entered.disconnect(_on_body_entered)
	
	# 播放音效后发射信号，然后删除自己
	audio_stream_player.play()
	visible = false
	picked_up.emit()
	await audio_stream_player.finished
	queue_free()






# 设置物品数据时更新图像
func _set_item_data(value: Item_Data):
	
	item_data = value
	
	_update_texture()




# 更新纹理
func _update_texture():
	
	if item_data and sprite:
		sprite.texture = item_data.texture




# 设置掉落物数量
func _set_item_count(value: int):
	item_count = value
	_update_count_label()




# 更新掉落物数量显示
func _update_count_label():
	if item_data and count_label:
		count_label.text = ""
		if item_count > 1:
			count_label.text = str(item_count)
