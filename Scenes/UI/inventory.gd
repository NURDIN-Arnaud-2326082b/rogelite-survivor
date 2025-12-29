extends Control
class_name Inventory

var inventory_hidden := true:
	set(value):
		if value != inventory_hidden:
			inventory_hidden = value
			hidden_changed.emit(inventory_hidden)
	get:
		return inventory_hidden

@onready var panel = $Panel
@onready var item_list = $Panel/VBoxContainer/ItemList
@onready var hidden_position = position
@onready var visible_position = hidden_position - panel.size * Vector2.RIGHT

signal hidden_changed(value: bool)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hidden_changed.connect(_on_hidden_changed)

func _input(_event: InputEvent) -> void:
	if _event.is_action_pressed("ui_inventory"):
		inventory_hidden = !inventory_hidden
	
	if not inventory_hidden and item_list.get_item_count() > 0:
		if _event.is_action_pressed("ui_down"):
			var current = item_list.get_selected_items()
			var next_index = current[0] + 1 if current.size() > 0 else 0
			if next_index >= item_list.get_item_count():
				next_index = 0
			item_list.select(next_index)
			item_list.ensure_current_is_visible()
		elif _event.is_action_pressed("ui_up"):
			var current = item_list.get_selected_items()
			var prev_index = current[0] - 1 if current.size() > 0 else 0
			if prev_index < 0:
				prev_index = item_list.get_item_count() - 1
			item_list.select(prev_index)
			item_list.ensure_current_is_visible()

func _on_hidden_changed(_value: bool) -> void:
	_animation(!inventory_hidden)
	if not inventory_hidden and item_list.get_item_count() > 0:
		item_list.select(0)
	get_tree().paused = not inventory_hidden

func _animation(shw: bool) -> void:
	var to = visible_position if shw else hidden_position
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", to, 0.4)
