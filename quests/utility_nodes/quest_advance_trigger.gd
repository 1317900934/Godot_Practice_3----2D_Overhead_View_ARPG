@tool
@icon("res://assets/quests/quest_advance.png")
class_name Quest_Advance_Trigger
extends Quest_Node



@export_category("父节点信号连接")
@export var signal_name: String = ""


signal  advanced



func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	$Sprite2D.queue_free()
	
	# 如果有信号名，就连接父节点的对应信号
	if signal_name != "":
		if get_parent().has_signal(signal_name):
			get_parent().connect(signal_name, advance_quest)
		else:
			print("未获取到父节点同名信号")
	



# 任务进展更新
func advance_quest():
	if linked_quest == null: return
	
	# 等待一帧保证父节点先运行
	await get_tree().process_frame
	
	advanced.emit()
	var _title: String = linked_quest.title
	var _step: String = get_step()
	if _step == "N/A":
		_step = ""
	
	QuestManager.update_quest(_title, _step, quest_complete)
