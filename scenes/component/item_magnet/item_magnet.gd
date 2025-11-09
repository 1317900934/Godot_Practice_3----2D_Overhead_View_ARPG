class_name Item_Magnet
extends Area2D



var items: Array[Item_Pickup] = []

var speeds: Array[float] = []


# 磁铁吸力
@export var magnet_strenth: float = 4.0
# 是否播放吸附音效
@export var play_audio: bool = false


@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D



func _ready() -> void:
	area_entered.connect(_on_area_entered)











func _process(delta: float) -> void:
	
	# 遍历物品数组，根据吸力速度移动物品(如果没有物品就清除此索引位)
	# 以相反的顺序遍历数组：从数组大小-1开始，到-1前结束，每次减少1
	for i in range (items.size() -1, -1, -1):
		var _item = items[i]
		
		# 如果数组目标索引位为空，就删除索引位
		if _item == null:
			# 以相反的顺序遍历数组时，移除一个项目不会影响后续需要遍历的项目
			items.remove_at(i)
			speeds.remove_at(i)
		# 如果物品位置距离大于吸引速度，就吸引
		elif _item.global_position.distance_to(global_position) > speeds[i]:
			speeds[i] += magnet_strenth * delta
			_item.position += _item.global_position.direction_to(global_position) * speeds[i]
		# 否则将物品位置设置为磁铁中心位置
		else:
			_item.global_position = global_position








func _on_area_entered(_a: Area2D):
	
	if _a.get_parent() is Item_Pickup:
		
		var _new_item = _a.get_parent() as Item_Pickup
		items.append(_new_item)
		speeds.append(magnet_strenth)
		# 禁用被吸引物品的物理效果，使其能穿过障碍
		_new_item.set_physics_process(false)
		
		if play_audio:
			audio_player.play(0)
