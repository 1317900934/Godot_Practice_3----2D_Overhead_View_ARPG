extends Area2D

class_name Hurt_Box


# 受伤信号
signal hurt(hit_box: Hit_Box)




# 受伤函数
func take_damage(hit_box: Hit_Box):
	
	# 发射受伤信号，携带打击框
	hurt.emit(hit_box)
