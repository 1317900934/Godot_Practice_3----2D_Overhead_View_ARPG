class_name Player_Camera
extends Camera2D


# 镜头摇晃强度
@export_range(0, 1, 0.05, "or_greater") var shake_power: float = 0.5
# 镜头摇晃最大偏移量
@export var shake_max_offset: float = 5.0
# 镜头摇晃衰减强度
@export var shake_decay: float = 1.0

# 镜头摇晃时间
var shake_trauma: float = 0.0




func _ready() -> void:
	# 连接全局脚本的瓦片地图范围改变的信号，自动更新相机范围限制
	LevelManager.tilemap_bound_change.connect(update_limits)
	
	# 获取并更新当前瓦片地图范围
	update_limits(LevelManager.current_tilemap_bounds)
	
	# 连接镜头摇晃函数
	PlayerManager.camera_shook.connect(add_camera_shake)





func _physics_process(delta: float) -> void:
	
	# 如果有镜头摇晃时间，就逐渐衰减并摇晃镜头
	if shake_trauma > 0:
		# 设置最高值
		shake_trauma = max(shake_trauma - shake_decay * delta, 0)
		shake()






# 摇晃镜头
func shake():
	
	# 获取摇晃次数:(摇晃时间 * 摇晃强度)的2次方
	var amount: float = pow(shake_trauma * shake_power, 2)
	# 根据镜头摇晃最大偏移量给予一个随机偏移
	offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake_max_offset * amount







# 增加镜头摇晃时间
func add_camera_shake(v: float):
	shake_trauma = v







# 根据向量数组的值来更新相机范围限制
func update_limits(bounds: Array[Vector2]):
	
	# 如果数组为空，则直接返回，防止错误
	if bounds == []:
		return
	
	limit_left = int(bounds[0].x)
	limit_top = int(bounds[0].y)
	limit_right = int(bounds[1].x)
	limit_bottom = int(bounds[1].y)
