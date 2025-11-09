extends Area2D

class_name Hit_Box


signal did_damage


# 伤害数值
@export var damage: int = 1



func _ready() -> void:
	
	# 将区域进入信号连接自定义函数
	area_entered.connect(_area_entered)
	




# 有区域进入时执行
func _area_entered(area):
	
	# 当进入的区域是受击框时，给其中的造成伤害函数传入自己，并发射造成伤害信号
	if area is Hurt_Box:
		area.take_damage(self)
		did_damage.emit()
