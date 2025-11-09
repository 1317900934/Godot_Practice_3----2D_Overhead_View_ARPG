class_name Quest
extends Resource


# 任务名称
@export var title: String
# 任务详情
@export_multiline var description: String

# 完成任务需要的步骤
@export var steps: Array[String]

# 经验奖励
@export var reward_xp: int = 0
# 物品奖励
@export var reward_items: Array[Quest_Reward_Item] = []
