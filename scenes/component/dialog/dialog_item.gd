@tool
@icon("res://assets/npc_and_dialog/icons/chat_bubble.svg")
class_name Dialog_Item
extends Node



# 引用npc信息
@export var npc_info: NPC_Resource


# 编辑器选择
var editor_selection
# 示例对话框
var example_dialog: Dialog_System_Node




func _ready() -> void:
	# 如果在编辑器中，就连接选择信号，使其在编辑器中被选中时显示预览
	if Engine.is_editor_hint():
		# 获取编辑器接口实例
		editor_selection = Engine.get_singleton("EditorInterface").get_selection()
		# 将编辑器选择信号连接函数
		editor_selection.selection_changed.connect(_on_selection_changed)
		return
	
	check_npc_data()








# 检查并获取npc资源数据
func check_npc_data():
	if npc_info == null:
		var p = self
		var _checking: bool = true
		
		while _checking == true:
			p = p.get_parent()
			if p:
				if p is NPC and p.npc_resource:
					npc_info = p.npc_resource
					_checking = false
			else:
				_checking = false





func _on_selection_changed():
	if editor_selection == null:
		return
	
	var sel = editor_selection.get_selected_nodes()
	
	# 如果有示例对话框，就先清除
	if example_dialog != null:
		example_dialog.queue_free()
	
	
	# 如果有一个选择，就实例化并添加示例节点
	if not sel.is_empty():
		if self == sel[0]:
			example_dialog = load("res://scenes/gui/dialog_system/dialog_system.tscn").instantiate() as Dialog_System_Node
		if example_dialog == null:
			return
		self.add_child(example_dialog)
		
		# 偏移界面位置
		example_dialog.offset = parent_global_pos() + Vector2(32, -200)
		# 检查并获取npc资源数据
		check_npc_data()
		# 设置编辑器显示对应内容
		_set_editor_display()






# 获取父节点的全局位置
func parent_global_pos() -> Vector2:
	var p = self
	var _checking: bool = true
	while _checking == true:
		p = p.get_parent()
		if p:
			if p is Node2D:
				return p.global_position
		else:
			_checking = false
	
	return Vector2.ZERO







# 创建空函数让子类重写
func _set_editor_display():
	pass
