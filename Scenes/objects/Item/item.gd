extends Node2D
class_name Item

@export var item_data : ItemData = null:
	set(value):
		item_data = value
		if is_node_ready():
			_update_sprite()

func _ready():
	_update_sprite()

func _update_sprite():
	var sprite = get_node_or_null("Sprite2D")
	if sprite != null and item_data != null and item_data.world_texture != null:
		sprite.texture = item_data.world_texture

func _on_collected():
	# TODO: Ajouter l'item à l'inventaire du joueur
	queue_free()
