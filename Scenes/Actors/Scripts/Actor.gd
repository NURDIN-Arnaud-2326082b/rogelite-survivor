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
	ATTACK
}

var current_state: STATE = STATE.IDLE

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

func _on_sprite_2d_frame_changed() -> void:
	if "attack".is_subsequence_of(animated_sprite.get_animation()):
		if animated_sprite.frame == 2:
			_attack_effect()
