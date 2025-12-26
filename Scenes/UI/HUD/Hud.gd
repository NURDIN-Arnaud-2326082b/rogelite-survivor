extends TextureRect

@onready var coin_counter: Label = $CoinCounter

func _ready() -> void:
	EVENTS.connect("nb_coins_changed", Callable(self, "_on_EVENTS_nb_coins_changed"))

func _on_EVENTS_nb_coins_changed(new_count: int) -> void:
	coin_counter.text = str(new_count)
