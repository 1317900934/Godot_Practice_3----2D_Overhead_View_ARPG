class_name Damage_Text
extends Node2D


# 生成数值时的偏移距离
var travel_distance: Vector2 = Vector2(10, -20)




func start(_text: String, _pos: Vector2):
	$Label.text = _text
	global_position = _pos
	
	# 设置一个随机的生成位置
	travel_distance.y *= randf_range(0.5, 1.5)
	travel_distance.x *= randf_range(-1.5, 1.5)
	
	# 过渡时间
	var duration: float = randf_range(0.6, 1.0)
	
	# 声明补间动画并设置后续补间动画同时进行
	var tween: Tween = create_tween().set_parallel(true)
	# 设置缓动和过渡效果
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	# 设置位置和淡出动画
	tween.tween_property(self, "global_position", global_position + travel_distance, duration)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.2), duration).set_ease(Tween.EASE_IN)
	
	# 完成以上补间动画后销毁自己
	tween.chain().tween_callback(self.queue_free)
