@icon("res://assets/npc_and_dialog/icons/npc_behavior.svg")
class_name NPC_Behavior
extends Node2D


var npc: NPC





func _ready() -> void:
	
	# 获取父节点，如果是NPC，就存储到变量
	var p = get_parent()
	if p is NPC:
		npc = p as NPC
		npc.do_behavior_on.connect(start)




func start():
	pass
