@tool
@icon("res://assets/npc_and_dialog/icons/text_bubble.svg")
class_name Dialog_Text
extends Dialog_Item



@export_multiline var text: String = "示例文本": set = _set_text




func _set_text(value: String):
	text = value
	if Engine.is_editor_hint():
		if example_dialog != null:
			_set_editor_display()




# 设置文本内容在编辑器中显示
func _set_editor_display():
	example_dialog.set_dialog_text_data(self)
	example_dialog.content.visible_characters = -1
