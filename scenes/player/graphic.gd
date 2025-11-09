extends Node2D

@onready var hit_box: Hit_Box = $"../Hit_Box"
@onready var attack_effect: Node2D = $Attack_Effect
@onready var weapon_below: Sprite2D = $Weapon_Below
@onready var weapon_above: Sprite2D = $Weapon_Above
@onready var player_sprite: Sprite2D = $Sprite2D


const FRAME_COUNT: int = 128



func _init() -> void:
	return





func _ready() -> void:
	PlayerManager.INVENTORY_DATA.Equipment_Changed.connect(_on_equipment_changed)
	



func _process(_delta: float) -> void:
	# 同步武器纹理与玩家精灵纹理的动作
	weapon_below.frame = player_sprite.frame
	weapon_above.frame = player_sprite.frame + FRAME_COUNT
	
	if PlayerManager.player.direction == Vector2.LEFT:
		weapon_below.flip_h = true
		weapon_above.flip_h = true
	else:
		weapon_below.flip_h = false
		weapon_above.flip_h = false




# 装备外观改变
func _on_equipment_changed():
	var equipment: Array[Slot_Data] = PlayerManager.INVENTORY_DATA.equipment_slots()
	player_sprite.texture = equipment[0].item_data.sprite_texture
	weapon_above.texture = equipment[1].item_data.sprite_texture
	weapon_below.texture = equipment[1].item_data.sprite_texture





# 玩家举起物体并朝左时翻转图像
func lift_left():
	if PlayerManager.player.direction == Vector2.LEFT:
		player_sprite.scale.x = 1 
		hit_box.scale.x = 1
		attack_effect.scale.x = 1
		scale.x = -1
