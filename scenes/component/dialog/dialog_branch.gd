@tool
@icon("res://assets/npc_and_dialog/icons/answer_bubble.svg")
class_name Dialog_Branch
extends Dialog_Item


@export var text: String = "好的": set = _set_text


# 对话项目
var dialog_items: Array[Dialog_Item]



@warning_ignore("unused_signal")
signal selected



func _ready() -> void:
	
	super()
	
	if Engine.is_editor_hint():
		return
	
	# 如果子节点有对话项，就加入数组
	for c in get_children():
		if c is Dialog_Item:
			dialog_items.append(c)






# 设置编辑器显示
func _set_editor_display():
	var _p = get_parent()
	if _p is Dialog_Choice:
		set_related_text()
		
		if _p.dialog_branches.size() < 2:
			return
		
		example_dialog.set_dialog_choice_data(_p as Dialog_Choice)




# 获取并显示父级选项的前一个文本节点的内容
func set_related_text():
	var _p = get_parent()
	var _p2 = _p.get_parent()
	var _t = _p2.get_child(_p.get_index() - 1)
	
	if _t is Dialog_Text:
		example_dialog.set_dialog_text_data(_t)
		example_dialog.content.visible_characters = -1






func _set_text(value: String):
	text = value
	if Engine.is_editor_hint():
		if example_dialog != null:
			_set_editor_display()
