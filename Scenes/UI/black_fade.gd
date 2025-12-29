extends ColorRect

@onready var inventory = get_parent().get_node("Inventory")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	modulate.a = 0.0
	inventory.hidden_changed.connect(_on_inventory_hidden_changed)

func _on_inventory_hidden_changed(is_hidden: bool) -> void:
	var target_alpha = 0.0 if is_hidden else 0.5
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", target_alpha, 0.4)
