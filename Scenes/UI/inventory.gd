extends Control
class_name Inventory

var item_list: Array = []

func _ready() -> void:
	EVENTS.connect("object_collected", Callable(self, "_on_EVENTS_object_collected"))

func _append_item(item_data: ItemData, amount: int = 1) -> void:
	var item_idx = _find_item_idx(item_data)
	if item_idx == -1:
		var new_item = ItemAmount.new(amount, item_data)
		item_list.append(new_item)
	else:
		item_list[item_idx].amount += amount

func _find_item_idx(item_data: ItemData) -> int:
	for i in range(item_list.size()):
		if item_list[i].item_data == item_data:
			return i
	return -1

func _remove_item(item_data: ItemData, amount: int = 1) -> void:
	var item_idx = _find_item_idx(item_data)
	if item_idx != -1:
		item_list[item_idx].amount -= amount
		if item_list[item_idx].amount <= 0:
			item_list.remove_at(item_idx)

func _print_inventory() -> void:
	for item_amount in item_list:
		print("Item: %s, Amount: %d" % [item_amount.item_data.item_name, item_amount.amount])

func _on_EVENTS_object_collected(item_data: ItemData) -> void:
	_append_item(item_data)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_inventory"):
		_print_inventory()

class ItemAmount:
	var item_data: ItemData = null
	var amount: int = 0

	func _init(_amount: int, _item_data: ItemData) -> void:
		item_data = _item_data
		amount = _amount
