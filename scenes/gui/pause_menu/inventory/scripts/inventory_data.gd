class_name Inventory_Data
extends Resource


# 库存数据数组
@export var slots: Array[Slot_Data]



# 装备改变信号
signal Equipment_Changed
# 拾取能力信号
signal add_ability(ability: Item_Data)


# 装备槽位个数
var equipment_slot_count: int = 4




func _init() -> void:
	connect_slots()






# 获取去除装备槽的库存槽数组
func inventory_slots() -> Array[Slot_Data]:
	return slots.slice(0, -equipment_slot_count)



# 获取去除库存槽的装备槽数组
func equipment_slots() -> Array[Slot_Data]:
	return slots.slice(-equipment_slot_count, slots.size())




# 添加物品到库存(获取物品数据和数量，默认数量为1)
func add_item(item: Item_Data, count: int = 1) -> bool:
	
	# 如果是能力效果，就发射信号
	if item is Ability_Item_Data:
		add_ability.emit(item)
		return true
	
	# 一次添加的数量不能超过9999
	count = clampi(count, 1, 9999)
	
	# 如果库存有相同物品就叠加，没有相同物品但有空位就添加物品，否则不添加
	# 遍历库存数组，如果槽位有物品，并且是相同物品，就增加对应数量
	for s in slots:
		if s:
			if s.item_data == item:
				s.quantity += count
				# 限制最大拥有量
				s.quantity = clampi(s.quantity, 1, 999)
				return true
	# 遍历库存数组长度，如果有空槽位，就创建一个新槽位数据，获取物品信息和数量,添加到数组中
	for i in inventory_slots().size():
		if slots[i] == null:
			var new = Slot_Data.new()
			new.item_data = item
			new.quantity = count
			slots[i] = new
			# 连接物品改变信号
			new.changed.connect(slot_changed)
			return true
	
	print("[库存已满]")
	
	return false





# 连接物品改变信号到自定义函数
func connect_slots():
	for s in slots:
		if s:
			s.changed.connect(slot_changed)




# 物品槽改变时执行
func slot_changed():
	
	for s in slots:
		if s:
			# 如果物品小于1，就清除物品
			if s.quantity < 1:
				# 断开函数连接
				s.changed.disconnect(slot_changed)
				# 找到s的索引
				var index = slots.find(s)
				# 清空对应槽位
				slots[index] = null
				# 发射改变信号
				emit_changed()




# 存储当前库存数据，得到一个字典数组
func get_save_data() -> Array:
	
	var item_save: Array = []
	
	# 遍历物品库存数组的物品槽，依次转变为字典数据后存储到数组中
	for i in slots.size():
		item_save.append( item_to_save(slots[i]) )
	
	return item_save



# 转换物品槽数据为字典
func item_to_save(s: Slot_Data) -> Dictionary:
	
	# 物品槽数据字典
	var result = {item = "", quantity = 0}
	
	if s != null:
		result.quantity = s.quantity
		# 如果物品槽内有物品数据，就获取该物品的资源路径
		if s.item_data != null:
			result.item = s.item_data.resource_path
	
	return result




# 解析存档的库存数据
func parse_save_data(save_data: Array):
	
	# 获取库存数组长度
	var array_size = slots.size()
	# 清空库存(包括其中的物品)
	slots.clear()
	# 将库存重新设置为之前的长度(其中的数据已全部清空)
	slots.resize(array_size)
	# 遍历并获取存档中库存的所有物品
	for i in save_data.size():
		slots[i] = item_from_save(save_data[i])
	# 连接物品改变信号到自定义函数
	connect_slots()






# 转换物品字典为物品槽数据
func item_from_save(save_object: Dictionary) -> Slot_Data:
	
	# 如果此对象的物品信息是空的，就直接返回
	if save_object.item == "":
		return null
	
	# 创建一个新资源
	var new_slot: Slot_Data = Slot_Data.new()
	# 新资源的数据将加载字典路径的资源文件，数量将是字典中的数量
	new_slot.item_data = load(save_object.item)
	new_slot.quantity = int(save_object.quantity)
	
	return new_slot



# 使用库存中的某些物品
func use_item(item: Item_Data, count: int = 1) -> bool:
	
	# 遍历槽位，如果有物品并且是目标物品，且物品数量足够,就减去对应数量，声明使用成功
	for s in slots:
		if s:
			if s.item_data == item and s.quantity >= count:
				s.quantity -= count
				return true
	
	return false



# 移除库存中的某些物品
func remove_item(item: Item_Data, count: int = 1) -> bool:
	
	# 遍历槽位，如果有物品并且是目标物品，且物品数量足够,就减去对应数量，声明使用成功
	for s in slots:
		if s:
			if s.item_data == item and s.quantity >= count:
				s.quantity -= count
				return true
	
	return false




# 通过交换物品索引，调整槽位在库存中的位置
func swap_items_by_index(i1: int, i2: int):
	var temp: Slot_Data = slots[i1]
	slots[i1] = slots[i2]
	slots[i2] = temp





# 装备物品
func equip_item(slot: Slot_Data):
	if slot == null or not slot.item_data is Equipable_Item_Data:
		return
	
	# 获取装备数据
	var item: Equipable_Item_Data = slot.item_data
	# 获取需装备物品在库存的索引
	var slot_index: int = slots.find(slot)
	# 根据装备类型获取对应装备槽位索引
	var equipment_index: int = slots.size() - equipment_slot_count
	match item.type:
		Equipable_Item_Data.Type.ARMOR:
			equipment_index += 0
		Equipable_Item_Data.Type.WEAPON:
			equipment_index += 1
		Equipable_Item_Data.Type.AMULET:
			equipment_index += 2
		Equipable_Item_Data.Type.RING:
			equipment_index += 3
	
	# 选定需要装备的目标槽位
	var unequip_slot: Slot_Data = slots[equipment_index]
	# 交换两个槽位
	slots[slot_index] = unequip_slot
	slots[equipment_index] = slot
	
	Equipment_Changed.emit()
	PauseMenu.focused_item_change(unequip_slot)
	
	





# 获取所有已装备物品攻击力加成值
func get_attack_bonus() -> int:
	return get_equipment_bonus(Equipable_Item_Modifier.Type.ATTACK)


# 获取新装备与当前装备的攻击属性差值
func get_attack_bonus_diff(item: Equipable_Item_Data) -> int:
	# 前一个装备加成值
	var before: int = get_attack_bonus()
	# 后一个装备加成值
	var after: int = get_equipment_bonus(Equipable_Item_Modifier.Type.ATTACK, item)
	
	return after - before









# 获取所有已装备物品防御力加成值
func get_defense_bonus() -> int:
	return get_equipment_bonus(Equipable_Item_Modifier.Type.DEFENCE)


# 获取新装备与当前装备的防御属性差值
func get_defense_bonus_diff(item: Equipable_Item_Data) -> int:
	# 前一个装备加成值
	var before: int = get_defense_bonus()
	# 后一个装备加成值
	var after: int = get_equipment_bonus(Equipable_Item_Modifier.Type.DEFENCE, item)
	
	return after - before






# 获取所有已装备物品移速加成值
func get_move_speed_bonus() -> int:
	return get_equipment_bonus(Equipable_Item_Modifier.Type.SPEED)


# 获取新装备与当前装备的移速加成差值
func get_move_speed_bonus_diff(item: Equipable_Item_Data) -> int:
	# 前一个装备加成值
	var before: int = get_move_speed_bonus()
	# 后一个装备加成值
	var after: int = get_equipment_bonus(Equipable_Item_Modifier.Type.SPEED, item)
	
	return after - before







# 获取某条属性的装备加成总值
func get_equipment_bonus(bonus_type: Equipable_Item_Modifier.Type, compare: Equipable_Item_Data = null) -> int:
	var bonus: int = 0
	# 遍历所有装备槽，获得目标属性的总加成值
	for s in equipment_slots():
		if s == null:
			continue
		var e: Equipable_Item_Data = s.item_data
		# 如果有另一个装备，就读取此装备
		if compare:
			if e.type == compare.type:
				e = compare
		
		for m in e.modifiers:
			if m.type == bonus_type:
				bonus += m.value
	
	return bonus





# 获取某物品在库存中的持有数量
func get_item_held_quantity(_item: Item_Data) -> int:
	
	for slot in slots:
		if slot and slot.item_data:
			if slot.item_data == _item:
				return slot.quantity
	
	return 0
