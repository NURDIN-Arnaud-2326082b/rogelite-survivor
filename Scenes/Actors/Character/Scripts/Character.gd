extends Actor
class_name Character

const SPEED = 300.0

func _physics_process(_delta: float) -> void:
	
	_move()
	if moving_direction != Vector2.ZERO:
		facing_direction = moving_direction.normalized()
	_update_attack_hitbox_position()

	var dir_name = _find_dir_name(facing_direction)

	if current_state == STATE.HURT:
		return

	if Input.is_action_just_pressed("ui_accept"):
		current_state = STATE.ATTACK
	if current_state == STATE.ATTACK:
		if dir_name != "":
			_set_animation("attack" + dir_name)
	else :
		current_state = STATE.IDLE
		if moving_direction == Vector2.ZERO:
			if dir_name != "":
				_set_animation("idle" + dir_name)
		else:
			if dir_name != "" and current_state == STATE.IDLE:
				current_state = STATE.MOVE
				_set_animation("move" + dir_name)
	

func _move() -> void:
	moving_direction.x = Input.get_axis("ui_left", "ui_right")
	moving_direction.y = Input.get_axis("ui_up", "ui_down")	
	velocity = moving_direction.normalized() * SPEED
	move_and_slide()

func _hurt() -> void:
	if current_state != STATE.HURT:
		current_state = STATE.HURT
		flash_opacity(0.3, 0.1, 3)
		var dir_name = _find_dir_name(facing_direction)
		if dir_name != "":
			_set_animation("hurt" + dir_name)
