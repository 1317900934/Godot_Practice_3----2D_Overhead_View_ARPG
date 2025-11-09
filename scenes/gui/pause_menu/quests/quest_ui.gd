class_name Quest_UI
extends Control



const QUEST_ITEM: PackedScene = preload("res://scenes/gui/pause_menu/quests/quest_item.tscn")
const QUEST_STEP_ITEM: PackedScene = preload("res://scenes/gui/pause_menu/quests/quest_step_item.tscn")


@onready var quest_item_container: VBoxContainer = $ScrollContainer/MarginContainer/VBoxContainer
@onready var details_container: VBoxContainer = $VBoxContainer
@onready var title_label: Label = $VBoxContainer/Title_Label
@onready var description_lable: Label = $VBoxContainer/Description_lable
@onready var null_lable: Label = $Null_Lable





func _ready() -> void:
	
	clear_quest_details()
	visibility_changed.connect(_on_visible_changed)






# 刷新任务容器
func _on_visible_changed():
	
	# 清空容器
	for i in quest_item_container.get_children():
		i.queue_free()
	
	if visible == true:
		
		# 对已接取任务进行排序
		QuestManager.sort_quests()
		# 清空任务详情页内容
		clear_quest_details()
		
		if QuestManager.current_quests.size() == 0:
			null_lable.visible = true
		else:
			null_lable.visible = false
		
		# 添加所有已接取任务到界面中显示
		for q in QuestManager.current_quests:
			var quest_data: Quest = QuestManager.find_quest_by_title(q.title)
			if quest_data == null:
				continue
			# 在界面添加按钮实例
			var new_q_item: Quest_Item = QUEST_ITEM.instantiate()
			quest_item_container.add_child(new_q_item)
			# 初始化任务信息
			new_q_item.initialize(quest_data, q)
			# 焦点进入信号连接刷新详情函数，并携带任务数据
			new_q_item.focus_entered.connect(update_quest_details.bind(new_q_item.quest))
			
			quest_item_container.get_child(0).grab_focus()





# 刷新任务详情页
func update_quest_details(q: Quest):
	clear_quest_details()
	title_label.text = q.title
	description_lable.text = q.description
	
	var quest_save = QuestManager.find_current_quest(q)
	
	# 生成对应任务步骤与进度
	for step in q.steps:
		var new_step: Quest_Step_Item = QUEST_STEP_ITEM.instantiate()
		var step_is_complete: bool = false
		if quest_save.title != "未知任务":
			step_is_complete = quest_save.completed_steps.has(step)
		details_container.add_child(new_step)
		new_step.initialize(step, step_is_complete)
	
	details_container.move_child(description_lable, details_container.get_child_count() )



# 清空任务详情页内容
func clear_quest_details():
	title_label.text = ""
	description_lable.text = ""
	for c in details_container.get_children():
		if c is Quest_Step_Item:
			c.queue_free()
