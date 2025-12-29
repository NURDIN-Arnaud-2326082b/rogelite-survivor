extends Node
class_name InventoryDataManager

var item_list: Array = []

signal item_added(item_amount)
signal item_removed(item_amount)

func _ready() -> void:
	EVENTS.connect("object_collected", Callable(self, "_on_EVENTS_object_collected"))

func _append_item(item_data: ItemData, amount: int = 1) -> void:
	var item_idx = _find_item_idx(item_data)
	var new_item = null
	if item_idx == -1:
		new_item = ItemAmount.new(amount, item_data)
		item_list.append(new_item)
	else:
		new_item = item_list[item_idx]
		item_list[item_idx].amount += amount
	item_added.emit(new_item)

func _find_item_idx(item_data: ItemData) -> int:
	for i in range(item_list.size()):
		if item_list[i].item_data == item_data:
			return i
	return -1

func _remove_item(item_data: ItemData, amount: int = 1) -> void:
	var item_idx = _find_item_idx(item_data)
	var item_to_remove = item_list[item_idx] if item_idx != -1 else null
	if item_to_remove != null:
		item_removed.emit(item_to_remove)
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
