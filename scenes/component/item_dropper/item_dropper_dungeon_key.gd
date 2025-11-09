@tool
extends Item_Dropper





# 生成掉落物品
func drop_item():
	
	
	if has_dropped == true:
		return
	
	# 生成玩家提示消息
	PlayerManager.player.set_tips_text("哇！下面掉落了一把钥匙！")
	PlayerManager.player.show_tips_anim()
	super()
	await get_tree().create_timer(5.0).timeout
	PlayerManager.player.hide_tips_anim()
	
	
