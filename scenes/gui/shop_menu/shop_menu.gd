extends CanvasLayer


const ERROR = preload("uid://bc3p5cukjrn6t")
const OPEN_SHOP = preload("uid://beqb4mjin6jkp")
const SHOP_ITEM_BUTTON = preload("uid://cgviu4g1phs2o")
const MENU_FOCUS = preload("uid://c7q40hm46vdph")
const MENU_SELECT = preload("uid://da8tk2aiqb7vt")


@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var close: Button = %Close
@onready var buy: Button = %Buy
@onready var shop_item_container: VBoxContainer = %Shop_Item_Container
@onready var gems_label: Label = %Gems_Label


@onready var item_image: TextureRect = %Item_Image
@onready var item_name: Label = %Item_Name
@onready var item_price: Label = %Item_Price
@onready var inventory_count: Label = %Inventory_Count
@onready var item_description: Label = %Item_Description
@onready var anim_player: AnimationPlayer = $Control/Player_Gems/AnimationPlayer



signal shown
signal hidden


var is_active: bool = false

var currency: Item_Data = preload("uid://b8eu7po5wx45m")

var selected_item: Item_Data



func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide_menu()
	close.pressed.connect(hide_menu)
	buy.pressed.connect(buy_item)




func _unhandled_input(event: InputEvent) -> void:
	if is_active == false:
		return
	
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		hide_menu()






# 显示商店界面
func show_menu(items: Array[Item_Data], dialog_triggered: bool = true):
	if dialog_triggered:
		await DialogSystem.finished
	enable_menu()
	populate_item_list(items)
	update_gems_label()
	shop_item_container.get_child(0).grab_focus()
	play_audio(OPEN_SHOP)
	shown.emit()





# 隐藏商店界面
func hide_menu():
	enable_menu(false)
	clear_item_list()
	hidden.emit()




func enable_menu(_enable: bool = true):
	get_tree().paused = _enable
	visible = _enable
	is_active = _enable




# 填充商店列表
func populate_item_list(items: Array[Item_Data]):
	
	for item in items:
		var shop_item: Shop_Item_Button = SHOP_ITEM_BUTTON.instantiate()
		shop_item.setup(item)
		shop_item_container.add_child(shop_item)
		shop_item.focus_entered.connect(focused_item_changed.bind(item))






# 清空商店列表
func clear_item_list():
	for c in shop_item_container.get_children():
		c.queue_free()




# 更新已持有宝石数量显示
func update_gems_label():
	gems_label.text = str(get_item_quantity(currency))




# 获取物品持有数量
func get_item_quantity(_item: Item_Data) -> int:
	return PlayerManager.INVENTORY_DATA.get_item_held_quantity(_item)





# 商品焦点改变
func focused_item_changed(item: Item_Data):
	play_audio(MENU_FOCUS)
	if item:
		update_item_details(item)
		selected_item = item






# 更新商品详情
func update_item_details(item: Item_Data):
	item_image.texture = item.texture
	item_description.text = item.description
	item_price.text = str(item.price)
	item_name.text = item.name
	inventory_count.text = str(get_item_quantity(item))
	





# 购买物品
func buy_item():
	if not selected_item: return
	
	# 判断货币数量是否足够购买
	var can_buy: bool = get_item_quantity(currency) >= selected_item.price
	
	if can_buy:
		PlayerManager.INVENTORY_DATA.remove_item(currency, selected_item.price)
		update_gems_label()
		PlayerManager.INVENTORY_DATA.add_item(selected_item)
		play_audio(MENU_SELECT)
		update_item_details(selected_item)
	else:
		play_audio(ERROR)
		anim_player.play("not_enough_gems")
		anim_player.seek(0)









func play_audio(_audio: AudioStream):
	audio_player.stream = _audio
	audio_player.play()
