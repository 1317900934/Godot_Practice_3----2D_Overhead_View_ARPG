class_name Level
extends Node2D


# 背景音乐
@export var BGM: AudioStream



func _ready() -> void:
	# 确保开启y轴排序
	self.y_sort_enabled = true
	
	# 设置玩家为自己的子节点
	PlayerManager.set_as_parent(self)
	
	# 开始加载新关卡时，销毁自己
	LevelManager.level_load_started.connect(_free_level)
	
	# 调用音乐播放器，播放背景音乐
	AudioManager.play_BGM(BGM)
	
	# 隐藏玩家提示消息
	PlayerManager.player.hide_tips_anim()




# 销毁场景
func _free_level():
	
	# 移除本节点中的玩家节点
	PlayerManager.unparent_player(self)
	
	# 销毁本场景
	queue_free()
