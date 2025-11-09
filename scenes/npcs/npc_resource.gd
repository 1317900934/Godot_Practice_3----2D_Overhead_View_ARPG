class_name NPC_Resource
extends Resource


# NPC名称
@export var npc_name: String = "未知"
# NPC精灵纹理
@export var sprite: Texture
# NPC肖像图
@export var portrait: Texture
# NPC对话音频音调
@export_range(0.4, 1.8, 0.02) var dialog_audio_pitch: float = 1.0
