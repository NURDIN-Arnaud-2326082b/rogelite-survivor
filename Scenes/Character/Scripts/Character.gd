extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $Sprite2D

const SPEED = 300.0
var is_attacking: bool = false
var is_moving: bool = false
var moving_direction: Vector2 = Vector2.ZERO
var facing_direction: Vector2 = Vector2.DOWN
var dir_dict = {
	"Up": Vector2.UP,
	"Down": Vector2.DOWN,
	"Left": Vector2.LEFT,
	"Right": Vector2.RIGHT
}
func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	
	_move()
	if moving_direction != Vector2.ZERO:
		facing_direction = moving_direction.normalized()
	var dir_name = _find_dir_name(facing_direction)
	if Input.is_action_just_pressed("ui_accept") and not is_attacking:
		is_attacking = !is_attacking
		animated_sprite.frame = 0
	if is_attacking:
		if dir_name != "":
			_set_animation("attack" + dir_name)
	else :
		# Handle move animation
		if moving_direction == Vector2.ZERO:
			animated_sprite.stop()
			animated_sprite.frame = 0
			is_moving = false
		else:
			if dir_name != "":
				is_moving = true
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
		is_attacking = false
		var dir_name = _find_dir_name(facing_direction)
		animated_sprite.set_animation("move" + dir_name)
		animated_sprite.frame = 0
