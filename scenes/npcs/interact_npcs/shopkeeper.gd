class_name Shopkeeper
extends Node2D

@export var shop_inventory: Array[Item_Data]

@onready var dialog_branch_yes: Dialog_Branch = $NPC/Dialog_Interact/Dialog_Choice/Dialog_Branch



func _ready() -> void:
	dialog_branch_yes.selected.connect(show_shop_menu)




func show_shop_menu():
	ShopMenu.show_menu(shop_inventory)
