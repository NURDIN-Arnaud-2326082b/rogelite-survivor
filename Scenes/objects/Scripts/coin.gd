extends Node2D

@onready var coin_sprite: AnimatedSprite2D = $CoinSprite
@onready var shadow_sprite: AnimatedSprite2D = $ShadowSprite
@onready var audio_coin: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _on_collected() -> void:
	audio_coin.play()
	coin_sprite.hide()
	shadow_sprite.hide()
	EVENTS.emit_signal("coin_collected")
	await audio_coin.finished
	queue_free()

func _set_animation(animation_name: String) -> void:
	coin_sprite.play(animation_name)
	shadow_sprite.play(animation_name)
