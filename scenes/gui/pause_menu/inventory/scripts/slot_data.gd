class_name Slot_Data
extends Resource

# 物品数据
@export var item_data: Item_Data
# 物品数量
@export var quantity: int = 0 : set = set_quantity



# 如果数量小于1，就发射变化信号
func set_quantity(value: int):
	quantity = value
	if quantity < 1:
		emit_changed()
