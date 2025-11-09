@tool

class_name Custscene_Action_Music
extends Custscene_Action


@export var track: AudioStream
@export var reset_after_cutscene: bool = true


var original_track: AudioStream





func _ready() -> void:
	pass







func play():
	
	if reset_after_cutscene:
		original_track = AudioManager.get_current_track()
		if not DialogSystem.finished.is_connected(_on_cutscene_finished):
			DialogSystem.finished.connect(_on_cutscene_finished)
	
	AudioManager.play_BGM(track)
	finished.emit()





func _on_cutscene_finished():
	AudioManager.play_BGM(original_track)
