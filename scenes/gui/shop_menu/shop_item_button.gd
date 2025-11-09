class_name Shop_Item_Button
extends Button


var item: Item_Data




func setup(_item: Item_Data):
	item = _item
	$Label.text = item.name
	$Price.text = str(item.price)
	$TextureRect.texture = item.texture
