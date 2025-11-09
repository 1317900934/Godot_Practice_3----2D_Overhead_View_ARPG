@icon("res://assets/npc_and_dialog/icons/cutscene_animation.svg")

class_name Custscene_Action_Animation
extends Custscene_Action




@export var anim_player: AnimationPlayer
@export var anim_name: String






func play():
	if anim_player and anim_name:
		anim_player.process_mode = Node.PROCESS_MODE_ALWAYS
		anim_player.play(anim_name)
		await  anim_player.animation_finished
	
	finished.emit()
