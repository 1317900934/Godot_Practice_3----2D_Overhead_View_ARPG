extends State

class_name Player_Death


@export var dead_audio: AudioStream

@onready var audio_player: AudioStreamPlayer2D = $"../../Audio/AudioStreamPlayer2D"





# 初始化状态
func init():
	pass





# 进入状态
func enter():
	# 播放死亡动画和音效
	character.animation_player.play("death")
	audio_player.stream = dead_audio
	audio_player.play()
	
	PlayerHud.show_game_over_hud()
	







# 退出状态
func exit():
	pass



# 持续处理函数
func update(_delta: float) -> State:
	character.velocity = Vector2.ZERO
	
	return null
