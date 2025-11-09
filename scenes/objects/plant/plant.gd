extends Node2D

class_name Plant

@onready var animation_player: AnimationPlayer = $AnimationPlayer




func _ready() -> void:
	# 将受击框的受伤信号连接受击函数
	$Hurt_Box.hurt.connect(take_damage)



# 受击后直接销毁节点
func take_damage(_hit_box: Hit_Box):
	animation_player.play("destroy")
	await animation_player.animation_finished
	queue_free()
