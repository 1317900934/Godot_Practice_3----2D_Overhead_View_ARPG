class_name Equipable_Item_Data
extends Item_Data


enum Type {WEAPON, ARMOR, AMULET, RING}


# 装备类型
@export var type: Type = Type.WEAPON
# 装备的属性加成
@export var modifiers: Array[Equipable_Item_Modifier]
# 装备的纹理
@export var sprite_texture: Texture
