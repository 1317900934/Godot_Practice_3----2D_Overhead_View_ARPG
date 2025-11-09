class_name Drop_Data
extends Resource


# 掉落的物品
@export var item: Item_Data
# 物品掉落几率(默认100%)
@export_range(0, 100, 1, "suffix:%") var probobility: float = 100
# 物品最小和最大掉落数量
@export_range(1, 10, 1, "suffix:items") var min_amount: int = 1
@export_range(1, 10, 1, "suffix:items") var max_amount: int = 1



# 获取掉落物数量
func get_drop_count() -> int:
	
	# 创建一个0到100的随机数，如果大于掉落几率，就返回0
	if randf_range(0, 100) > probobility:
		return 0
	
	var count: int = randi_range(min_amount, max_amount)
	
	return count
