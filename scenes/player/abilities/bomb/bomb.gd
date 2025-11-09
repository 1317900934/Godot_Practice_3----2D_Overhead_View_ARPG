class_name Throwable_Bomb
extends Throwable


@export_category("炸弹设置")
# 引信结束时间
@export_range(1.0, 10.0, 0.1, "s") var fuse_duration: float = 4.0



@export_category("弹跳效果")
# 弹跳力度
@export_range(0.1, 0.9, 0.05) var bounciness: float = 0.5
# 最大弹跳次数
@export_range(1, 10, 1) var max_bounces: int = 5


# 弹跳计数
var bounce_count: int = 0
# 起始扔出速度
var og_throw_speed: float = 0


@onready var expolosion_sprite: Sprite2D = $"../Expolosion"



func _ready() -> void:
	super()
	og_throw_speed = throw_speed
	hit_box.damage = 1
	anim_player.queue("explosion")
	anim_player.animation_changed.connect(_on_anim_changed)
	# 设置动画时间缩放
	anim_player.speed_scale = anim_player.current_animation_length / fuse_duration





func _physics_process(delta: float) -> void:
	super(delta)
	expolosion_sprite.position = object_sprite.position






func _on_anim_changed(_old_name: String, _new_name: String):
	anim_player.speed_scale = 1.0





func hit_ground():
	bounce_count += 1
	if bounce_count <= max_bounces:
		object_sprite.position.y = graound_height - 1
		vertical_velocity *= -1 * bounciness
		throw_speed *= bounciness
	else:
		set_physics_process(false)
		hit_box.set_deferred("monitoring", false)
		hit_box.did_damage.disconnect(did_damage)
		wall_detect.body_entered.disconnect(_on_body_entered)
		area_entered.connect(_on_area_enter)
		area_exited.connect(_on_area_exit)



# 碰到物体
func did_damage():
	var throw_magnitude: Vector2 = throw_direction.abs()
	if throw_magnitude.x > throw_magnitude.y:
		throw_direction *= Vector2(-1, 1)
	else:
		throw_direction *= Vector2(1, -1)
	
	throw_speed *= bounciness / 5




func disable_collisions(_node: Node):
	super(_node)
	$"../Hit_Box/CollisionShape2D".disabled = false





func drop():
	super()
	if anim_player.current_animation == "explosion":
		expolosion_sprite.position = object_sprite.position
		set_physics_process(false)






func player_interact():
	super()
	throw_speed = og_throw_speed
	bounce_count = 0




func explosion():
	set_physics_process(false)
	PlayerManager.shake_camera(1.5)
