class_name Inventory_UI
extends Control


# 引用库存槽场景
const INVENTORY_SLOT = preload("uid://oto3b0xund7y")

# 引用库存数据
@export var data: Inventory_Data



@onready var armor_slot: Inventory_Slot = %Armor_Slot
@onready var weapon_slot: Inventory_Slot = %Weapon_Slot
@onready var amulet_slot: Inventory_Slot = %Amulet_Slot
@onready var ring_slot: Inventory_Slot = %Ring_Slot


# 拖动物品时的悬停物
var hovered_item: Inventory_Slot



# 聚焦索引
var focus_index: int = 0



func _ready() -> void:
	
	
	# 显示暂停菜单时，更新库存物品
	PauseMenu.shown.connect(update_inventory)
	# 关闭暂停菜单时，清除库存物品
	PauseMenu.hidden.connect(clear_inventory)
	# 将数据改变和装备改变信号连接自定义函数
	data.changed.connect(on_inventory_changed)
	data.Equipment_Changed.connect(on_inventory_changed)
	
	
	# 清除库存物品
	clear_inventory()
	
	





# 清除所有库存物品数据
func clear_inventory():
	
	for c in get_children():
		c.set_slot_data(null)





# 更新库存
func update_inventory(apply_focus: bool = true):
	
	# 先清除原有库存数据
	clear_inventory()
	
	# 获取不包含装备槽的库存插槽数组
	var inventory_slots: Array[Slot_Data] = data.inventory_slots()
	
	# 遍历子节点的非装备库存槽，给每个槽位设置数组中的对应数据，并连接槽位中的信号
	for i in inventory_slots.size():
		var slot: Inventory_Slot = get_child(i)
		slot.set_slot_data(inventory_slots[i])
		connect_item_signals(slot)
	
	
	# 获取并设置剩余的4个装备槽
	var e_slots: Array[Slot_Data] = data.equipment_slots()
	armor_slot.set_slot_data(e_slots[0])
	weapon_slot.set_slot_data(e_slots[1])
	amulet_slot.set_slot_data(e_slots[2])
	ring_slot.set_slot_data(e_slots[3])
	
	
	# 如果需要聚焦，就获取第一个物品槽，抓取焦点
	if apply_focus:
		get_child(0).grab_focus()




# 刷新库存
func on_inventory_changed():
	update_inventory(false)





# 物品聚焦
func item_focus():
	# 遍历物品槽个数，如果某物品有焦点，就获取该物品槽的索引
	for i in get_child_count():
		if get_child(i).has_focus():
			focus_index = i
			return





# 连接库存槽中的信号
func connect_item_signals(item: Inventory_Slot):
	if not item.button_up.is_connected(_on_item_drop):
		item.button_up.connect(_on_item_drop.bind(item))
	
	if not item.mouse_entered.is_connected(_on_item_mouse_entered):
		item.mouse_entered.connect(_on_item_mouse_entered.bind(item))
	
	if not item.mouse_exited.is_connected(_on_item_mouse_exited):
		item.mouse_exited.connect(_on_item_mouse_exited)




# 鼠标在某槽位松开时交换物品位置并聚焦
func _on_item_drop(item: Inventory_Slot):
	# 当拖拽的物品槽没有物品数据，或槽位与悬停槽位一致，或没有悬停槽位时，不执行交换
	if item == null or item == hovered_item or hovered_item == null:
		return
	data.swap_items_by_index(item.get_index(), hovered_item.get_index())
	hovered_item.grab_focus()
	PauseMenu.focused_item_change(item.slot_data)
	update_inventory(false)




# 鼠标悬停物品槽
func _on_item_mouse_entered(item: Inventory_Slot):
	hovered_item = item



# 鼠标离开物品槽
func _on_item_mouse_exited():
	hovered_item = null
