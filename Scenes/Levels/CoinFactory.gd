extends Node2D
class_name ItemFactory

var coin_scene := preload("res://Scenes/objects/Scripts/coin.tscn")
var item_scene := preload("res://Scenes/objects/Item/item.tscn")

func _ready() -> void:
	EVENTS.connect("spawn_special_item", Callable(self, "_on_EVENTS_spawn_special_item"))
	EVENTS.connect("spawn_item", Callable(self, "_on_EVENTS_spawn_item"))

func _spawn_item(item_data: ItemData, pos: Vector2) -> void:
	var item_instance = item_scene.instantiate()
	owner.add_child(item_instance)
	item_instance.item_data = item_data
	item_instance.global_position = pos

func _spawn_special_item(item_scn: PackedScene, pos: Vector2) -> void:
	var special_item_instance = item_scn.instantiate()
	owner.add_child(special_item_instance)
	special_item_instance.global_position = pos

func _on_EVENTS_spawn_special_item(item_scn: PackedScene, pos: Vector2) -> void:
	_spawn_special_item(item_scn, pos)

func _on_EVENTS_spawn_item(item_data: ItemData, pos: Vector2) -> void:
	_spawn_item(item_data, pos)
