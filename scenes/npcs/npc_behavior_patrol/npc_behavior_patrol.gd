@tool
extends NPC_Behavior


const COLORS = [Color.ORANGE_RED, Color.ORANGE, Color.ROYAL_BLUE, 
Color.YELLOW, Color.LIME_GREEN, Color.AQUA, Color.MEDIUM_PURPLE]




# 巡逻移动速度
@export var walk_speed: float = 30.0


# 巡逻路线点
var patrol_locations: Array[Patrol_Location]
# 当前位置索引
var current_loaction_index: int = 0
# 下一个目标点
var target: Patrol_Location


# 是否开始行动
var has_started: bool = false
# 上一个阶段
var last_phase: String = ""
# npc朝向
var direction: Vector2

@onready var timer: Timer = $Timer



func _ready() -> void:
	
	gather_patrol_location()
	
	if Engine.is_editor_hint():
		child_entered_tree.connect(gather_patrol_location)
		child_order_changed.connect(gather_patrol_location)
		return
	
	super()
	
	if patrol_locations.size() == 0:
		process_mode = Node.PROCESS_MODE_DISABLED
		return
	
	target = patrol_locations[0]








func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	# 当npc接近巡逻点后，进入空闲阶段，准备下一步行动
	if npc.global_position.distance_to(target.target_pos) < 1:
		idle_phase()







# 更新巡逻线路点数组
func gather_patrol_location(_n: Node = null):
	
	patrol_locations = []
	
	for c in get_children():
		if c is Patrol_Location:
			patrol_locations.append(c)
	
	if Engine.is_editor_hint():
		if patrol_locations.size() > 0:
			for i in patrol_locations.size():
				
				var _p =  patrol_locations[i] as Patrol_Location
				
				if not _p.transform_changed.is_connected(gather_patrol_location) :
					_p.transform_changed.connect(gather_patrol_location)
				
				_p.update_label(str(i))
				_p.modulate = get_color_by_index(i)
				
				var _next: Patrol_Location
				if i < patrol_locations.size() - 1:
					_next = patrol_locations[i + 1]
				else:
					_next = patrol_locations[0]
				
				_p.update_line(_next.position)







# npc开始行动
func start():
	
	if npc.do_behavior == false or patrol_locations.size() < 2:
		return
	
	# 如果不是第一次开始行动，就进入行走阶段并返回
	if has_started == true:
		if timer.time_left == 0:
			walk_phase()
		return
	
	has_started = true
	idle_phase()
	




# npc空闲阶段
func idle_phase():
	
	
	npc.global_position = target.target_pos
	npc.state = "idle"
	npc.velocity = Vector2.ZERO
	npc.update_anim()
	
	var wait_time: float = target.wait_time
	current_loaction_index += 1
	if current_loaction_index >= patrol_locations.size():
		current_loaction_index = 0
	target = patrol_locations[current_loaction_index]
	
	if wait_time > 0:
		timer.start(wait_time)
		await timer.timeout
	
	if npc.do_behavior == false:
		return
	
	walk_phase()
	





# npc行走阶段
func walk_phase():
	
	npc.state = "walk"
	direction = global_position.direction_to(target.target_pos)
	npc.direction = direction
	npc.velocity = direction * walk_speed
	npc.update_dir(target.target_pos)
	npc.update_anim()






# 获取一个颜色值
func get_color_by_index(i: int) -> Color:
	var color_count: int = COLORS.size()
	
	while i > color_count - 1:
		i -= color_count
	
	return COLORS[i]
