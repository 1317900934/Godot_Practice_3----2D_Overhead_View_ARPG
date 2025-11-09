@tool
@icon("res://assets/npc_and_dialog/icons/cutscene_bubble.svg")
class_name Dialog_Cutscene
extends Dialog_Item



signal finished

# 定义并行模式和顺序模式
enum Mode {PARRALLEL, SEQUENTIAL}

# 运行模式
@export var playback_mode: Mode = Mode.SEQUENTIAL


# 所有过场动画活动
var actions: Array[Custscene_Action] = []
# 过场动画完成数
var actions_finished_count: int = 0




func _ready() -> void:
	gather_actions()




# 获取并连接所有过场活动
func gather_actions():
	for c in get_children():
		if c is Custscene_Action:
			actions.append(c)
			if Engine.is_editor_hint() == false:
				c.finished.connect(_on_action_finished)





# 开始执行
func play():
	
	if Engine.is_editor_hint(): return
	
	actions_finished_count = 0
	
	if actions.size() == 0:
		await get_tree().process_frame
		finished.emit()
	elif playback_mode == Mode.SEQUENTIAL:
		actions[0].play()
	else:
		for a in actions:
			a.play()
	
	





# 一个过场执行完毕
func _on_action_finished():
	actions_finished_count += 1
	
	if actions_finished_count >= actions.size():
		finished.emit()
	elif playback_mode == Mode.SEQUENTIAL:
		actions[actions_finished_count].play()
