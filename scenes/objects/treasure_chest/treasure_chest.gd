@tool
class_name Treasure_Chest
extends Node2D


# 物品信息
@export var item_data: Item_Data: set = _set_item_data
# 物品数量
@export var quantity: int = 1: set = _set_item_quantity


# 宝箱是否已打开
var is_opened: bool = false


@onready var chest_sprite: Sprite2D = $Chest_Sprite
@onready var label: Label = $Item_Info/Label
@onready var item_sprite: Sprite2D = $Item_Info/Item_Sprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var interact_area: Area2D = $Area2D
@onready var is_open_data: Persistent_Data_Handler = $IS_Open




func _ready() -> void:
	
	
	
	#更新纹理和标签
	_update_item_texture()
	_update_label()
	
	# 如果当前脚本正在编辑器中运行，就返回
	if Engine.is_editor_hint():
		return
	
	# 连接进入和退出区域信号
	interact_area.area_entered.connect(_on_area_enter)
	interact_area.area_exited.connect(_on_area_exit)
	
	# 将箱子打开数据信号连接函数
	is_open_data.data_loaded.connect(set_chest_state)
	# 设置箱子打开状态
	set_chest_state()
	
	



# 玩家交互
func player_ineract():
	
	# 如果宝箱已打开，就返回
	if is_opened: return
	# 隐藏玩家提示
	PlayerManager.player.hide_tips_anim()
	
	# 声明宝箱已打开，保存打开状态并播放打开动画
	is_opened = true
	is_open_data.set_value()
	animation_player.play("open_chest")
	
	# 如果有物品数据并且数量大于0，就让玩家库存添加物品，否则在输出面板和调试器中打印错误
	if item_data and quantity > 0:
		
		if item_data.name == "炸弹":
			PlayerManager.player.bomb_count += quantity
		elif item_data.name == "箭矢":
			PlayerManager.player.arrow_count += quantity
		else:
			PlayerManager.INVENTORY_DATA.add_item(item_data, quantity)
	else:
		printerr("[空数据] 宝箱 ", name, " 中没有物品")
		push_error("[空数据] 宝箱 ", name, " 中没有物品")




# 玩家交互区域进入
func _on_area_enter(_a: Area2D):
	
	PlayerManager.interact_pressed.connect(player_ineract)
	




# 玩家交互区域退出
func _on_area_exit(_a: Area2D):
	
	PlayerManager.interact_pressed.disconnect(player_ineract)
	





func _set_item_data(value: Item_Data):
	item_data = value
	_update_item_texture()


func _set_item_quantity(value: int):
	quantity = value
	_update_label()





# 更新物品纹理
func _update_item_texture():
	if item_data and item_sprite:
		item_sprite.texture = item_data.texture
	
	if item_data == null and item_sprite:
		item_sprite.texture = null



# 更新标签
func _update_label():
	# 如果物品数量小于等于1，标签文本就为空，否则显示对应数量的文本
	if label:
		if quantity <= 1:
			label.text = ""
		else:
			label.text = "×" + str(quantity)




# 获取箱子打开数据，如果已打开，就播放已打开动画，否则播放关闭动画
func set_chest_state():
	
	is_opened = is_open_data.data_value
	
	if is_opened:
		animation_player.play("opened")
	else:
		animation_player.play("closed")
