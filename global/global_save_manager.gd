extends Node


const SAVE_PATH = "user://"



signal game_loaded
signal game_saved



# 当前保存的数据(场景路径、玩家数据、拥有物品、持久数据、任务)
var current_save: Dictionary = {
	scene_path = "",
	player = {
		level = 1,
		xp = 0,
		hp = 1,
		max_hp = 1,
		attack_power = 1,
		defense_power = 1,
		pos_x = 0,
		pos_y = 0,
		arrow_count = 0,
		bomb_count = 0
	},
	items = [],
	persistence = [],
	quests = [],
	abilities = ["", "", "", ""]
}





# 保存游戏
func save_game():
	
	
	# 调用函数更新存档字典数据
	update_player_data()
	update_scene_path()
	update_item_data()
	update_quest_data()
	# 创建或打开存档文件，存入变量
	var file := FileAccess.open(SAVE_PATH + "data.sav", FileAccess.WRITE)
	# 将存档字典转换为json文本数据
	var save_json = JSON.stringify(current_save)
	# 将json文本数据存入存档文件，后加一个换行符
	file.store_line(save_json)
	# 发射游戏保存完毕信号
	game_saved.emit()
	
	print("[保存游戏] 完毕！")




# 获取存档文件
func get_save_file() -> FileAccess:
	return FileAccess.open(SAVE_PATH + "data.sav", FileAccess.READ)





# 加载游戏存档
func load_game():
	# 读取存档文件，存入变量
	var file := get_save_file()
	
	if file == null:
		print("[读取存档] 失败！未找到存档文件")
		return
	
	# 创建应该json文本数据变量
	var json := JSON.new()
	# 解析存档文件变量的第一行数据
	json.parse(file.get_line())
	# 创建一个字典，获取json数据
	var save_dict: Dictionary = json.get_data() as Dictionary
	# 将此字典赋予当前数据字典
	current_save = save_dict
	
	# 调用关卡管理器，进入目标场景
	LevelManager.load_new_level(current_save.scene_path, "", Vector2.ZERO)
	# 等待关卡加载开始
	await LevelManager.level_load_started
	
	# 读取并设置玩家存档时的位置
	PlayerManager.set_player_position( Vector2(current_save.player.pos_x, current_save.player.pos_y) )
	# 读取并设置玩家存档时的生命值
	PlayerManager.set_player_hp(current_save.player.hp, current_save.player.max_hp)
	
	# 读取并设置玩家属性值
	var p: Player = PlayerManager.player
	p.level = current_save.player.level
	p.xp = current_save.player.xp
	p.attack_power = current_save.player.attack_power
	p.defense_power = current_save.player.defense_power
	p.arrow_count = current_save.player.arrow_count
	p.bomb_count = current_save.player.bomb_count
	
	
	
	# 读取存档中的玩家库存
	PlayerManager.INVENTORY_DATA.parse_save_data(current_save.items)
	# 读取存档中的已接取任务
	QuestManager.current_quests = current_save.quests
	# 发射装备改变信号
	PlayerManager.INVENTORY_DATA.Equipment_Changed.emit()
	
	# 等待关卡加载完毕
	await LevelManager.level_loaded
	# 发射游戏加载完毕信号
	game_loaded.emit()
	
	print("[加载游戏] 完毕！")















# 更新玩家的数据
func update_player_data():
	
	var p: Player = PlayerManager.player
	
	current_save.player.hp = p.hp
	current_save.player.max_hp = p.max_hp
	current_save.player.pos_x = p.global_position.x
	current_save.player.pos_y = p.global_position.y
	current_save.player.level = p.level
	current_save.player.xp = p.xp
	current_save.player.attack_power = p.attack_power
	current_save.player.defense_power = p.defense_power
	current_save.player.arrow_count = p.arrow_count
	current_save.player.bomb_count = p.bomb_count
	current_save.abilities = p.player_abilities.abilities
	






# 更新玩家所处场景的路径
func update_scene_path():
	
	var scene_path: String = ""
	
	# 遍历场景树根部的子节点，如果是关卡类型，就将场景的路径赋值给变量
	for c in get_tree().root.get_children():
		if c is Level:
			scene_path = c.scene_file_path
	
	current_save.scene_path = scene_path





# 更新玩家库存数据
func update_item_data():
	
	# 调用玩家管理器中引用的库存数据，获取库存的字典数组
	current_save.items = PlayerManager.INVENTORY_DATA.get_save_data()





# 更新玩家任务数据
func update_quest_data():
	current_save.quests = QuestManager.current_quests






# 添加持久值到存档中
func add_persistent_value(value: String):
	
	# 如果持久值数组中没有对应的值，就添加
	if not check_persistent_value(value):
		current_save.persistence.append(value)




# 移除存档中的持久值数据
func remove_persistent_value(value: String):
	var p = current_save.persistence as Array
	p.erase(value)






# 检查存档是否有持久值
func check_persistent_value(value: String) -> bool:
	
	var p = current_save.persistence as Array
	
	# 如果持久值数组中有传入的值，就返回true，否则返回false
	return p.has(value)
