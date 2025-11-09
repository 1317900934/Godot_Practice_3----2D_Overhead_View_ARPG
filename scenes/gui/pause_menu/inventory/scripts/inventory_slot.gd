class_name Inventory_Slot
extends Button


# 物品槽数据
var slot_data: Slot_Data: set = set_slot_data
# 点击按钮时的鼠标位置
var click_pos: Vector2 = Vector2.ZERO
# 是否正在拖动
var dragging: bool = false
# 拖动时显示的半透明纹理
var drag_texture: Control
# 判定进入拖动状态的最小像素距离
var drag_threshold: float = 16




@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label



func _ready() -> void:
	
	# 清空初始槽位数据
	texture_rect.texture = null
	label.text = ""
	
	# 将按钮聚焦和失焦的信号连接到自定义函数
	focus_entered.connect(item_focused)
	focus_exited.connect(item_unfocused)
	
	# 连接按钮按下和松开的函数
	button_down.connect(on_button_down)
	button_up.connect(on_button_up)
	








func _process(_delta: float) -> void:
	if dragging == true:
		drag_texture.position = get_local_mouse_position() - Vector2(16, 16)
		if outside_drag_threshold() == true:
			drag_texture.modulate.a = 0.5
		else:
			drag_texture.modulate.a = 0





# 设置槽位数据
func set_slot_data(value: Slot_Data):
	
	# 获取物品数据，如果为空，就设置空数据并返回
	slot_data = value
	if slot_data == null:
		texture_rect.texture = null
		label.text = ""
		return
	
	# 更新物品纹理
	texture_rect.texture = slot_data.item_data.texture
	# 如果是装备物品，就不显示数量，否则更新物品数量
	if slot_data.item_data is Equipable_Item_Data:
		label.text = ""
	else:
		label.text = str(slot_data.quantity)







# 聚焦物品时更新物品描述和属性加成显示
func item_focused():
	PauseMenu.focused_item_change(slot_data)



# 失焦物品时清空物品描述
func item_unfocused():
	PauseMenu.update_item_description("")




# 输入处理函数
func _gui_input(event: InputEvent) -> void:
	# 处理鼠标按钮按下事件
	if event is InputEventMouseButton and event.pressed:
		# 匹配鼠标按键索引(1是左键，2是右键)
		match event.button_index:
			1:  # 左键(MouseButton.LEFT)
				grab_focus() 
			
			2:  # 右键(MouseButton.RIGHT)
				
				if outside_drag_threshold() == true:
					return
				
				if has_focus():
					# 使用或装备物品
					if slot_data and slot_data.item_data:
						
						var item = slot_data.item_data
						
						if item is Equipable_Item_Data:
							PlayerManager.INVENTORY_DATA.equip_item(slot_data)
							return
						
						var was_used = item.use_item()
						if not was_used: return
						
						# 更新物品数量
						slot_data.quantity -= 1
						if slot_data == null: return
						label.text = str(slot_data.quantity)
				else:
					grab_focus()







func on_button_down():
	grab_focus()
	click_pos = get_global_mouse_position()
	dragging = true
	drag_texture = texture_rect.duplicate()
	drag_texture.z_index = 10
	drag_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(drag_texture)
	




func on_button_up():
	
	dragging = false
	if drag_texture:
		drag_texture.free()




# 判断是否超过进入拖动状态的范围
func outside_drag_threshold() -> bool:
	if get_global_mouse_position().distance_to(click_pos) > drag_threshold:
		return true
	
	return false
