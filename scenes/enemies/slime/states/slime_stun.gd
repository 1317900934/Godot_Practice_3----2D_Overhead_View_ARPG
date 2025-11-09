extends Enemy_State

class_name Slime_Stun

# 动画名称引用
@export var anim_name: String = "stun"
# 击退速度
@export var knockback_speed: float = 200.0
# 减缓速度
@export var deceleracte_speed: float = 20.0

# 为后续导出属性设置为AI类别
@export_category("AI")

# 下一个状态
@export var next_state: Enemy_State

# 受到伤害的位置
var _damage_position: Vector2
# 面向方向
var _direction: Vector2
# 动画是否播放完毕
var _animation_finish: bool = false


# 初始化
func init() -> void:
	
	# 将敌人脚本中的受伤信号与受伤函数连接
	enemy.enemy_hurt.connect(_on_enemy_hurt)
	
	


# 进入状态
func enter():
	
	# 启用无敌
	enemy.invulnerable = true
	# 标志动画未完成
	_animation_finish = false
	# 将面向方向设置为受伤位置的方向
	_direction = enemy.global_position.direction_to(_damage_position)
	# 设置方向
	enemy.set_direction(_direction)
	# 设置击退速度向量
	enemy.velocity = _direction * -knockback_speed
	# 更新动画
	enemy.update_animation(anim_name)
	# 将敌人脚本中动画播放器的播放完毕信号与动画播放完毕函数连接
	enemy.animation_player.animation_finished.connect(_on_anim_finish)





# 退出状态
func exit():
	
	# 关闭无敌
	enemy.invulnerable = false
	
	# 将敌人脚本中动画播放器的播放完毕信号与动画播放完毕函数断开连接
	enemy.animation_player.animation_finished.disconnect(_on_anim_finish)




# 持续处理函数
func update(_delta: float) -> Enemy_State:
	
	
	# 如果动画播放完毕，返回下一个状态
	if _animation_finish:
		return next_state
	
	# 将速度向量每秒减少减缓速度量，逐渐变为0
	enemy.velocity -= enemy.velocity * deceleracte_speed * _delta
	
	return null






# 物理持续处理函数
func physics_update(_delta: float) -> Enemy_State:
	return null






# 一旦获得受伤信号，就直接调用状态机，切换为当前的受伤状态
func _on_enemy_hurt(hit_box: Hit_Box):
	
	# 获取伤害位置
	_damage_position = hit_box.global_position
	
	state_machine.change_state(self)






# 动画播放完毕后执行的函数(包含动画名称)
func _on_anim_finish(_anim: String):
	_animation_finish = true
