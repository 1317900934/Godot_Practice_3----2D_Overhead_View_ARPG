@tool
@icon("res://assets/npc_and_dialog/icons/question_bubble.svg")
class_name Dialog_Choice
extends Dialog_Item



var dialog_branches: Array[Dialog_Branch]





func _ready() -> void:
	
	super()
	
	# 遍历对话分支，添加到分支数组中
	for c in get_children():
		if c is Dialog_Branch:
			dialog_branches.append(c)





# 设置文本内容在编辑器中显示
func _set_editor_display():
	
	# 获取并显示选项的前一个文本节点的内容
	set_related_text()
	
	if dialog_branches.size() < 2:
		return
	
	example_dialog.set_dialog_choice_data(self)




# 获取并显示选项的前一个文本节点的内容
func set_related_text():
	var _p = get_parent()
	var _t = _p.get_child(self.get_index() - 1)
	
	if _t is Dialog_Text:
		example_dialog.set_dialog_text_data(_t)
		example_dialog.content.visible_characters = -1




# 如果有错误就返回警告
func _get_configuration_warnings() -> PackedStringArray:
	if _check_for_dialog_branchs() == false:
		return ["需要至少两个对话分支项节点"]
	else:
		return []






# 检查对话分支节点是否可用
func _check_for_dialog_branchs() -> bool:
	var _count: int = 0
	
	# 遍历子节点，如果有两个及以上的分支，就返回true
	for c in get_children():
		if c is Dialog_Branch:
			_count += 1
			if _count > 1:
				return true
	
	return false
