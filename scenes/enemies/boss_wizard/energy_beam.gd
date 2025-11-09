class_name Energy_Beam
extends Node2D


@export var use_timer: bool = false
@export var time_between_attacks: float = 3.0



@onready var anim_player: AnimationPlayer = $AnimationPlayer





func _ready() -> void:
	if use_timer == true:
		attack_delay()






func attack():
	anim_player.play("attack")
	await anim_player.animation_finished
	anim_player.play("default")
	if use_timer == true:
		attack_delay()



# 等待一定延迟后再次攻击
func attack_delay():
	await get_tree().create_timer(time_between_attacks).timeout
	attack()
