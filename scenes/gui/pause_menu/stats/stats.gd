class_name Player_Stats
extends PanelContainer

@onready var level_label: Label = $VBoxContainer/HBoxContainer/Label2
@onready var xp_label: Label = $VBoxContainer/HBoxContainer/Label4
@onready var attack_label: Label = $VBoxContainer/HBoxContainer3/Label2
@onready var attack_label_change: Label = $VBoxContainer/HBoxContainer3/Label3
@onready var defense_label: Label = $VBoxContainer/HBoxContainer4/Label2
@onready var defense_label_change: Label = $VBoxContainer/HBoxContainer4/Label3


var inventory: Inventory_Data



func _ready() -> void:
	PauseMenu.shown.connect(update_stats)
	PauseMenu.preview_stats_changed.connect(_on_preview_stats_changed)
	inventory = PlayerManager.INVENTORY_DATA
	# 装备更改时更新属性文本
	inventory.Equipment_Changed.connect(update_stats)





# 更新属性文本
func update_stats():
	var _p: Player = PlayerManager.player
	
	level_label.text = str(_p.level)
	
	if _p.level < PlayerManager.level_requirements.size():
		xp_label.text = str(_p.xp) + "/" + str(PlayerManager.level_requirements[_p.level])
	else:
		xp_label.text = "已满"
	
	attack_label.text = str(_p.attack_power + inventory.get_attack_bonus())
	defense_label.text = str(_p.defense_power + inventory.get_defense_bonus())




# 预览装备属性加成值的改变
func _on_preview_stats_changed(item: Item_Data):
	attack_label_change.text = ""
	defense_label_change.text = ""
	
	if not item is Equipable_Item_Data: return
	
	var equipment: Equipable_Item_Data = item
	
	# 获取目标装备与当前装备的属性差异值后更新预览标签的文本
	var attack_delta: int = inventory.get_attack_bonus_diff(equipment)
	var defense_delta: int = inventory.get_defense_bonus_diff(equipment)
	update_label(attack_label_change, attack_delta)
	update_label(defense_label_change, defense_delta)




# 更新属性值变化预览标签的文本
func update_label(label: Label, value: int):
	if value > 0:
		label.text = "+" + str(value)
		label.modulate = Color.PALE_GREEN
	elif value < 0:
		label.text = str(value)
		label.modulate = Color.PALE_VIOLET_RED
	else: 
		return
