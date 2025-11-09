extends Node



# 音乐播放器数量
var BGM_player_count: int = 2
# 当前音乐播放器
var current_BGM_player: int = 0
# 播放器数组
var BGM_players: Array[AudioStreamPlayer] = []
# 音乐总线名
var BGM_bus: String = "BGM"
# 音乐淡入淡出效果持续时间
var BGM_fade_duration: float = 1.0






func _ready() -> void:
	
	# 确保不会在游戏暂停时停止播放
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# 遍历音乐播放器数量，添加子节点，设置总线并加入数组
	for i in BGM_player_count:
		var audio_player = AudioStreamPlayer.new()
		add_child(audio_player)
		audio_player.bus = BGM_bus
		BGM_players.append(audio_player)
		audio_player.volume_db = -60
	





func play_BGM(_audio: AudioStream):
	
	# 如果传入的音频为空，或与当前正在播放的音频相同，就返回
	if _audio == BGM_players[current_BGM_player].stream:
		return
	elif _audio == null:
		return
	
	
	current_BGM_player += 1
	
	if current_BGM_player >= 1 :
		current_BGM_player = 0
	
	
	
	# 抓取当前需要的播放器
	var target_player: AudioStreamPlayer = BGM_players[current_BGM_player]
	
	# 设置目标播放器的音频并淡入播放
	target_player.stream = _audio
	play_and_fade_in(target_player)
	
	
	
	# 抓取上一个播放器
	var old_player = BGM_players[1]
	if current_BGM_player == 1:
		old_player = BGM_players[0]
	
	
	# 淡出并停止上一个播放器
	fade_out_and_stop(old_player)





# 音频播放并淡入
func play_and_fade_in(audio_player: AudioStreamPlayer):
	
	audio_player.play(0)
	var tween: Tween = create_tween()
	tween.tween_property(audio_player, "volume_db", 0, BGM_fade_duration)






# 音频淡出并停止
func fade_out_and_stop(audio_player: AudioStreamPlayer):
	
	var tween: Tween = create_tween()
	tween.tween_property(audio_player, "volume_db", -60, BGM_fade_duration)
	
	await tween.finished
	audio_player.stop()




# 获取当前播放的音频
func get_current_track() -> AudioStream:
	return BGM_players[current_BGM_player].stream
