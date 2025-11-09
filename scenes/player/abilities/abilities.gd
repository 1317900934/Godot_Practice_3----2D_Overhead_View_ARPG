class_name Player_Abilities
extends Node


# 回旋镖场景
const BOOMERANG = preload("uid://3ujvw78oucfa")
# 炸弹场景
const BOMB = preload("uid://bakxhwpotnxw4")





@onready var state_machine: Player_State_Machine = $"../State_Machine"
@onready var lift: Player_Lift = $"../State_Machine/Lift"
@onready var idle: Player_Idle = $"../State_Machine/Idle"
@onready var move: Player_Walk = $"../State_Machine/Move"
@onready var bow: Player_Bow = $"../State_Machine/Bow"
@onready var grapple: Player_Grapple = $"../State_Machine/Grapple"



# 玩家拥有的能力
var abilities: Array[String] = [
	"BOOMERANG", # "BOOMERANG"
	"",# "GRAPPLE"
	"",# "BOW"
	""# "BOMB"
	]


# 当前选中的能力
var current_ability: int = 0
# 玩家引用
var player: Player
# 回旋镖实例
var boomerang_instance: Boomerang = null





func _ready() -> void:
	player = PlayerManager.player
	PlayerHud.update_arrow_count(player.arrow_count)
	PlayerHud.update_bomb_count(player.bomb_count)
	
	setup_abilities()
	
	SaveManager.game_loaded.connect(_on_game_loaded)
	
	PlayerManager.INVENTORY_DATA.add_ability.connect(_on_add_ability)





func _unhandled_input(event: InputEvent) -> void:
	
	# 如果技能键被按下，就根据当前选中的技能释放出对应的功能
	if event.is_action_pressed("ability"):
		
		match current_ability:
			0:
				boomerang_ability()
			
			1:
				grapple_ability()
			
			2:
				arrow_ability()
			
			3:
				bomb_ability()
			
	# 如果切换技能键被按下，就切换选中的技能
	elif event.is_action_pressed("ability_switch"):
		toggle_ability()






func setup_abilities(select_index: int = 0):
	
	PauseMenu.update_ability_items(abilities)
	PlayerHud.update_ability_items(abilities)
	
	current_ability = select_index - 1
	toggle_ability()









# 切换选中的技能
func toggle_ability():
	
	if abilities.count("") == abilities.size():
		return
	
	current_ability = wrapi(current_ability + 1, 0, 4)
	
	while abilities[current_ability] == "":
		current_ability = wrapi(current_ability + 1, 0, 4)
	
	PlayerHud.update_ability_ui(current_ability)







# 释放回旋镖能力
func boomerang_ability():
	
	# 如果当前有回旋镖实例，就返回，确保同时只存在一个飞镖
	if boomerang_instance != null: return
	# 回旋镖实例化
	var _b = BOOMERANG.instantiate() as Boomerang
	# 将回旋镖实例添加为玩家的同级节点
	player.add_sibling(_b)
	# 设置回旋镖位置
	_b.global_position = player.global_position + Vector2(0, -10)
	
	# 设置投掷方向；如果没有移动，就设置为玩家朝向
	var throw_dir = player.move_direction
	if player.move_direction == Vector2.ZERO:
		throw_dir = player.direction
	
	# 开始投掷
	_b.throw(throw_dir)
	
	# 绑定回旋镖实例
	boomerang_instance = _b






# 释放抓钩能力
func grapple_ability():
	if state_machine.current_state == idle or state_machine.current_state == move:
		player.state_machine.change_state(grapple)






# 释放弓箭能力
func arrow_ability():
	if player.arrow_count <= 0:
		return
	elif state_machine.current_state == idle or state_machine.current_state == move:
		player.arrow_count -= 1
		player.state_machine.change_state(bow)







# 释放炸弹能力
func bomb_ability():
	if player.bomb_count <= 0:
		return
	elif state_machine.current_state == idle or state_machine.current_state == move:
		player.bomb_count -= 1
		lift.start_anim_late = true
		# 生成炸弹
		var bomb: Node2D = BOMB.instantiate()
		player.add_sibling(bomb)
		bomb.global_position = player.global_position
		# 使玩家拾起炸弹
		PlayerManager.interact_handle = false
		var throwable: Throwable_Bomb = bomb.find_child("Throwable")
		throwable.player_interact()




# 加载游戏存档中的数据
func _on_game_loaded():
	var new_abilities = SaveManager.current_save.abilities
	
	abilities.clear()
	for i in new_abilities:
		abilities.append(i)
	
	setup_abilities()




func _on_add_ability(_ability: Ability_Item_Data):
	print("获得能力",_ability.type)
	
	match _ability.type:
		
		_ability.Type.BOOMERANG:
			abilities[0] = "BOOMERANG"
		
		_ability.Type.GRAPPLE:
			abilities[1] = "GRAPPLE"
		
		_ability.Type.BOW:
			abilities[2] = "BOW"
		
		_ability.Type.BOMB:
			abilities[3] = "BOMB"
	
	setup_abilities(current_ability)
