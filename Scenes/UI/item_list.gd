extends ItemList
class_name inventory_item_list

func update_item_diplay(item_amount: ItemAmount) -> void:
	var item_id = _find_item_in_list(item_amount)
	var item_text = "%s x%d" % [item_amount.item_data.item_name, item_amount.amount]
	
	if item_id == -1:
		add_item(item_text, item_amount.item_data.icon_texture)
	else:
		set_item_text(item_id, item_text)

func _find_item_in_list(item_amount) -> int:
	for i in range(get_item_count()):
		var item_text = get_item_text(i)
		if item_text.begins_with(item_amount.item_data.item_name):
			return i
	return -1

func _on_inventory_data_manager_item_added(item_amount : ItemAmount) -> void:
	update_item_diplay(item_amount)

func _on_inventory_data_manager_item_removed(item_amount : ItemAmount) -> void:
	update_item_diplay(item_amount)
