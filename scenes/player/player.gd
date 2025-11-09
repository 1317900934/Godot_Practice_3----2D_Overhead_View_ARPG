extends CharacterBody2D
class_name Player



signal player_hurt(hit_box: Hit_Box)
signal direction_changed(dir: Vector2)



# 玩家是否无敌
var invulnerable: bool = false

# 玩家生命值
var hp: int = 10

# 玩家最大生命值
var max_hp: int = 10

# 玩家等级
var level: int = 1

# 玩家经验值
var xp: int = 0

# 攻击力
var attack_power: int = 0: 
	set(v):
		attack_power = v
		update_damage_values()

# 防御力
var defense_power: int = 0
# 防御力加成
var defense_bonus: int = 0
# 移速加成
var move_speed_bonus: int = 0


# 角色朝向
var direction: Vector2 = Vector2.DOWN
# 移动方向
var move_direction: Vector2 

# 玩家能位于的所有朝向
const DIR_4 = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]

# 弓箭数量
var arrow_count: int = 5 :set = _set_arrow_count

# 炸弹数量
var bomb_count: int = 3 :set = _set_bomb_count


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Graphic/Sprite2D
@onready var state_machine: Player_State_Machine = $State_Machine
@onready var hit_box: Hit_Box = $Hit_Box
@onready var hurt_box: Hurt_Box = $Hurt_Box
@onready var attack_effect: Node2D = $Graphic/Attack_Effect
@onready var invulnerable_anim: AnimationPlayer = $Graphic/Invulnerable_Anim
@onready var tips: Node2D = $Tips
@onready var tips_anim: AnimationPlayer = $Tips/AnimationPlayer
@onready var audio_player: AudioStreamPlayer2D = $Audio/AudioStreamPlayer2D
@onready var lift: Player_Lift = $State_Machine/Lift
@onready var held_item: Node2D = $Graphic/Held_Item
@onready var graphic: Node2D = $Graphic
@onready var state_carry: Player_Carry = $State_Machine/Carry
@onready var level_up_anim: AnimationPlayer = $Level_up_Effect/Level_up_Anim
@onready var weapon_below: Sprite2D = $Graphic/Weapon_Below
@onready var weapon_above: Sprite2D = $Graphic/Weapon_Above
@onready var player_abilities: Player_Abilities = $Abilities




func _ready() -> void:
	
	
	
	# 将自己与玩家管理器的玩家变量绑定
	PlayerManager.player = self
	# 初始化状态机，并传入自己与其绑定
	state_machine.initialize(self)
	# 将受击框的受伤信号与受击函数连接
	hurt_box.hurt.connect(_take_hurt)
	# 更新生命值
	update_hp(99)
	# 更新玩家伤害
	update_damage_values()
	# 玩家升级时更新玩家伤害
	PlayerManager.player_leveled_up.connect(update_damage_values)
	# 连接玩家升级动画
	PlayerManager.player_leveled_up.connect(_on_level_up_anim)
	# 连接装备改变函数
	PlayerManager.INVENTORY_DATA.Equipment_Changed.connect(_on_equipment_changed)







func _process(_delta: float) -> void:
	# 实时获取移动向量
	move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")



func _physics_process(_delta: float) -> void:
	# 执行速度向量
	move_and_slide()








func  _set_arrow_count(value: int):
	arrow_count = value
	PlayerHud.update_arrow_count(arrow_count)





func _set_bomb_count(value: int):
	bomb_count = value
	PlayerHud.update_bomb_count(bomb_count)







# 设置角色朝向
func set_direction() -> bool:
	
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
	
	# 如果角色朝向为左，就翻转图像、攻击框和攻击特效，否则不翻转
	if direction == Vector2.LEFT:
		sprite.scale.x = -1 
		hit_box.scale.x = -1
		attack_effect.scale.x = -1
		graphic.scale.x = 1
		
		
	else:
		sprite.scale.x = 1 
		hit_box.scale.x = 1
		attack_effect.scale.x = 1
		graphic.scale.x = 1
	
	# 发射方向改变信号
	direction_changed.emit(direction)
	
	
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




# 受击函数
func _take_hurt(_hit_box: Hit_Box):
	
	# 如果处于无敌状态，就直接返回
	if invulnerable:
		return
	
	# 如果当前生命值大于0，就更新生命值并发射玩家受伤信号(由状态机的受伤状态接收)
	if hp > 0:
		
		var d: int = _hit_box.damage
		# 如果有伤害，就计算减去总防御力的伤害，并至少为1
		if d > 0:
			d = clampi(d - defense_power - defense_bonus, 1, 9999)
		
		update_hp(-d)
		player_hurt.emit(_hit_box)
	




# 更新生命值
func update_hp(value: int):
	
	# 将生命值加上变量，并钳制范围
	hp = clampi(hp + value, 0, max_hp)
	
	# 调用并更新全局脚本中的玩家生命值显示
	PlayerHud.update_hp(hp, max_hp)





# 进入无敌状态
func make_invulnerable(_duration: float):
	
	# 开启无敌并使受击框不能被检测
	invulnerable = true
	hurt_box.set_deferred("monitorable", false)
	
	# 创建临时计时器，等待无敌时间结束的信号
	await get_tree().create_timer(_duration).timeout
	
	# 关闭无敌并使受击框可以被检测
	invulnerable = false
	hurt_box.set_deferred("monitorable", true)
	
	pass



# 设置玩家提示文本
func set_tips_text(text: String):
	tips.tips_text.text = text


# 显示玩家提示
func show_tips_anim():
	tips_anim.play("appear")
	await tips_anim.animation_finished
	tips_anim.play("flash")


# 隐藏玩家提示
func hide_tips_anim():
	tips_anim.play("disappear")
	await tips_anim.animation_finished
	tips_anim.play("RESET")




# 举起物品
func lift_item(_t: Throwable):
	state_machine.change_state(lift)
	# 传入投掷物引用
	state_carry.throwable = _t





# 复活玩家
func revive_player():
	update_hp(99)
	state_machine.change_state($State_Machine/Idle)





# 更新玩家攻击伤害
func update_damage_values():
	# 获取并设置经过装备加成的最终攻击力
	var damage_value: int = attack_power + PlayerManager.INVENTORY_DATA.get_attack_bonus()
	$Hit_Box.damage = damage_value
	$Charge_Hit_Box.damage = damage_value + int(attack_power / 2.0)



# 播放升级动画并获得最大生命值一半的生命值
func _on_level_up_anim():
	level_up_anim.play("level_up")
	update_hp( int(max_hp / 2.0) )



# 装备改变后更新属性加成
func _on_equipment_changed():
	update_damage_values()
	defense_bonus = PlayerManager.INVENTORY_DATA.get_defense_bonus()
	move_speed_bonus = PlayerManager.INVENTORY_DATA.get_move_speed_bonus()
