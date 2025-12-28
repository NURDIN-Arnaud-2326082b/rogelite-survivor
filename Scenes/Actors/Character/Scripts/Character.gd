extends Actor
class_name Character

const SPEED = 300.0

func _physics_process(_delta: float) -> void:
	if get_hp() <= 0:
		die()
	
	# Gérer les timers
	if parry_window_timer > 0:
		parry_window_timer -= _delta
	if stun_timer > 0:
		stun_timer -= _delta
		if stun_timer <= 0:
			current_state = STATE.IDLE
	
	# Si stunned, ne rien faire
	if current_state == STATE.STUNNED:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	_move()
	if moving_direction != Vector2.ZERO:
		facing_direction = moving_direction.normalized()
	_update_attack_hitbox_position()

	var dir_name = _find_dir_name(facing_direction)

	if current_state == STATE.HURT or current_state == STATE.PARRY:
		return

	if Input.is_action_just_pressed("ui_accept"):
		current_state = STATE.ATTACK
	
	if Input.is_action_just_pressed("block"):
		_start_parry_window()
		current_state = STATE.BLOCK
	elif Input.is_action_pressed("block"):
		current_state = STATE.BLOCK
	elif current_state == STATE.BLOCK and not Input.is_action_pressed("block"):
		current_state = STATE.IDLE

	if current_state == STATE.ATTACK:
		if dir_name != "":
			_set_animation("attack" + dir_name)
	elif current_state == STATE.BLOCK:
		if dir_name != "":
			_set_animation("block" + dir_name)
	else:
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

func _deal_damage(damage: int) -> void:
	super._deal_damage(damage)
	EVENTS.emit_signal("character_hp_changed", current_health)
	
