extends State

class_name Player_Dash


# 空闲状态引用
@export var state_idle: State
# 冲刺速度
@export var dash_speed: float = 300
# 冲刺特效延留时间
@export var effect_delay: float = 0.03
# 冲刺音效
@export var dash_audio: AudioStream

# 冲刺方向
var direction: Vector2 = Vector2.ZERO


var next_state: State = null

var effect_timer: float = 0





# 进入状态
func enter():
	
	character.invulnerable = true
	
	character.update_animation("dash")
	
	character.animation_player.animation_finished.connect(_on_animation_finished)
	
	direction = character.move_direction
	if direction == Vector2.ZERO:
		direction = character.direction
	
	if dash_audio:
		character.audio_player.stream = dash_audio
		character.audio_player.play()
	
	effect_timer = 0
	
	character.modulate = Color(0.5, 0.5, 0.5, 0.5)






# 退出状态
func exit():
	character.modulate = Color(1.0, 1.0, 1.0, 1.0)
	character.invulnerable = false
	next_state = null
	character.animation_player.animation_finished.disconnect(_on_animation_finished)





# 持续处理函数
func update(_delta: float) -> State:
	
	character.velocity = dash_speed * direction
	
	effect_timer -= _delta
	
	if effect_timer < 0:
		effect_timer = effect_delay
		spawn_effect()
	
	return next_state





# 物理持续处理函数
func physics_update(_delta: float) -> State:
	return null




func spawn_effect():
	var effect: Node2D = Node2D.new()
	
	character.get_parent().add_child(effect)
	
	effect.global_position = character.global_position
	
	var sprite_copy: Node2D = character.graphic.duplicate()
	
	sprite_copy.script = null
	sprite_copy.modulate = Color(0.682, 0.821, 1.0, 0.502)
	effect.add_child(sprite_copy)
	
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(effect, "modulate", Color(0.6, 0.7, 1.0, 0), 0.2)
	tween.chain().tween_callback(effect.queue_free)







func _on_animation_finished(_anim_name: String):
	next_state = state_idle
