extends State
class_name Player_Bow



const ARROW = preload("uid://clxjw2xdwvyoj")


# 空闲状态引用
@export var state_idle: State

# 射箭方向
var direction: Vector2 = Vector2.ZERO

var next_state: State = null






# 进入状态
func enter():
	
	character.update_animation("bow")
	character.animation_player.animation_finished.connect(_on_animation_finished)
	
	direction = character.direction
	
	var arrow: Arrow = ARROW.instantiate()
	character.add_sibling(arrow)
	arrow.global_position = character.global_position + (direction * 32)
	arrow.fire(direction)





# 退出状态
func exit():
	
	character.animation_player.animation_finished.disconnect(_on_animation_finished)
	next_state = null
	





# 持续处理函数
func update(_delta: float) -> State:
	
	character.velocity = Vector2.ZERO
	return next_state





# 物理持续处理函数
func physics_update(_delta: float) -> State:
	return null







func _on_animation_finished(_anim_name: String):
	next_state = state_idle
