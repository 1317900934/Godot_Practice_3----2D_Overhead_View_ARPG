class_name Quest_Item
extends Button



var quest: Quest


@onready var title_label: Label = $Title
@onready var step_label: Label = $Step



# 根据任务资源和任务字典数据初始化任务信息
func initialize(q_data: Quest, q_state):
	quest = q_data
	title_label.text = q_data.title
	
	if q_state.is_complete:
		step_label.text = "已完成"
		step_label.modulate = Color.LIME_GREEN
	else:
		var step_count: int = q_data.steps.size()
		var completed_count: int = q_state.completed_steps.size()
		step_label.text = "进度：" + str(completed_count) + "/" + str(step_count)
