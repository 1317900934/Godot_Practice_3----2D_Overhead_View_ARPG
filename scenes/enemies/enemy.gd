class_name Enemy
extends CharacterBody2D


# 方向改变信号
signal direction_changed(new_dir: Vector2)
# 受伤信号
signal enemy_hurt(hit_box: Hit_Box)
# 死亡信号
signal enemy_destroyed(hit_box: Hit_Box)


# 方向范围
const DIR_4 = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]


@export var hp: int = 5

# 击败后的经验值奖励
@export var xp_reward: int = 1


# 角色朝向
var direction: Vector2 = Vector2.DOWN
# 移动方向
var move_direction: Vector2 
# 玩家引用
var player: Player
# 是否无敌
var invulnerable: bool = false


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var hurt_box: Hurt_Box = $Hurt_Box
@onready var state_machine: Node = $State_Machine






func _ready() -> void:
	# 初始化状态机，并传入自己与其绑定
	state_machine.initialize(self)
	# 获取玩家
	player = PlayerManager.player
	
	# 将受击框的受伤信号连接受伤函数
	hurt_box.hurt.connect(_take_hurt)



func _physics_process(_delta: float) -> void:
	move_and_slide()



func set_direction(_new_direction: Vector2) -> bool:
	
	# 将传递进来的方向向量赋值给移动方向
	move_direction = _new_direction
	
	# 如果移动方向为0，就不需要设置新方向，返回false
	if move_direction ==  Vector2.ZERO:
		return false
	
	
	# 获取方向参数值，这将作为方向数组中的索引位置
	# 获取朝向向量并转为弧度，然后除以圆常量得到0到1的数值，接着乘以数组长度，最后将得到的值使用round函数四舍五入得到索引位置
	var direction_id: int = int( round( ( move_direction + direction * 0.1).angle() / TAU * DIR_4.size() ) )
	
	# 声明新方向，获取方向数组中方向参数索引位的方向
	var new_dir = DIR_4[ direction_id ]
	
	# 如果新方向与移动方向相同，就不需要设置新方向，返回false
	if new_dir == direction:
		return false
	
	# 将新方向设置为角色朝向
	direction = new_dir
	
	# 发射方向改变的信号，携带新方向向量
	direction_changed.emit(new_dir)
	
	# 如果角色朝向为左，就翻转图像，否则不翻转
	if direction == Vector2.LEFT:
		sprite.scale.x = -1 
	else:
		sprite.scale.x = 1 
	
	
	# 返回true，表示需要设置新方向
	return true




# 更新动画
func update_animation(state: String):
	
	# 根据角色朝向播放对应的动画
	animation_player.play(state + "_" + anim_direction())



# 获取动画方向
func anim_direction() -> String:
	if direction == Vector2.DOWN:
		return "down"
	elif direction == Vector2.UP:
		return "up"
	else:
		return "side"




# 受伤函数
func _take_hurt(hit_box: Hit_Box):
	
	# 如果当前是无敌状态，就直接返回
	if invulnerable:
		return
	
	# 减少生命值
	hp -= hit_box.damage
	# 摇晃镜头
	PlayerManager.shake_camera(0.8)
	
	# 传入伤害值和位置，使伤害数字显示
	EffectManager.damage_text(hit_box.damage, global_position + Vector2(0, -36))
	
	# 如果生命值大于0，发射受伤信号，否则发射死亡信号(发射信号携带打击框)
	if hp > 0:
		enemy_hurt.emit(hit_box)
	else:
		enemy_destroyed.emit(hit_box)
	
