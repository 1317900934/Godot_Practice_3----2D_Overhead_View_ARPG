class_name Area_Trigger
extends Area2D



signal player_entered



var dialog: Dialog_Interact
var triggered: bool = false





func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	for c in get_children():
		if c is Dialog_Interact:
			dialog = c
			break





func _on_body_entered(_body: Node2D):
	
	#if triggered == true: return
	
	player_entered.emit()
	
	if dialog:
		triggered = true
		dialog.player_interact()
