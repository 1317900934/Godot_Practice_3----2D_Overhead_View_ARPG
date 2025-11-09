class_name State
extends Node


# 创建角色和状态机引用，使每个状态类的实例都能访问
static var character: Player
static var state_machine: Player_State_Machine


# 初始化
func init() -> void:
	pass


# 进入状态
func enter():
	pass


# 退出状态
func exit():
	pass


# 持续处理函数
func update(_delta: float) -> State:
	return null


# 物理持续处理函数
func physics_update(_delta: float) -> State:
	return null


# 处理输入事件
func handle_input(_event: InputEvent) -> State:
	return null
