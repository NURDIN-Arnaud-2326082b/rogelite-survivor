extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $Sprite2D
@onready var hitbox: Area2D = $AttackHitBox
const SPEED = 300.0
var moving_direction: Vector2 = Vector2.ZERO
var facing_direction: Vector2 = Vector2.DOWN
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

func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	
	_move()
	if moving_direction != Vector2.ZERO:
		facing_direction = moving_direction.normalized()
	_update_attack_hitbox_position()

	var dir_name = _find_dir_name(facing_direction)

	if Input.is_action_just_pressed("ui_accept"):
		current_state = STATE.ATTACK
	if current_state == STATE.ATTACK:
		if dir_name != "":
			_set_animation("attack" + dir_name)
	else :
		current_state = STATE.IDLE
		# Idle animation
		if moving_direction == Vector2.ZERO:
			animated_sprite.stop()
			animated_sprite.frame = 0
		else:
			if dir_name != "" and current_state == STATE.IDLE:
				current_state = STATE.MOVE
				_set_animation("move" + dir_name)
	

func _move() -> void:
	moving_direction.x = Input.get_axis("ui_left", "ui_right")
	moving_direction.y = Input.get_axis("ui_up", "ui_down")	
	velocity = moving_direction.normalized() * SPEED
	move_and_slide()

func _set_animation(dir_name: String) -> void:
	animated_sprite.play(dir_name)	

func _find_dir_name(dir: Vector2) -> String:
	var dir_array = dir_dict.values()
	var dir_index = dir_array.find(dir)
	if dir_index != -1:
		var dir_name_array = dir_dict.keys()
		return dir_name_array[dir_index]
	return ""


func _on_sprite_2d_animation_finished() -> void:
	if "attack".is_subsequence_of(animated_sprite.get_animation()):
		current_state = STATE.IDLE
		var dir_name = _find_dir_name(facing_direction)
		animated_sprite.set_animation("move" + dir_name)
		animated_sprite.frame = 0

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


func _on_sprite_2d_frame_changed() -> void:
	if "attack".is_subsequence_of(animated_sprite.get_animation()):
		if animated_sprite.frame == 2:
			_attack_effect()
