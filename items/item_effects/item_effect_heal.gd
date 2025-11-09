class_name Item_Effect_Heal
extends Item_Effect


@export var heal_amount: int = 1

@export var audio: AudioStream


# 使用效果
func use():
	PlayerManager.player.update_hp(heal_amount)
	PauseMenu.audio_play(audio)
