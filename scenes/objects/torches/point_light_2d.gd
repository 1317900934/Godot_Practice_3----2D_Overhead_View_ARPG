extends PointLight2D








func _ready() -> void:
	flicker()




# 持续改变光源属性，实现闪烁效果
func flicker():
	energy = randf() * 0.04 + 0.4
	
	scale = Vector2.ONE * (energy + 0.58)
	
	offset.x = energy + 0.58
	
	await get_tree().create_timer(0.1).timeout
	
	flicker()
