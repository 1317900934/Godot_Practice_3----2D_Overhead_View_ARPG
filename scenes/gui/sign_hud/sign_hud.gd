extends CanvasLayer


@onready var label: Label = $Control/Label
@onready var button: Button = $Control/Button


var is_show: bool = false




func _ready() -> void:
	sign_hide()
	label.text = ""
	button.pressed.connect(sign_hide)







func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and is_show == true:
		get_viewport().set_input_as_handled()
		sign_hide()








func sign_show(text: String):
	get_tree().paused = true
	label.text = text
	visible = true
	PauseMenu.can_pause = false
	is_show = true
	button.grab_focus()





func sign_hide():
	get_tree().paused = false
	label.text = ""
	visible = false
	PauseMenu.can_pause = true
	is_show = false
