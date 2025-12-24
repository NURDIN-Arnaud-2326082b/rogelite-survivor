extends Node2D

@onready var area: Area2D = $Area2D
@onready var coin_sprite: AnimatedSprite2D = $CoinSprite
@onready var shadow_sprite: AnimatedSprite2D = $ShadowSprite
@onready var audio_coin : AudioStreamPlayer2D = $AudioStreamPlayer2D

enum state {
	IDLE,
	FOLLOWING,
	COLLECTED
}

var current_state: int = state.IDLE
var target : Node2D = null
var speed: float = 400.0

func _physics_process(delta: float) -> void:
	if current_state == state.FOLLOWING and target != null:
		_set_animation("Idle")
		var direction: Vector2 = (target.global_position - global_position).normalized()
		global_position += direction * speed * delta

		if global_position.distance_to(target.global_position) < 10.0:
			_collect()
	elif current_state == state.IDLE:
		_set_animation("Rotation")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if current_state != state.IDLE:
		return
	current_state = state.FOLLOWING
	target = body

func _collect() -> void:
	current_state = state.COLLECTED
	audio_coin.play()
	coin_sprite.stop()
	shadow_sprite.stop()
	await audio_coin.finished
	queue_free()

func _set_animation(animation_name: String) -> void:
	coin_sprite.play(animation_name)
	shadow_sprite.play(animation_name)
