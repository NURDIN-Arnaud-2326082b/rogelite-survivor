extends CharacterBody2D
class_name Actor

@onready var animated_sprite: AnimatedSprite2D = $Sprite2D
@onready var hitbox: Area2D = $AttackHitBox

var facing_direction: Vector2 = Vector2.DOWN
var moving_direction: Vector2 = Vector2.ZERO

var dir_dict = {
	"Up": Vector2.UP,
	"Down": Vector2.DOWN,
	"Left": Vector2.LEFT,
	"Right": Vector2.RIGHT
}

enum STATE {
	IDLE,
	MOVE,
	ATTACK,
	HURT
}

var current_state: STATE = STATE.IDLE
var opacity_tween: Tween

func _ready() -> void:
	if animated_sprite and animated_sprite.material:
		animated_sprite.material = animated_sprite.material.duplicate()

func _find_dir_name(dir: Vector2) -> String:
	var dir_array = dir_dict.values()
	var dir_index = dir_array.find(dir)
	if dir_index != -1:
		var dir_name_array = dir_dict.keys()
		return dir_name_array[dir_index]
	return ""

func _set_animation(dir_name: String) -> void:
	animated_sprite.play(dir_name)

func _update_attack_hitbox_position() -> void:
	var angle = facing_direction.angle()
	hitbox.set_rotation_degrees(rad_to_deg(angle) - 90)

func _attack_effect() -> void:
	var bodies_array = hitbox.get_overlapping_bodies()
	for body in bodies_array:
		if body == self:
			continue
		if body.has_method("_hurt"):
			body._hurt()
		if body.has_method("destroy"):
			body.destroy()
		if body.has_method("interact"):
			body.interact()

func _on_sprite_2d_animation_finished() -> void:
	if "attack".is_subsequence_of(animated_sprite.get_animation()):
		current_state = STATE.IDLE
		var dir_name = _find_dir_name(facing_direction)
		animated_sprite.set_animation("move" + dir_name)
		animated_sprite.frame = 0
	elif "hurt".is_subsequence_of(animated_sprite.get_animation()):
		current_state = STATE.IDLE
		if opacity_tween:
			opacity_tween.kill()
		if animated_sprite.material and animated_sprite.material.get_shader_parameter("opacity") != null:
			animated_sprite.material.set_shader_parameter("opacity", 0.0)
		else:
			animated_sprite.modulate.a = 1.0

func _on_sprite_2d_frame_changed() -> void:
	if "attack".is_subsequence_of(animated_sprite.get_animation()):
		if animated_sprite.frame == 2:
			_attack_effect()

func set_opacity(target_opacity: float, duration: float = 0.3) -> void:
	if opacity_tween:
		opacity_tween.kill()
	opacity_tween = create_tween()
	if animated_sprite.material and animated_sprite.material.get_shader_parameter("opacity") != null:
		opacity_tween.tween_method(func(value): animated_sprite.material.set_shader_parameter("opacity", value), animated_sprite.material.get_shader_parameter("opacity"), target_opacity, duration)
	else:
		opacity_tween.tween_property(animated_sprite, "modulate:a", target_opacity, duration)

func flash_opacity(min_opacity: float = 0.3, flash_duration: float = 0.1, flash_count: int = 3) -> void:
	if opacity_tween:
		opacity_tween.kill()
	opacity_tween = create_tween()
	var current_opacity = 1.0
	if animated_sprite.material and animated_sprite.material.get_shader_parameter("opacity") != null:
		current_opacity = animated_sprite.material.get_shader_parameter("opacity")
		for i in flash_count:
			opacity_tween.tween_method(func(value): animated_sprite.material.set_shader_parameter("opacity", value), current_opacity, min_opacity, flash_duration)
			opacity_tween.tween_method(func(value): animated_sprite.material.set_shader_parameter("opacity", value), min_opacity, 1.0, flash_duration)
			current_opacity = 1.0
	else:
		for i in flash_count:
			opacity_tween.tween_property(animated_sprite, "modulate:a", min_opacity, flash_duration)
			opacity_tween.tween_property(animated_sprite, "modulate:a", 1.0, flash_duration)
	
