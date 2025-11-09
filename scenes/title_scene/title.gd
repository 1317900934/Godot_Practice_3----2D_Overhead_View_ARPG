extends CanvasLayer


@export var music: AudioStream
@export var focus_audio: AudioStream
@export var press_audio: AudioStream


@onready var button_new: Button = $Control/Button_New
@onready var button_continue: Button = $Control/Button_Continue
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer



const START_LEVEL: String = "res://scenes/levels/area_01/section_01.tscn"






func _ready() -> void:
	# 暂停游戏并隐藏玩家
	get_tree().paused = true
	PlayerManager.player.visible = false
	
	# 关闭玩家hud和暂停菜单
	PlayerHud.visible = false
	PauseMenu.process_mode = Node.PROCESS_MODE_DISABLED
	
	# 如果没有存档文件，就禁用继续按钮
	if SaveManager.get_save_file() == null:
		button_continue.disabled = true
	
	# 初始化开始屏幕
	setup_title_screen()
	
	# 一开始关卡加载，就调用离开标题屏幕函数
	LevelManager.level_load_started.connect(exit_title_screen)
	




# 初始化开始屏幕
func setup_title_screen():
	
	#play_audio(music)
	AudioManager.play_BGM(music)
	
	button_new.pressed.connect(start_game)
	button_new.grab_focus()
	button_continue.pressed.connect(load_game)
	
	button_new.focus_entered.connect(play_audio.bind(focus_audio))
	button_continue.focus_entered.connect(play_audio.bind(focus_audio))





# 开始新游戏
func start_game():
	play_audio(press_audio)
	PlayerManager.set_player_pos_to_spawn.emit()
	LevelManager.load_new_level(START_LEVEL, "", Vector2.ZERO)




# 加载存档
func load_game():
	play_audio(press_audio)
	SaveManager.load_game()







# 离开标题屏幕
func exit_title_screen():
	# 显示玩家
	PlayerManager.player.visible = true
	
	# 显示玩家hud和暂停菜单
	PlayerHud.visible = true
	PauseMenu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# 删除自己
	self.queue_free()



# 播放音频
func play_audio(_audio: AudioStream):
	audio_player.stream = _audio
	audio_player.play()
