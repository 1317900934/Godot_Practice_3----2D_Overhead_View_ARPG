extends Enemy_State

class_name Goblin_Chase


# 寻路系统
const PATH_FINDER: PackedScene = preload("res://scenes/enemies/path_finder.tscn")


# 动画名称引用
@export var anim_name: String = "chase"
# 追逐速度
@export var chase_speed: float = 50.0

# 为后续导出属性设置为AI类别
@export_category("AI")
# 状态的追踪时间
@export var state_aggro_duration: float = 0.5
# 下一个状态
@export var next_state: Enemy_State
# 视野区域引用
@export var vision_area: Vision_Area
# 攻击区域引用
@export var attack_box: Hit_Box
# 追逐玩家时的转向速率
@export var turn_rate: float = 0.25



var path_finder: Path_Finder


var _timer: float

var _direction: Vector2


# 是否看到玩家
var _see_player: bool = false





# 初始化
func init() -> void:
	
	if vision_area:
		vision_area.player_entered.connect(_on_player_enter)
		vision_area.player_exited.connect(_on_player_exit)
		print("警戒区域已连接")




# 进入状态
func enter():
	
	path_finder = PATH_FINDER.instantiate() as Path_Finder
	
	enemy.add_child(path_finder)
	
	_timer = state_aggro_duration
	
		# 更新动画
	enemy.update_animation(anim_name)
	
	
	
	




# 退出状态
func exit():
	
	path_finder.queue_free()
	
	# 如果有攻击区域，就关闭
	if attack_box:
		attack_box.monitoring = false
	
	# 声明未看到玩家
	_see_player = false
	
	




# 持续处理函数
func update(_delta: float) -> Enemy_State:
	
	# 如果玩家死亡，就直接进入下一个状态
	if PlayerManager.player.hp <= 0:
		return next_state
	
	
	# 线性插值使当前方向逐渐转变为寻路方向
	_direction = lerp(_direction, path_finder.move_dir, turn_rate)
	
	# 设置速度向量
	enemy.velocity = _direction * chase_speed
	# 如果敌人设置了随机方向,就更新动画，确保动画方向与方向一致
	if enemy.set_direction(_direction):
		enemy.update_animation(anim_name)
	
	# 如果没有看到玩家，就逐渐减少计时器，归零时返回下一个状态，否则不断刷新计时器
	if not _see_player:
		_timer -= _delta
		if _timer <= 0:
			return next_state
	else:
		_timer = state_aggro_duration
	
	
	return null



# 物理持续处理函数
func physics_update(_delta: float) -> Enemy_State:
	return null





# 玩家进入警戒范围
func _on_player_enter():
	# 声明已看到玩家
	_see_player = true
	# 如果之前是被击晕状态或销毁状态，就直接返回
	if (
		state_machine.current_state is Goblin_Stun or
		state_machine.current_state is Goblin_Destroy
	):
		return
	# 切换状态为追逐状态
	state_machine.change_state(self)



# 玩家退出警戒范围
func _on_player_exit():
	# 声明未看到玩家
		_see_player = false
