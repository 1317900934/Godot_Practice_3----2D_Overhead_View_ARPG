extends Node


const DAMAGE_TEXT = preload("uid://daove425ulbae")





func damage_text(_damage: int, _pos: Vector2):
	
	var _t: Damage_Text = DAMAGE_TEXT.instantiate()
	add_child(_t)
	_t.start(str(_damage), _pos)
