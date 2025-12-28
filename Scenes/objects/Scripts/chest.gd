extends StaticBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@export var coin_scene: PackedScene = preload("res://Scenes/objects/Scripts/coin.tscn")

enum STATE {
	IDLE,
	OPENING,
	OPENEND
}

var current_state: int = STATE.IDLE

func interact() -> void:
	if current_state != STATE.IDLE:
		return

	current_state = STATE.OPENING
	animated_sprite.play("open")
		
func _spawn_content() -> void:
	var coin_count: int = randi() % 5 + 1  # Génère entre 1 et 5 pièces
	for i in coin_count:
		var offset: Vector2 = Vector2(randf_range(-16, 16), randf_range(-16, 16))
		EVENTS.emit_signal("spawn_special_item", coin_scene, global_position + offset)

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.get_animation() == "open":
		current_state = STATE.OPENEND
		collision_shape.disabled = true
		_spawn_content()
		# cacher le pot 
		animated_sprite.hide()
