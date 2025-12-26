extends Node2D

var coin_scene := preload("res://Scenes/objects/Scripts/coin.tscn")

func _ready() -> void:
	EVENTS.connect("spawn_coin", Callable(self, "_on_EVENTS_spawn_coin"))

func _spawn_coin(pos: Vector2) -> void:
	var coin_instance = coin_scene.instantiate()
	coin_instance.set_position(pos)
	owner.add_child(coin_instance)

func _on_EVENTS_spawn_coin(pos: Vector2) -> void:
	_spawn_coin(pos)
