class_name Loceked_Door
extends Node2D



var is_open: bool = false


# 引用可以打开门的物品
@export var key_item: Item_Data


@export var locked_audio: AudioStream
@export var open_audio: AudioStream


@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var is_open_data: Persistent_Data_Handler = $Persistent_Data_Handler
@onready var interact_area: Area2D = $Interact_Area




func _ready() -> void:
	
	interact_area.area_entered.connect(_on_area_enter)
	interact_area.area_exited.connect(_on_area_exit)
	is_open_data.data_loaded.connect(set_state)
	# 根据持久数据更新门的状态
	set_state()





func _on_area_enter(_a: Area2D):
	PlayerManager.interact_pressed.connect(open_door)
	
	PlayerManager.player.set_tips_text("单击鼠标右键与门互动")
	PlayerManager.player.show_tips_anim()





func _on_area_exit(_a: Area2D):
	PlayerManager.interact_pressed.disconnect(open_door)
	PlayerManager.player.hide_tips_anim()




func open_door():
	if key_item == null:
		return
	
	# 使用钥匙物品，成功返回true，否则返回false
	var door_unlocked = PlayerManager.INVENTORY_DATA.use_item(key_item)
	
	if door_unlocked:
		anim_player.play("open_door")
		audio_player.stream = open_audio
		is_open_data.set_value()
	else:
		audio_player.stream = locked_audio
		PlayerManager.player.hide_tips_anim()
		await PlayerManager.player.tips_anim.animation_finished
		PlayerManager.player.set_tips_text("需要钥匙才能开门！")
		PlayerManager.player.show_tips_anim()
	
	
	audio_player.play()





func close_door():
	anim_player.play("close_door")




# 根据持久数据设置门的初始状态
func set_state():
	is_open = is_open_data.data_value
	
	if is_open:
		anim_player.play("opened")
	else:
		anim_player.play("closed")
