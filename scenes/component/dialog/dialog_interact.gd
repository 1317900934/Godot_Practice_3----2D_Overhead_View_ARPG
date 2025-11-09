@tool
@icon("res://assets/npc_and_dialog/icons/chat_bubbles.svg")
class_name Dialog_Interact
extends Area2D




signal player_interacted

signal finished



# 是否启用对话交互
@export var enabled: bool = true


# 对话项目
var dialog_items: Array[Dialog_Item]


@onready var anim_player: AnimationPlayer = $AnimationPlayer




func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	
	# 如果子节点有对话项，就加入数组
	for c in get_children():
		if c is Dialog_Item:
			dialog_items.append(c)





# 检查子节点是否有对话文本节点
func _check_for_dialog_items() -> bool:
	# 如果子节点有对话项，就加入数组
	for c in get_children():
		if c is Dialog_Item:
			return true
	
	return false





# 如果有错误就返回警告
func _get_configuration_warnings() -> PackedStringArray:
	if _check_for_dialog_items() == false:
		return ["需要至少一个对话项节点"]
	else:
		return []





# 玩家交互
func player_interact():
	player_interacted.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	DialogSystem.show_dialog(dialog_items)
	DialogSystem.finished.connect(_on_dialog_finished)





# 玩家进入对话交互范围
func _on_area_entered(_a: Area2D):
	if enabled == false or dialog_items.size() == 0:
		print("错误")
		return
	anim_player.play("show")
	PlayerManager.interact_pressed.connect(player_interact)




# 玩家退出对话交互范围
func _on_area_exited(_a: Area2D):
	anim_player.play("hide")
	PlayerManager.interact_pressed.disconnect(player_interact)






# 对话结束
func _on_dialog_finished():
	DialogSystem.finished.disconnect(_on_dialog_finished)
	finished.emit()
