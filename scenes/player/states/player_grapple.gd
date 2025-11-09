extends State

class_name Player_Grapple


@onready var idle: Player_Idle = $"../Idle"
@onready var grapple_hook: Node2D = %Grapple_Hook
@onready var nine_patch_rect: NinePatchRect = $"../../Grapple_Hook/NinePatchRect"
@onready var chain_audio_player: AudioStreamPlayer2D = $"../../Grapple_Hook/AudioStreamPlayer2D"
@onready var grapple_ray_cast: RayCast2D = %Grapple_RayCast
@onready var hit_box: Hit_Box = $"../../Grapple_Hook/NinePatchRect/Control/Hit_Box"


# 抓钩最大延伸长度
@export var grapple_distance: float = 200.0
# 抓钩延伸速度
@export var grapple_speed: float = 500.0

@export_group("抓钩音效")

@export var fire_audio: AudioStream
@export var stick_audio: AudioStream
@export var bounce_audio: AudioStream



# 碰撞距离
var collision_distance: float
# 碰撞类型；0 = 无碰撞,1 = 墙壁,2 = 抓钩点
var collision_type: int = 0
# 抓钩除延伸区域外的图像尺寸
var nine_patch_size: float = 25.0



var tween: Tween

var next_state: State = null



# 抓钩在各个方向的位置(z为旋转角度, x和y为坐标)
var positions: Array[Vector3] = [
	Vector3(0.0, -20.0, 180.0),# 上
	Vector3(0.0, -13.0, 0.0),# 下
	Vector3(-8.0, -15.0, 90.0),# 左
	Vector3(8.0, -15.0, -90.0),# 右
]
# 抓钩各个方向的映射值
var pos_map: Dictionary = {
	Vector2.UP: 0,
	Vector2.DOWN: 1,
	Vector2.LEFT: 2,
	Vector2.RIGHT: 3,
}






func init() -> void:
	grapple_hook.visible = false
	hit_box.monitoring = false
	grapple_ray_cast.enabled = false
	grapple_ray_cast.target_position.y = grapple_distance







# 进入状态
func enter():
	character.update_animation("idle")
	grapple_hook.visible = true
	hit_box.monitoring = true
	
	# 设置抓钩位置
	set_grapple_hook_pos()
	# 开始射线检测
	ray_cast_detection()
	# 发射抓钩
	shoot_grapple()
	
	# 播放声音效果
	chain_audio_player.play()
	play_audio(fire_audio)
	
	
	







# 退出状态
func exit():
	next_state = null
	grapple_hook.visible = false
	hit_box.monitoring = false
	chain_audio_player.stop()
	tween.kill()
	nine_patch_rect.size.y = nine_patch_size








# 持续处理函数
func update(_delta: float) -> State:
	character.velocity = Vector2.ZERO
	
	return next_state







# 根据玩家朝向设置对应的抓钩位置
func set_grapple_hook_pos():
	var new_pos: Vector3 = positions[
		pos_map[character.direction]
	]
	grapple_hook.position = Vector2(new_pos.x, new_pos.y)
	grapple_hook.rotation_degrees = new_pos.z
	
	if character.direction == Vector2.UP:
		grapple_hook.show_behind_parent = true
		grapple_hook.z_index = 0
	else:
		grapple_hook.show_behind_parent = false
		grapple_hook.z_index = 1
	





# 发射抓钩
func 	shoot_grapple():
	if tween: tween.kill()
	
	var tween_duration: float = collision_distance / grapple_speed
	tween = create_tween()
	tween.tween_property(
		nine_patch_rect, "size",
		Vector2(nine_patch_rect.size.x, collision_distance),
		tween_duration
	)
	
	# 如果碰撞到抓钩点，就拉走玩家，否则收回抓钩
	if collision_type == 2:
		tween.tween_callback(grapple_player)
	else:
		tween.tween_callback(return_grapple)







# 抓钩抓到抓钩点，拉走玩家
func grapple_player():
	if tween: tween.kill()
	
	play_audio(stick_audio)
	# 关闭玩家的墙壁碰撞检测
	character.set_collision_mask_value(4, false)
	
	if collision_type > 0:
		play_audio(bounce_audio)
	
	var tween_duration: float = collision_distance / grapple_speed
	tween = create_tween()
	# 收缩抓钩长度
	tween.tween_property(
		nine_patch_rect, "size",
		Vector2(nine_patch_rect.size.x, nine_patch_size),
		tween_duration
	)
	
	# 设定玩家需要被拉向的位置
	var player_target: Vector2 = character.global_position
	player_target += (character.direction * collision_distance)
	player_target -= character.direction * nine_patch_size
	
	# 将玩家拉向目标位置，与上一个收缩抓钩的补间动画同时执行
	tween.parallel().tween_property(
		character, "global_position", player_target, tween_duration
	)
	# 拉走过程中玩家无敌
	character.make_invulnerable(tween_duration)
	# 释放完毕
	tween.tween_callback(grapple_finish)
	





# 抓钩未抓到抓钩点，收回抓钩
func return_grapple():
	if tween: tween.kill()
	
	if collision_type > 0:
		play_audio(bounce_audio)
	
	var tween_duration: float = collision_distance / grapple_speed
	tween = create_tween()
	# 收缩抓钩长度
	tween.tween_property(
		nine_patch_rect, "size",
		Vector2(nine_patch_rect.size.x, nine_patch_size),
		tween_duration
	)
	# 释放完毕
	tween.tween_callback(grapple_finish)





# 抓钩释放完毕
func grapple_finish():
	character.set_collision_mask_value(4, true)
	next_state = idle








# 启动抓钩检测
func ray_cast_detection():
	collision_type = 0
	collision_distance = grapple_distance
	
	grapple_ray_cast.set_collision_mask_value(5, false)
	grapple_ray_cast.set_collision_mask_value(4, false)
	grapple_ray_cast.set_collision_mask_value(7, true)
	# 立即更新碰撞信息，避免物理帧延迟
	grapple_ray_cast.force_raycast_update()
	# 如果碰撞到抓钩点
	if grapple_ray_cast.is_colliding():
		collision_type = 2
		# 获取碰撞点到玩家的距离
		collision_distance = grapple_ray_cast.get_collision_point().distance_to(character.global_position)
		return
	
	
	grapple_ray_cast.set_collision_mask_value(5, true)
	grapple_ray_cast.set_collision_mask_value(4, true)
	grapple_ray_cast.set_collision_mask_value(7, false)
	# 立即更新碰撞信息，避免物理帧延迟
	grapple_ray_cast.force_raycast_update()
	# 如果碰撞到墙壁
	if grapple_ray_cast.is_colliding():
		collision_type = 1
		# 获取碰撞点到玩家的距离
		collision_distance = grapple_ray_cast.get_collision_point().distance_to(character.global_position)
		return






func play_audio(audio: AudioStream):
	character.audio_player.stream = audio
	character.audio_player.play()
