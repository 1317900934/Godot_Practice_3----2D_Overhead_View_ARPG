extends Node



signal quest_updated(q)


# 所有任务的存放位置
const QUEST_DATA_LOCATION: String = "res://quests/"




# 游戏中的所有任务
var quests: Array[Quest]
# 玩家已接取的任务
var current_quests: Array = []





func _ready() -> void:
	# 获取所有任务数据
	gather_quests_data()






func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("test"):
		#print( find_current_quest( load("res://quests/recover_lost_flute.tres") as Quest ) )
		#print(find_quest_by_title("测试任务"))
		#print("寻找小老弟的魔法笛：", get_current_quest_index_by_title("寻找小老弟的魔法笛"))
		#print("测试任务：", get_current_quest_index_by_title("测试任务"))
		
		#print("更新前：", current_quests)
		
		#update_quest("测试任务", "", true)
		#update_quest("寻找小老弟的魔法笛")
		#update_quest("测试长期任务", "测试1")
		#update_quest("测试长期任务", "测试2")
		
		
		
		#print("任务：", current_quests)
		
		pass
		







# 收集所有任务数据
func gather_quests_data():
	
	# 获取不含文件夹的所有文件名，收集为一个字符串数组
	var quest_files: PackedStringArray = DirAccess.get_files_at(QUEST_DATA_LOCATION)
	
	# 存储任务目录前先清空一次任务数组
	quests.clear()
	
	# 添加所有任务到数组
	for q in quest_files:
		
		var file_name: String = QUEST_DATA_LOCATION + q.get_basename()
		
		if not file_name.ends_with(".tres"):
			file_name += ".tres"
		
		
		# 加载任务资源文件
		var quest = load(file_name)
		
		
		if quest is Quest:
			quests.append(quest)
	
	
	print("系统任务数量：", quests.size())





# 更新任务状态
func update_quest(_title: String, _completed_step: String = "", _is_complete: bool = false):
	
	# 尝试获取目标任务索引
	var quest_index: int = get_current_quest_index_by_title(_title)
	
	# 如果没有获取到索引，就创建一个新任务加入到已接取任务中
	if quest_index == -1:
		var new_quest: Dictionary = {
			title = _title, 
			is_complete = _is_complete, 
			completed_steps = []
		}
		# 如果有传入任务步骤，就加进此任务中
		if _completed_step != "":
			new_quest.completed_steps.append(_completed_step)
		# 将新任务加入当前接取的任务中
		current_quests.append(new_quest)
		# 发射任务更新信号，并携带新任务的信息
		quest_updated.emit(new_quest)
		
		# 调用玩家HUD，添加一个通知消息
		PlayerHud.queue_notification("接受任务", _title)
		
		
		
	# 如果获取到索引，就更新目标任务
	else:
		var q = current_quests[quest_index]
		# 如果有传入任务步骤，并且目标任务没有对应的步骤，就添加传入的步骤到目标任务
		if _completed_step != "" and q.completed_steps.has(_completed_step) == false:
			q.completed_steps.append(_completed_step)
		
		# 更新目标任务的完成状态
		q.is_complete = _is_complete
		# 发射任务更新信号，并携带更新后目标任务的信息
		quest_updated.emit(q)
		
	
		
		# 如果完成任务，就通知完成并发放奖励，否则通知进度更新
		if q.is_complete == true:
			PlayerHud.queue_notification("任务完成！", _title + " 已完成")
			disperse_quest_rewards(find_quest_by_title(_title))
		else:
			PlayerHud.queue_notification("任务进度完成", _title + "：\n" + _completed_step)







# 给玩家发放任务完成奖励
func disperse_quest_rewards(_q: Quest):
	
	var _message: String ="已获得奖励：" + str(_q.reward_xp) + "玩家经验值"
	
	if _q == null:
		print("任务不存在，无法发放奖励")
		return
	
	PlayerManager.reward_xp(_q.reward_xp)
	
	for i in _q.reward_items:
		PlayerManager.INVENTORY_DATA.add_item(i.item, i.quantity)
		_message += "，" + i.item.name + " x" + str(i.quantity)
	
	PlayerHud.queue_notification("任务奖励已发放！", _message )







# 查找一个已接取的任务
func find_current_quest(_quest: Quest) -> Dictionary:
	
	for q in current_quests:
		if q.title.to_lower() == _quest.title.to_lower():
			return q
	
	return {
		title = "未知任务", is_complete = false, completed_steps = []
	}





# 通过任务标题查找一个任务
func find_quest_by_title(_title: String) -> Quest:
	for q in quests :
		
		if q.title == _title:
			return q
	
	print("在系统中未查找到目标任务")
	return null





# 通过任务标题获取一个已接取任务的索引
func get_current_quest_index_by_title(_title: String) -> int:
	for i in current_quests.size():
		if current_quests[i].title.to_lower() == _title.to_lower():
			return i
	return -1







# 对任务进行排序
func sort_quests():
	var uncompleted_quest: Array = []
	var completed_quest: Array = []
	
	for q in current_quests:
		if q.is_complete:
			completed_quest.append(q)
		else:
			uncompleted_quest.append(q)
	
	uncompleted_quest.sort_custom(sort_quests_ascending)
	completed_quest.sort_custom(sort_quests_ascending)
	
	current_quests = uncompleted_quest
	current_quests.append_array(completed_quest)




# 自定义排序方法
func sort_quests_ascending(a, b):
	if a.title < b.title:
		return true
	return false
