extends Node

var nb_coins: int = 0

func _ready() -> void:
	EVENTS.connect("coin_collected", Callable(self, "_on_EVENTS_coin_collected"))

func get_coins() -> int:
	return nb_coins

func reset_coins() -> void:
	nb_coins = 0
	EVENTS.emit_signal("nb_coins_changed", nb_coins)

func set_nb_coins(count: int) -> void:
	if count != nb_coins:
		nb_coins = count
	EVENTS.emit_signal("nb_coins_changed", nb_coins)

func _on_EVENTS_coin_collected() -> void:
	print("Coin collected!")
	set_nb_coins(nb_coins + 1)
