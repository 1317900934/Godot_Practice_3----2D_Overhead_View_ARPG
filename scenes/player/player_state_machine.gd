class_name Player_State_Machine
extends Node


# 状态数组
var states: Array[State]
# 上一个状态
var prev_state: State
# 当前状态
var current_state: State
# 下一个状态
var next_state: State



func _ready() -> void:
	# 禁用当前节点
	process_mode = Node.PROCESS_MODE_DISABLED
	


func _process(delta: float) -> void:
	# 调用改变状态函数，调用并传入当前状态的更新函数(默认得到null)
	change_state(current_state.update(delta))


func _physics_process(delta: float) -> void:
	# 调用改变状态函数，调用并传入当前状态的物理更新函数(默认得到null)
	change_state(current_state.physics_update(delta))


func _unhandled_input(event: InputEvent) -> void:
	# 调用改变状态函数，调用并传入当前状态的处理输入事件函数(默认得到null)
	change_state(current_state.handle_input(event))




# 初始化状态机
func initialize(player: Player):
	# 初始设置状态数组为空
	states = []
	
	# 遍历所有子节点，如果是状态类，就添加进状态数组
	for child in get_children():
		if child is State:
			states.append(child)
	
	
	# 如果状态数组没有状态，就直接返回
	if states.size() == 0:
		print("状态机中没有状态")
		return
	
	
	# 将传入的玩家参数设置到第一个添加进来的状态的角色参数
	# 状态类中的玩家参数是静态变量，所以只需设置一个，其他状态脚本也能共同使用此变量
	states[0].character = player
	states[0].state_machine = self
	
	
	# 调用每个状态的初始化函数
	for state in states:
		state.init()
	
	
	# 切换状态为数组中的第一个状态
	change_state(states[0])
	# 一切准备完毕！重新启用当前节点
	process_mode = Node.PROCESS_MODE_INHERIT






# 改变状态
func change_state(new_state: State):
	# 如果新状态与当前状态相同或为空，就直接返回，否则继续
	if new_state == current_state or new_state == null:
		return
	
	# 获取下一个状态
	next_state = new_state
	
	# 如果当前状态不为空，就调用当前状态的退出函数
	if current_state:
		current_state.exit()
	
	# 将当前状态存储到上一个状态变量
	prev_state = current_state
	# 将新状态设置为当前状态
	current_state = new_state
	# 调用当前状态的进入函数
	current_state.enter()
