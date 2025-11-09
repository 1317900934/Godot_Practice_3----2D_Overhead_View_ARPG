extends State

class_name Player_Lift

# 举起音效
@export var lift_audio: AudioStream
# 举着时的状态引用
@onready var carry: State = $"../Carry"



# 是否要从动画的后半部分开始播放
var start_anim_late: bool = false





# 进入状态
func enter():
	# 播放举起动画和音效，并调用状态完毕函数
	character.update_animation("lift")
	if start_anim_late == true:
		character.animation_player.seek(0.2)
	character.animation_player.animation_finished.connect(state_complete)
	character.audio_player.stream = lift_audio
	character.audio_player.play()



# 退出状态
func exit():
	start_anim_late = false




# 持续处理函数
func update(_delta: float) -> State:
	
	character.velocity = Vector2.ZERO
	return null



# 物理持续处理函数
func physics_update(_delta: float) -> State:
	return null




# 处理输入事件
func handle_input(_event: InputEvent) -> State:
	return null




func state_complete(_a: String):
	character.animation_player.animation_finished.disconnect(state_complete)
	state_machine.change_state(carry)
