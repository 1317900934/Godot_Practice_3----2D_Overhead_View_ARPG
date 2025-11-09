class_name Persistent_Data_Handler
extends Node




signal data_loaded

var data_value: bool = false




func _ready() -> void:
	
	get_value()




# 调用保存管理器，添加持久值到存档中
func set_value():
	SaveManager.add_persistent_value(_get_name())



# 获取当前是否有持久值，并发射信号
func get_value():
	
	data_value = SaveManager.check_persistent_value(_get_name())
	data_loaded.emit()



# 移除持久值数据
func remove_value():
	SaveManager.remove_persistent_value(_get_name())



# 获取标识名
func _get_name() -> String:
	# 返回标识名：当前场景路径/父节点名/本节点名
	return get_tree().current_scene.scene_file_path + "/" + get_parent().name + "/" + name
