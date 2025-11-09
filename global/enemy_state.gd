class_name Enemy_State
extends Node


# 创建角色和状态机引用
var enemy: Enemy
var state_machine: Enemy_State_Machine


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
func update(_delta: float) -> Enemy_State:
	return null



# 物理持续处理函数
func physics_update(_delta: float) -> Enemy_State:
	return null
