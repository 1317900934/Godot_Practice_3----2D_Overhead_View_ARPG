@tool
class_name Quest_Node
extends Node


@export var linked_quest: Quest = null: set = _set_quest
@export var quest_step: int = 0: set = _set_step
@export var quest_complete: bool = false: set = _set_complete

@export_category("信息文本")
@export_multiline var settings_summary: String





func _set_quest(_v: Quest):
	linked_quest = _v
	quest_step = 0
	update_summary()





func _set_step(_v: int):
	quest_step = clamp(_v, 0, get_step_count())
	update_summary()





# 获取目标任务的步骤个数
func get_step_count() -> int:
	if linked_quest == null:
		return 0
	else:
		return linked_quest.steps.size()





func _set_complete(_v: bool):
	quest_complete = _v
	update_summary()




# 更新摘要文本
func update_summary():
	settings_summary = "更新任务：\n" + linked_quest.title + "\n"
	settings_summary += "进度：" + str(quest_step) + " - " + get_step() + "\n"
	settings_summary += "是否完成：" + str(quest_complete)


# 获取某任务步骤的数据
func get_step() -> String:
	if quest_step != 0 and quest_step <= get_step_count():
		return linked_quest.steps[quest_step - 1]
	else:
		return "N/A"


# 获取当前任务步骤的上一个步骤
func get_preview_step() -> String:
	if quest_step <= get_step_count() and quest_step > 1:
		return linked_quest.steps[quest_step - 2]
	else:
		return "N/A"
