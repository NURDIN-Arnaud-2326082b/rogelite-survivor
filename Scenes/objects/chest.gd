extends StaticBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

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
		


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.get_animation() == "open":
		current_state = STATE.OPENEND
		collision_shape.disabled = true
		# cacher le pot 
		animated_sprite.hide()
