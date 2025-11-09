@tool
@icon("res://assets/quests/quest_switch.png")
class_name Quest_Activated_Switch
extends Quest_Node


# 所有检查模式：是否有任务、任务步骤是否完成、当前正进行的步骤、整个任务是否完成
enum Check_Mode {
	HAS_QUEST,
	QUEST_STEP_COMPLETE,
	ON_CURRENT_QUEST_STEP,
	QUEST_COMPLETE
	}


# 状态改变
signal is_activated_changed(v: bool)


# 检查模式
@export var check_mode: Check_Mode = Check_Mode.HAS_QUEST: set = _set_check_mode
# 激活时是否移除
@export var remove_when_activated: bool = false
# 移除时是否释放
@export var free_when_remove: bool = false
# 是否响应任务管理器发射的更新信号
@export var react_global_signal: bool = false



# 是否激活
var is_activated: bool = false





func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	if has_node("Sprite2D"):
		$Sprite2D.queue_free()
	
	if react_global_signal == true:
		QuestManager.quest_updated.connect(_on_quest_update)
	
	check_is_activated()






# 根据节点模式检查是否激活
func check_is_activated():
	# 获取目标任务字典数据
	var _q: Dictionary = QuestManager.find_current_quest(linked_quest)
	
	# 如果找到目标任务，就根据不同模式的条件决定是否应该激活，否则设置为禁用状态
	if _q.title != "未知任务":
		
		if check_mode == Check_Mode.HAS_QUEST:
			set_is_activated(true)
			
		elif check_mode == Check_Mode.QUEST_COMPLETE:
			var is_complete: bool = false
			if _q.is_complete is bool:
				is_complete = _q.is_complete
			set_is_activated(is_complete)
			
		elif check_mode == Check_Mode.QUEST_STEP_COMPLETE:
			if quest_step > 0:
				# 如果任务完成步骤中有当前步骤，就激活，否则禁用
				if _q.completed_steps.has(get_step()):
					set_is_activated(true)
				else:
					set_is_activated(false)
			
		elif check_mode == Check_Mode.ON_CURRENT_QUEST_STEP:
			var step: String = get_step()
			if step == "N/A":
				set_is_activated(false)
			else:
				if _q.completed_steps.has(step):
					set_is_activated(false)
				else:
					var pre_step: String = get_preview_step()
					# 如果没有前一个步骤或数据中存在前一个步骤，就设置为激活，否则禁用
					if pre_step == "N/A" or _q.completed_steps.has(pre_step):
						set_is_activated(true)
					else:
						set_is_activated(false)
		
	else:
		set_is_activated(false)









# 设置是否激活
func set_is_activated(_v: bool):
	is_activated = _v
	is_activated_changed.emit(_v)
	
	if is_activated == true:
		if remove_when_activated == true:
			hide_children()
		else:
			show_children()
	else:
		if remove_when_activated == true:
			show_children()
		else:
			hide_children()







# 显示子节点
func show_children():
	for c in get_children():
		c.visible = true
		c.process_mode = Node.PROCESS_MODE_INHERIT




# 隐藏子节点
func hide_children():
	for c in get_children():
		c.set_deferred("visible", false)
		c.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
		if free_when_remove:
			c.queue_free()






# 任务管理器中的任务更新时，检查是否需要激活
func _on_quest_update(_q: Dictionary):
	check_is_activated()






# 更新摘要文本
func update_summary():
	if linked_quest == null:
		settings_summary = "选择一个任务："
		return
	
	settings_summary = "更新任务：\n" + linked_quest.title + "\n"
	
	if check_mode == Check_Mode.HAS_QUEST:
		settings_summary += "[正在检查玩家是否有任务]"
		
	elif check_mode == Check_Mode.QUEST_STEP_COMPLETE:
		settings_summary += "[正在检查玩家是否完成任务步骤：" + get_step() + "]"
		
	elif check_mode == Check_Mode.ON_CURRENT_QUEST_STEP:
		settings_summary += "[正在检查玩家是否处于任务步骤：" + get_step() + "]"
		
	elif check_mode == Check_Mode.QUEST_COMPLETE:
		settings_summary += "[正在检查任务是否完成]" 
		
	elif check_mode == Check_Mode.ON_CURRENT_QUEST_STEP:
		settings_summary += "[正在检查当前是否处于任务步骤：" + get_step() + "]"



func _set_check_mode(_v: Check_Mode):
	check_mode = _v
	update_summary()
