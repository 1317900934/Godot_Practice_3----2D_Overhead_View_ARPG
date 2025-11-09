extends State

class_name Player_Stun



# 击退速度
@export var knockback_speed: float = 200.0
# 减缓速度
@export var deceleracte_speed: float = 20.0
# 无敌时间长度
@export var invulnerable_duration: float = 0.8

# 空闲状态引用
@export var state_idle: Player_Idle
# 死亡状态引用
@export var state_death: Player_Death


# 定义下一个状态
var next_state: State = null
# 打击框
var hit_box: Hit_Box
# 面向方向
var direction: Vector2





# 初始化状态
func init():
	# 将玩家的受伤函数连接到当前状态的受伤函数
	character.player_hurt.connect(_player_hurt)



# 进入状态
func enter():
	
	# 将玩家动画播放器的动画播放完毕信号连接到当前脚本的播放完毕函数
	character.animation_player.animation_finished.connect(_anim_finish)
	# 将面向方向设置为朝向打击框的方向
	direction = character.global_position.direction_to(hit_box.global_position)
	# 给予玩家一个受击击退
	character.velocity = direction * -knockback_speed
	# 更新玩家方向
	character.set_direction()
	# 更新玩家的动画
	character.update_animation("stun")
	# 调用玩家的进入无敌时间函数，并传入无敌时间长度
	character.make_invulnerable(invulnerable_duration)
	# 调用玩家的无敌时间动画播放器，播放无敌时间动画
	character.invulnerable_anim.play("flash")
	# 根据伤害大小来施加不同强度摇晃镜头
	PlayerManager.shake_camera(hit_box.damage * 0.3)






# 退出状态
func exit():
	# 将下一个状态设置为空
	next_state = null
	
	# 将玩家动画播放器的动画播放完毕信号与当前脚本的动画播放完毕函数断开连接
	character.animation_player.animation_finished.disconnect(_anim_finish)




# 持续处理函数
func update(delta: float) -> State:
	# 将玩家受击状态时的速度向量根据时间减少
	character.velocity -= character.velocity * delta
	
	return next_state




# 物理持续处理函数
func physics_update(_delta: float) -> State:
	return null




func _player_hurt(_hit_box: Hit_Box):
	
	# 获取传进来的打击框
	hit_box = _hit_box
	
	# 如果当前不是死亡状态，就调用状态机，切换状态为自身
	if state_machine.current_state != state_death:
		state_machine.change_state(self)
	




# 动画播放完毕函数
func _anim_finish(_anim: String):
	
	
	# 将下一个状态设置为idle
	next_state = state_idle
	
	# 如果玩家生命值小于等于0，就将下一个状态设置为death
	if character.hp <= 0:
		next_state = state_death
