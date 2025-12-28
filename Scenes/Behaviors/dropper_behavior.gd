extends Behavior
class_name DropperBehavior

@export var item_drop_array : Array = []

func drop_item():
	var rdm_value = randf_range(0.0, _compute_total_weight())
	var item_data = _find_item_by_weight(rdm_value)
	if item_data == null:
		return
	elif item_data is ItemData:
		EVENTS.emit_signal("spawn_item",  item_data, object.global_position)
	elif item_data is PackedScene:
		EVENTS.emit_signal("spawn_special_item",  item_data, object.global_position)

func _compute_total_weight() -> float:
	var total_weight : float = 0.0
	for item_drop_weight in item_drop_array:
		total_weight += item_drop_weight.weight
	return total_weight
	
func _find_item_by_weight(target_weight: float) -> ItemData:
	var cumulative_weight : float = 0.0
	for item_drop_weight in item_drop_array:
		cumulative_weight += item_drop_weight.weight
		if target_weight <= cumulative_weight:
			return item_drop_weight.item_data

	push_error("Weight not found in drop table: " + str(target_weight))
	return null 
