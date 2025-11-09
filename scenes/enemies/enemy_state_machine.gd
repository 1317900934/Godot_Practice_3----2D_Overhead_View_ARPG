class_name Enemy_State_Machine
extends Node


# 状态数组
var states: Array[Enemy_State]
# 上一个状态
var prev_state: Enemy_State
# 当前状态
var current_state: Enemy_State


func _ready() -> void:
	# 禁用当前节点
	process_mode = Node.PROCESS_MODE_DISABLED
	


func _process(delta: float) -> void:
	# 调用改变状态函数，调用并传入当前状态的更新函数(默认得到null)
	change_state(current_state.update(delta))


func _physics_process(delta: float) -> void:
	# 调用改变状态函数，调用并传入当前状态的物理更新函数(默认得到null)
	change_state(current_state.physics_update(delta))





# 初始化状态机
func initialize(_enemy: Enemy):
	# 初始设置状态数组为空
	states = []
	
	# 遍历所有子节点，如果是状态类，就添加进状态数组
	for child in get_children():
		if child is Enemy_State:
			states.append(child)
	
	# 遍历状态数组中的状态，给每个状态的敌人引用和状态机引用都添加绑定,然后调用其初始化函数
	for s in states:
		s.enemy = _enemy
		s.state_machine = self
		s.init()
	
	
	# 如果数组存在状态，就切换为第一个状态，并重新启用节点
	if states.size() > 0:
		# 改变状态为数组中的第一个状态
		change_state(states[0])
		# 一切准备完毕！重新启用当前节点
		process_mode = Node.PROCESS_MODE_INHERIT




# 改变状态
func change_state(new_state: Enemy_State ):
	# 如果新状态与当前状态相同或为空，就直接返回，否则继续
	if new_state == current_state or new_state == null:
		return
	
	# 如果当前状态不为空，就调用当前状态的退出函数
	if current_state:
		current_state.exit()
	
	# 将当前状态存储到上一个状态变量
	prev_state = current_state
	
	# 将新状态设置为当前状态
	current_state = new_state
	
	# 调用当前状态的进入函数
	current_state.enter()
