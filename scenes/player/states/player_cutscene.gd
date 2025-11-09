extends State

class_name Player_Cutscene

# 空闲状态引用
@export var state_idle: State




# 初始化
func init() -> void:
	DialogSystem.started.connect(_on_dialog_started)
	DialogSystem.finished.connect(_on_dialog_finished)





# 进入状态
func enter():
	character.update_animation("idle")
	character.process_mode = Node.PROCESS_MODE_ALWAYS



# 退出状态
func exit():
	character.process_mode = Node.PROCESS_MODE_INHERIT




# 持续处理函数
func update(_delta: float) -> State:
	
	# 清空已有的速度向量
	character.velocity = Vector2.ZERO
	
	return null





# 物理持续处理函数
func physics_update(_delta: float) -> State:
	return null








func _on_dialog_started():
	state_machine.change_state(self)





func _on_dialog_finished():
	state_machine.change_state(state_idle)
