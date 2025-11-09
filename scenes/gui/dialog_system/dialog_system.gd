@tool
@icon("res://assets/npc_and_dialog/icons/star_bubble.svg")
class_name Dialog_System_Node
extends CanvasLayer


signal started
signal finished


# 文本是否在逐渐显现
var text_in_progress: bool = false
# 文本显现速度
var text_speed: float = 0.02
# 文本长度
var text_length: int = 0
# 没有特殊样式信息的纯文本
var pure_text: String
# 根据字符计数播放音效
var letter_count: int = 0
# npc基准音调
var audio_pitch_base: float = 1.0


# 是否正在等待用户选择选项
var waiting_choice: bool = false
# 是否正在观看过场动画
var watching_cutscene: bool = false




# 对话文本内容
var dialog_items: Array[Dialog_Item]
# 对话文本分页索引
var dialog_item_index: int = 0


var is_active: bool = false


@onready var dialog_ui: Control = $Dialog_UI
@onready var content: RichTextLabel = $Dialog_UI/PanelContainer2/RichTextLabel
@onready var npc_name: RichTextLabel = $Dialog_UI/PanelContainer/RichTextLabel
@onready var portrait: Sprite2D = $Dialog_UI/Portrait
@onready var progress_indicator: PanelContainer = $Dialog_UI/Progress_Indicator
@onready var indicator_label: Label = $Dialog_UI/Progress_Indicator/Label
@onready var timer: Timer = $Dialog_UI/Timer
@onready var audio_player: AudioStreamPlayer = $Dialog_UI/AudioStreamPlayer
@onready var choice_options: VBoxContainer = $Dialog_UI/VBoxContainer



func _ready() -> void:
	# 在编辑器中运行时删掉自己
	if Engine.is_editor_hint():
		if get_viewport() is Window:
			get_parent().remove_child(self)
			return
		return
	
	# 将文本进度计时器的信号连接显示函数
	timer.timeout.connect(_on_timer_timeout)
	
	# 隐藏进度指示器和对话界面
	show_indicator(false)
	hide_dialog()





func _unhandled_input(event: InputEvent) -> void:
	
	if is_active == false or watching_cutscene == true:
		return
	
	
	# 如果按下了交互、攻击或确认键，就推进对话
	if(
		event.is_action_pressed("interact") or
		event.is_action_pressed("attack") or 
		event.is_action_pressed("ui_accept")
	):
		# 如果文本正在逐渐显现，点击就立刻显示当页所有文本
		if text_in_progress == true:
			content.visible_characters = text_length
			timer.stop()
			text_in_progress = false
			show_indicator(true)
			return
		# 如果正在等待选择，就返回输入
		elif waiting_choice == true:
			return
		
		advance_dialog()







# 推进对话项
func advance_dialog():
	# 文本页索引加1
		dialog_item_index += 1
		# 如果还有下一页，就继续显示，否则关闭对话界面
		if dialog_item_index < dialog_items.size():
			start_dialog()
		else:
			hide_dialog()





# 显示对话界面
func show_dialog(_items: Array[Dialog_Item]):
	waiting_choice = false
	is_active = true
	
	if _items:
		if _items[0] is Dialog_Cutscene:
			dialog_ui.visible = false
		else:
			dialog_ui.visible = true
		
		for i in _items:
			if i is Dialog_Cutscene:
				$Cutscene_Black_UI/AnimationPlayer.play("start")
	
	dialog_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	dialog_items = _items
	dialog_item_index = 0
	PlayerHud.ability_items.visible = false
	get_tree().paused = true
	
	await get_tree().process_frame
	
	started.emit()
	
	# 如果没有对话项了，就关闭对话，否则继续显示对话
	if dialog_items.size() == 0:
		hide_dialog()
	else:
		start_dialog()
	




# 隐藏对话界面
func hide_dialog():
	is_active = false
	choice_options.visible = false
	dialog_ui.visible = false
	dialog_ui.process_mode = Node.PROCESS_MODE_DISABLED
	PlayerHud.ability_items.visible = true
	get_tree().paused = false
	finished.emit()
	PlayerManager.reset_camera_on_player()
	
	$Cutscene_Black_UI/AnimationPlayer.play("end")




# 显示对话文本内容
func start_dialog():
	# 隐藏对话进度指示器
	show_indicator(false)
	# 获取对话文本对应分页的内容
	var _d: Dialog_Item = dialog_items[dialog_item_index]
	
	# 如果是对话文本，就设置文本数据
	if _d is Dialog_Text:
		set_dialog_text_data(_d as Dialog_Text)
	# 如果是对话选项，就设置选项数据
	elif _d is Dialog_Choice:
		set_dialog_choice_data(_d as Dialog_Choice)
	# 如果是过场动画，就开始过场
	elif _d is Dialog_Cutscene:
		start_dialog_cutscene(_d as Dialog_Cutscene)





# 开始过场动画
func start_dialog_cutscene(_d: Dialog_Cutscene):
	watching_cutscene = true
	_d.play()
	choice_options.visible = false
	dialog_ui.visible = false
	
	# 等待过场动画结束后重新启用对话UI并推进对话项
	await _d.finished
	watching_cutscene = false
	choice_options.visible = true
	dialog_ui.visible = true
	advance_dialog()
	






# 设置对话文本数据
func set_dialog_text_data(_d: Dialog_Text):
	
	choice_options.visible = false
	# 获取文本内容、姓名、肖像、基础音调
	content.text = _d.text
	npc_name.text = _d.npc_info.npc_name
	portrait.texture = _d.npc_info.portrait
	audio_pitch_base = _d.npc_info.dialog_audio_pitch
	
	# 获取文本内容长度并使其逐渐显现
	content.visible_characters = 0
	text_length = content.get_total_character_count()
	pure_text = content.get_parsed_text()
	text_in_progress = true
	start_timer()





# 设置对话选项数据
func set_dialog_choice_data(_d: Dialog_Choice):
	# 显示选项
	choice_options.visible = true
	# 设置等待选择状态
	waiting_choice = true
	# 先清空所有对话选项
	for c in choice_options.get_children():
		c.queue_free()
	
	# 添加对应数量的选项按钮
	for i in _d.dialog_branches.size():
		var _new_choice: Button = Button.new()
		choice_options.add_child(_new_choice)
		_new_choice.text = _d.dialog_branches[i].text
		_new_choice.alignment = HORIZONTAL_ALIGNMENT_CENTER
		# 连接信号，一旦选项按下，就调用函数并传入对应的选项
		_new_choice.pressed.connect(_dialog_choice_selected.bind(_d.dialog_branches[i]))
	
	if Engine.is_editor_hint():
		return
	
	# 等待选项生成后抓取第一个焦点
	await get_tree().process_frame
	await get_tree().process_frame
	choice_options.get_child(0).grab_focus()





# 对话选项被选择
func _dialog_choice_selected(_d: Dialog_Branch):
	# 关闭选项界面
	choice_options.visible = false
	# 显示对应选项的对话文本
	
	show_dialog(_d.dialog_items)
	
	# 使对应选项节点发射信号
	_d.selected.emit()









# 计时器结束
func _on_timer_timeout():
	# 增加一个显示字符
	content.visible_characters += 1
	
	# 如果文本未完，就再次开启计时器，否则显示对话进度指示器
	if content.visible_characters <= text_length:
		letter_count += 1
		if letter_count == 2:
			audio_player.pitch_scale = randf_range(audio_pitch_base - 0.1, audio_pitch_base + 0.1)
			audio_player.play()
			letter_count = 0
		start_timer()
	else:
		show_indicator(true)
		text_in_progress = false






# 控制对话进度指示器
func show_indicator(_is_visible: bool):
	progress_indicator.visible = _is_visible
	if dialog_item_index + 1 < dialog_items.size():
		indicator_label.text = "继续"
	else:
		indicator_label.text = "退出"








# 开始文本显示计时器
func start_timer():
	timer.wait_time = text_speed
	
	timer.start()
