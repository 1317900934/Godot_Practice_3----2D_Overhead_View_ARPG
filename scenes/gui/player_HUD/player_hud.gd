extends CanvasLayer


@export var button_focus_audio: AudioStream = preload("res://assets/audio/menu_focus.wav")
@export var button_select_audio: AudioStream = preload("res://assets/audio/menu_select.wav")



# 生命数组
var hearts: Array[Heart_GUI] = []




@onready var game_over: Control = $Control/Game_Over
@onready var countinue: Button = $Control/Game_Over/HBoxContainer/Countinue
@onready var back_title: Button = $Control/Game_Over/HBoxContainer/Back_Title
@onready var anim_player: AnimationPlayer = $Control/Game_Over/AnimationPlayer
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

@onready var boss_hp_ui: Control = $Control/Boss_HP
@onready var boss_hp_bar: TextureProgressBar = $Control/Boss_HP/TextureProgressBar
@onready var boss_name: Label = $Control/Boss_HP/Label

@onready var notification_ui: Notification_UI = $Control/Notification

@onready var abilities: Control = $Control/Abilities
@onready var ability_items: HBoxContainer = %Abilities_Hud_Container
@onready var arrow_label: Label = %Arrow_Label
@onready var bomb_label: Label = %Bomb_Label






func _ready() -> void:
	# 遍历流容器中的所有子节点，如果是生命容器，就加入生命数组，默认设置为不可见
	for child in $Control/HFlowContainer.get_children():
		if child is Heart_GUI:
			hearts.append(child)
			child.visible = false
	
	hide_game_over_hud()
	
	update_ability_ui(0)
	
	countinue.focus_entered.connect(play_audio.bind(button_focus_audio))
	countinue.pressed.connect(load_game)
	
	back_title.focus_entered.connect(play_audio.bind(button_focus_audio))
	back_title.pressed.connect(title_screen)
	
	LevelManager.level_loaded.connect(hide_game_over_hud)
	
	hide_boss_bar()
	
	PauseMenu.shown.connect(_on_pause_menu_shown)
	PauseMenu.hidden.connect(_on_pause_menu_hidden)







# 隐藏游戏失败界面
func hide_game_over_hud():
	game_over.visible = false
	game_over.mouse_filter = Control.MOUSE_FILTER_IGNORE
	game_over.modulate = Color(1, 1, 1, 0)





# 显示游戏失败界面
func show_game_over_hud():
	game_over.visible = true
	game_over.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# 如果没有存档，就隐藏加载按钮
	var can_continue: bool = SaveManager.get_save_file() != null
	countinue.visible = can_continue
	
	anim_player.play("show_game_over")
	await anim_player.animation_finished
	
	
	if can_continue == true:
		countinue.grab_focus()
	else:
		back_title.grab_focus()






# 播放音效
func play_audio(_a: AudioStream):
	pass




# 加载游戏存档
func load_game():
	play_audio(button_select_audio)
	await fade_to_black()
	SaveManager.load_game()




# 回到标题界面
func title_screen():
	play_audio(button_select_audio)
	await fade_to_black()
	LevelManager.load_new_level("res://scenes/title_scene/title.tscn", "", Vector2.ZERO)




# 淡出界面为黑色
func fade_to_black() -> bool:
	anim_player.play("fade_to_black")
	await anim_player.animation_finished
	
	# 复活玩家
	await PlayerManager.player.revive_player()
	
	return true









# 更新生命值
func update_hp(_hp: int, _max_hp: int):
	# 首先更新最大生命值
	update_max_hp(_max_hp)
	
	# 遍历最大生命值，更新心形图标
	for i in _max_hp:
		update_heart_sprite(i, _hp)





# 更新心形图标
func update_heart_sprite(_index: int, _hp: int):
	
	# 实际心形图标样式值：空心、半空心、实心，即0到2的整数
	var _value: int = clampi(_hp - _index * 2, 0, 2)
	# 将生命数组中对应索引位的值(心型图标实例)设置为样式值
	hearts[_index].value = _value





# 更新最大生命值，声明需要显示多少心形图标
func update_max_hp(_max_hp: int):
	# 应该显示的心形图标数量：最大生命值的一半
	var _heart_count: int = roundi(_max_hp * 0.5)
	
	# 遍历生命数组的每一个心形图标，如果小于心形数量就显示，否则隐藏
	for i in hearts.size():
		if i < _heart_count:
			hearts[i].visible = true
		else:
			hearts[i].visible = false






# 显示boss生命值进度条
func show_boss_bar(_boss_name: String):
	boss_hp_ui.visible = true
	boss_name.text = _boss_name
	update_boss_hp(1, 1)





# 隐藏boss生命值进度条
func hide_boss_bar():
	boss_hp_ui.visible = false




# 获取boss生命值
func update_boss_hp(hp: int, max_hp: int):
	boss_hp_bar.value = clampf(float(hp) / float(max_hp) * 100, 0, 100)



# 添加一个通知内容
func queue_notification(_title: String, _message: String):
	notification_ui.add_notification_to_queue(_title, _message)





# 更新能力选中的显示
func update_ability_ui(ability_index: int):
	var _items: Array[Node] = ability_items.get_children()
	for a in _items:
		a.self_modulate = Color(1.0, 1.0, 1.0, 0)
		a.modulate = Color(1.0, 1.0, 1.0, 0.6)
	
	_items[ability_index].self_modulate = Color(1.0, 1.0, 1.0, 1.0)
	_items[ability_index].modulate = Color(1.0, 1.0, 1.0, 1.0)
	play_audio(button_focus_audio)





func update_ability_items(items: Array[String]):
	# 获取技能按钮容器中的所有技能图标
	var items_hud: Array[Node] = ability_items.get_children()
	
	
	# 设置是否显示某技能按钮
	for i in items_hud.size():
		if items[i] == "":
			items_hud[i].visible = false
		else:
			items_hud[i].visible = true







# 更新箭矢数量
func update_arrow_count(count: int):
	arrow_label.text = str(count)





# 更新炸弹数量
func update_bomb_count(count: int):
	bomb_label.text = str(count)




# 暂停菜单显示时
func _on_pause_menu_shown():
	abilities.visible = false



# 暂停菜单隐藏时
func _on_pause_menu_hidden():
	abilities.visible = true
