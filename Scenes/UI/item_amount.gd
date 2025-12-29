extends Object
class_name ItemAmount

var item_data: ItemData = null
var amount: int = 0

func _init(_amount: int, _item_data: ItemData) -> void:
	item_data = _item_data
	amount = _amount