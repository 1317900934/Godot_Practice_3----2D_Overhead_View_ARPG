extends CanvasLayer


signal shown
signal hidden
signal preview_stats_changed(item: Item_Data)


@onready var audio_player: AudioStreamPlayer = $Control/AudioStreamPlayer
@onready var button_save: Button = $"Control/TabContainer/系统/VBoxContainer/Button_Save"
@onready var button_load: Button = $"Control/TabContainer/系统/VBoxContainer/Button_Load"
@onready var button_quit: Button = $Control/TabContainer/系统/VBoxContainer/Button_Quit
@onready var item_description: Label = $"Control/TabContainer/库存/Item_Description"
@onready var tab_container: TabContainer = $Control/TabContainer



# 是否已暂停
var is_paused: bool = false
# 是否允许暂停
var can_pause: bool = true




func _ready() -> void:
	# 初始隐藏暂停界面
	hide_pause_menu()
	
	# 连接关卡开始转换的信号
	LevelManager.level_transform_start.connect(level_is_transform)
	
	
	# 将按钮连接对应函数
	button_save.pressed.connect(_on_save_pressed)
	button_load.pressed.connect(_on_load_pressed)
	button_quit.pressed.connect(_on_quit_pressed)
	
	# 初始清空物品描述文本
	item_description.text = ""





func _unhandled_input(event: InputEvent) -> void:
	
	
	# 如果按下暂停键并且允许暂停，就根据暂停标志变量来控制游戏暂停和显隐暂停界面
	if event.is_action_pressed("pause") and can_pause:
		if not is_paused:
			if DialogSystem.is_active:
				return
			show_pause_menu()
		else:
			hide_pause_menu()
		
		# 声明输入事件已被处理，防止其他脚本执行输入事件
		get_viewport().set_input_as_handled()
	





# 场景正在转换时，不允许暂停，等待场景转换完毕后才允许
func level_is_transform():
	can_pause = false
	await LevelManager.level_loaded
	can_pause = true






# 显示暂停菜单
func show_pause_menu():
	
	# 暂停场景树，显示暂停界面，开启暂停标志变量
	get_tree().paused = true
	visible = true
	is_paused = true
	
	# 将当前标签设置为第一个
	tab_container.current_tab = 0
	
	# 发射菜单显示信号
	shown.emit()
	
	
	%Arrow_Count_Label.text = str(PlayerManager.player.arrow_count)
	%Bomb_Count_Label.text = str(PlayerManager.player.bomb_count)





# 关闭暂停菜单
func hide_pause_menu():
	
	# 继续场景树，隐藏暂停界面，关闭暂停标志变量
	get_tree().paused = false
	visible = false
	is_paused = false
	
	# 发射菜单关闭信号
	hidden.emit()





# 保存按钮按下
func _on_save_pressed():
	
	if not is_paused:
		return
	
	SaveManager.save_game()
	
	hide_pause_menu()




# 加载按钮按下
func _on_load_pressed():
	
	if not is_paused:
		return
	
	SaveManager.load_game()
	
	await LevelManager.level_load_started
	hide_pause_menu()




# 返回主标题按钮按下
func _on_quit_pressed():
	
	LevelManager.load_new_level("res://scenes/title_scene/title.tscn", "", Vector2.ZERO)
	hide_pause_menu()




# 聚焦物品改变
func focused_item_change(slot: Slot_Data):
	if slot:
		if slot.item_data:
			update_item_description(slot.item_data.description)
			# 显示属性变化预览
			preview_stats(slot.item_data)
	else:
		update_item_description("")
		preview_stats(null)





# 更新物品描述文本
func update_item_description(new_text: String):
	item_description.text = new_text



# 播放音频
func audio_play(sound: AudioStream):
	audio_player.stream = sound
	audio_player.play()



# 预览装备属性值
func preview_stats(item: Item_Data):
	preview_stats_changed.emit(item)





func update_ability_items(items: Array[String]):
	# 获取技能按钮容器中的所有技能按钮
	var item_buttons: Array[Node] = %Ability_Grid_Container.get_children()
	# 移除第一个空白占位节点
	item_buttons.remove_at(0)
	
	
	# 设置是否显示某技能按钮
	for i in item_buttons.size():
		if items[i] == "":
			item_buttons[i].visible = false
		else:
			item_buttons[i].visible = true
