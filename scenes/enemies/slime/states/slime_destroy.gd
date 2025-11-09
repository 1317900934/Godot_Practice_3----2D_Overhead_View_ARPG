extends Enemy_State

class_name Slime_Destroy

# 引用物品拾取场景
const PICKUP_ITEM = preload("uid://ba18nawb87xwb")


# 动画名称引用
@export var anim_name: String = "destroy"
# 击退速度
@export var knockback_speed: float = 200.0
# 减缓速度
@export var deceleracte_speed: float = 20.0
# 攻击框
@onready var hit_box: Hit_Box


@export_category("Item_Drops")
# 掉落物
@export var drops: Array[Drop_Data]


# 面向方向
var _direction: Vector2
# 受到伤害的位置
var _damage_position: Vector2



# 初始化
func init() -> void:
	
	# 将敌人脚本中的死亡信号与死亡函数连接
	enemy.enemy_destroyed.connect(_on_enemy_destroyed)
	
	


# 进入状态
func enter():
	
	# 启用无敌
	enemy.invulnerable = true
	# 获取攻击框，关闭它的检测
	hit_box = enemy.get_node_or_null("Hit_Box")
	if hit_box:
		hit_box.monitoring = false
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
	# 掉落物品
	drop_items()
	# 奖励玩家经验
	PlayerManager.reward_xp(enemy.xp_reward)




# 退出状态
func exit():
	pass



# 持续处理函数
func update(_delta: float) -> Enemy_State:
	
	# 将速度向量每秒减少减缓速度量，逐渐变为0
	enemy.velocity -= enemy.velocity * deceleracte_speed * _delta
	
	return null






# 物理持续处理函数
func physics_update(_delta: float) -> Enemy_State:
	return null






# 一旦获得死亡信号，就直接调用状态机，切换为当前的死亡状态
func _on_enemy_destroyed(_hit_box: Hit_Box):
	
	# 获取伤害位置
	_damage_position = _hit_box.global_position
	
	state_machine.change_state(self)






# 动画播放完毕后执行的函数(包含动画名称)
func _on_anim_finish(_anim: String):
	await get_tree().process_frame
	enemy.queue_free()





func drop_items():
	
	# 如果掉落物数组长度为0，表示没有掉落物，直接返回
	if drops.size() == 0:
		return
	
	# 遍历掉落物数组
	for i in drops.size():
		
		# 如果某索引位是空的或某索引位的物品数据是空的，就跳过，进行下一个循环
		if drops[i] == null or drops[i].item == null:
			continue
		
		# 获取掉落物数量
		var drop_count: int = drops[i].get_drop_count()
		# 遍历获取物品数量，实例化
		for c in drop_count:
			var drop: Item_Pickup = PICKUP_ITEM.instantiate() as Item_Pickup
			# 将掉落物数组中的每个数据分别赋值给实例化的物品
			drop.item_data = drops[i].item
			# 延迟调用函数，在父节点处添加物品节点
			enemy.get_parent().call_deferred("add_child", drop)
			# 将掉落物设置到敌人位置附近并随机分散
			drop.global_position = enemy.global_position
			# 设置掉落物移动向量,随机方向，随机范围
			drop.velocity = enemy.velocity.rotated(randf_range(-1.5, 1.5)) * randf_range(0.9, 1.5)
