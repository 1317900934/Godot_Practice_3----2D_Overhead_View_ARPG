@tool

class_name Level_Transform
extends Area2D

signal player_entered


enum SIDE { Left, Right, Top, Bottom }


# 引用某个场景文件作为关卡变量
@export_file("*.tscn") var level

# 目标转换区域
@export var target_transform_area: String = "Level_Transform"

# 检查器属性分隔符
@export_category("Collison_Area_Settings")

# 大小范围;更改数值时，更新区域大小
@export_range(1, 12, 1, "or_greater") var size: int = 2:
	set(v):
		size = v
		update_area()

# 方向;更改数值时，更新区域方向
@export var side: SIDE = SIDE.Bottom:
	set(v):
		side = v
		update_area()

# 是否对齐网格
@export var snap_to_grid: bool = false:
		set(v):
			_snap_to_grid()


# 进入后，玩家是否在出口中间位置
@export var center_player: bool = false





# 碰撞形状引用
@onready var collision_shape: CollisionShape2D = $CollisionShape2D










func _ready() -> void:
	
	update_area()
	
	# 如果脚本当前正在编辑器中运行，就直接返回
	if Engine.is_editor_hint():
		return
	
	# 先关闭区域检测，防止一开始玩家意外落在区域内
	monitoring = false
	
	# 设置玩家进入位置
	_place_player()
	
	# 等待关卡加载完毕的信号
	await LevelManager.level_loaded
	
	# 重新开启区域检测
	monitoring = true
	
	# 将物体进入方法连接到玩家进入函数
	body_entered.connect(_player_entered)




# 玩家进入区域时调用
func _player_entered(_object: Node2D):
	
	# 如果是玩家，就加载新场景，并传入目标关卡名、目标区域位置和位置偏移量
	if _object is Player:
		LevelManager.load_new_level(level, target_transform_area, get_offset())





# 设置玩家进入场景时的位置
func _place_player():
	
	# 如果此区域名不是关卡管理器中的目标区域名，就直接返回
	if name != LevelManager.target_transform:
		return
	
	# 设置玩家的位置为此区域的位置加上位置偏移量
	PlayerManager.set_player_position(global_position + LevelManager.position_offset)
	
	player_entered.emit()




# 获取位置偏移量
func get_offset() -> Vector2:
	
	var offset: Vector2 = Vector2.ZERO
	
	var player_pos = PlayerManager.player.global_position
	
	
	# 根据区域方向来调整玩家偏移位置
	match side:
		SIDE.Left, SIDE.Right:
			
			if center_player:
				offset.y = 0
			else:
				offset.y = player_pos.y - global_position.y
			
			offset.x = 32
			if side == SIDE.Left:
				offset.x *= -1
		
		
		
		
		SIDE.Top, SIDE.Bottom:
			
			if center_player:
				offset.x = 0
			else:
				offset.x = player_pos.x - global_position.x
			
			offset.y = 32
			if side == SIDE.Top:
				offset.y *= -1
	
	
	return offset





# 更新转换区域
func update_area():
	
	var new_rect: Vector2 = Vector2(32, 32)
	var new_pos: Vector2 = Vector2.ZERO
	
	
	# 根据方向调整矩形与位置
	match side:
		
		SIDE.Top:
			new_rect.x *= size
			new_pos.y -= 16
		
		SIDE.Bottom:
			new_rect.x *= size
			new_pos.y += 16
		
		SIDE.Left:
			new_rect.y *= size
			new_pos.x -= 16
		
		SIDE.Right:
			new_rect.y *= size
			new_pos.x += 16
	
	
	# 如果碰撞形状为空，就获取一个碰撞形状
	if collision_shape == null:
		collision_shape = get_node("CollisionShape2D")
	
	
	# 设置碰撞形状大小
	collision_shape.shape.size = new_rect
	# 设置碰撞形状位置
	collision_shape.position = new_pos
	
	




# 对齐网格
func _snap_to_grid():
	position.x = round(position.x / 16) * 16
	position.y = round(position.y / 16) * 16
