@tool
class_name  Level_Transform_Interact
extends Level_Transform



func _ready() -> void:
	
	super()
	
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)




func _on_area_entered(_a: Area2D):
	PlayerManager.interact_pressed.connect(player_interact)
	PlayerManager.player.set_tips_text("单击鼠标右键进入")
	PlayerManager.player.show_tips_anim()



func _on_area_exited(_a: Area2D):
	PlayerManager.interact_pressed.disconnect(player_interact)
	PlayerManager.player.hide_tips_anim()





func player_interact():
	_player_entered(PlayerManager.player)
