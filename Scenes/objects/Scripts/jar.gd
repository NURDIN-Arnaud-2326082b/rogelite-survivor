extends StaticBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var dropper_behavior: DropperBehavior = $DropperBehavior

enum STATE {
	IDLE,
	BREAKING,
	BROKEN
}

var current_state: int = STATE.IDLE

func destroy() -> void:
	if current_state != STATE.IDLE:
		return

	current_state = STATE.BREAKING
	animated_sprite.play("break")
		


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.get_animation() == "break":
		current_state = STATE.BROKEN
		collision_shape.disabled = true
		# cacher le pot 
		animated_sprite.hide()
		# drop item
		if dropper_behavior:
			dropper_behavior.drop_item()
