class_name Item_Data
extends Resource


# 引用物品名称，物品描述和物品图像
@export var name: String = ""
@export_multiline var description: String = ""
@export var texture: Texture2D


@export_category("Item_Use_Effect")
# 物品使用效果
@export var effects: Array[Item_Effect]

@export var price: int = 10




# 使用物品
func use_item() -> bool:
	
	# 如果使用效果数组没有效果，就返回
	if effects.size() == 0:
		return false
	
	# 遍历使用效果数组中的每一个效果，如果有，就调用其使用函数
	for e in effects:
		if e:
			e.use()
	
	return true
