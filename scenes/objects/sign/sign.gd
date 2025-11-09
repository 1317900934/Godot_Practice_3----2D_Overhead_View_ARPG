extends Node2D



@onready var interact: Area2D = $Interact


@export_multiline var text: String = ""



func _ready() -> void:
	interact.body_entered.connect(_on_body_entered)
	interact.body_exited.connect(_on_body_exited)




func _on_body_entered(_body: Node2D):
	if _body is Player:
		PlayerManager.player.set_tips_text("单击鼠标右键查看木牌")
		PlayerManager.player.show_tips_anim()
		PlayerManager.interact_pressed.connect(player_interact)






func _on_body_exited(_body: Node2D):
	if _body is Player:
		PlayerManager.player.hide_tips_anim()
		PlayerManager.interact_pressed.disconnect(player_interact)





func player_interact():
	SignHud.sign_show(text)
