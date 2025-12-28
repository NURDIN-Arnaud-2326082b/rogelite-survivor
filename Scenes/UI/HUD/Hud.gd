extends TextureRect

@onready var coin_counter: Label = $CoinCounter
@onready var hp_bar: ProgressBar = $HP_Bar

func _ready() -> void:
	EVENTS.connect("nb_coins_changed", Callable(self, "_on_EVENTS_nb_coins_changed"))
	EVENTS.connect("character_hp_changed", Callable(self, "_on_EVENTS_character_hp_changed"))

func _on_EVENTS_nb_coins_changed(new_count: int) -> void:
	coin_counter.text = str(new_count)

func _on_EVENTS_character_hp_changed(new_hp: int) -> void:
	hp_bar.value = new_hp
