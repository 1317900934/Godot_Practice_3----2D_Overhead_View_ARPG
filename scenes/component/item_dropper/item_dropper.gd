@tool
class_name Item_Dropper
extends Node2D

signal drop_collected


# 引入物品拾取场景
const PICKUP = preload("res://items/item_pickup/item_pickup.tscn")


@export var item_data: Item_Data: set = _set_item_data
@onready var sprite: Sprite2D = $Sprite2D
@onready var drop_data: Persistent_Data_Handler = $Persistent_Data_Handler
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer



var has_dropped: bool = false






func _ready() -> void:
	if Engine.is_editor_hint() == true:
		_update_texture()
		return
	
	
	sprite.visible = false
	
	drop_data.data_loaded.connect(_on_data_loaded)
	_on_data_loaded()
	
	





# 生成掉落物品
func drop_item():
	
	# 如果已掉落过，就返回
	if has_dropped == true:
		return
	
	has_dropped = true
	
	# 实例化可拾取的物品
	var drop = PICKUP.instantiate() as Item_Pickup
	# 将可拾取物品的数据设置为掉落物数据
	drop.item_data = item_data
	# 加入场景树
	add_child(drop)
	# 将物品拾取信号连接添加持久数据函数
	drop.picked_up.connect(_on_drop_pickup)
	# 播放掉落音效
	audio_player.play()
	
	
	





# 添加持久数据到存档
func _on_drop_pickup():
	drop_data.set_value()
	drop_collected.emit()





# 获取并设置持久数据
func _on_data_loaded():
	has_dropped = drop_data.data_value







# 设置物品数据
func _set_item_data(value: Item_Data):
	item_data = value
	_update_texture()






# 更新纹理预览
func _update_texture():
	if Engine.is_editor_hint() == true:
		if item_data and sprite:
			sprite.texture = item_data.texture
