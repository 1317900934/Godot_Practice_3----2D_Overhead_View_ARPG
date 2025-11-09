extends CanvasLayer



@onready var animation_player: AnimationPlayer = $Control/AnimationPlayer


signal transform_finish



# 播放转场动画开始
func transform_start() -> bool:
	animation_player.play("transform_start")
	await animation_player.animation_finished
	
	return true



# 播放转场动画结束
func transform_end():
	animation_player.play("transform_end")
	await get_tree().create_timer(0.05).timeout
	transform_finish.emit()
