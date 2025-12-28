extends CharacterBody2D
class_name Actor

@onready var animated_sprite: AnimatedSprite2D = $Sprite2D
@onready var hitbox: Area2D = $AttackHitBox

var facing_direction: Vector2 = Vector2.DOWN
var moving_direction: Vector2 = Vector2.ZERO

@export var max_health: int = 3
@onready var current_health: int = max_health

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
	HURT,
	BLOCK,
	PARRY,
	STUNNED,
	DEAD
}

var current_state: STATE = STATE.IDLE
var opacity_tween: Tween
var has_attacked: bool = false
var parry_window_timer: float = 0.0
var parry_window_duration: float = 0.2
var stun_timer: float = 0.0

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
	if has_attacked:
		return
	has_attacked = true
	var bodies_array = hitbox.get_overlapping_bodies()
	for body in bodies_array:
		if body == self:
			continue
		if body.has_method("_deal_damage"):
			var is_blocking = body.current_state == STATE.BLOCK if "current_state" in body else false
			var is_in_parry_window = body.parry_window_timer > 0 if "parry_window_timer" in body else false
			var block_successful = false
			var parry_successful = false
			
			# Vérifier si c'est un parry (dans la fenêtre de temps)
			if is_in_parry_window and is_blocking and "facing_direction" in body:
				var defender_facing = body.facing_direction.normalized()
				var attacker_facing = facing_direction.normalized()
				if defender_facing.dot(attacker_facing) < -0.5:
					parry_successful = true
					print("Parry successful!")
					if body.has_method("_on_parry_success"):
						body._on_parry_success()
					# Stunner l'attaquant
					_get_stunned(2.0)
					return
			if parry_successful:
				continue
			# Vérifier si le blocage est dans la bonne direction
			if is_blocking and "facing_direction" in body:
				# Le défenseur doit bloquer dans la direction opposée à l'attaque
				var defender_facing = body.facing_direction.normalized()
				var attacker_facing = facing_direction.normalized()
				# Les directions doivent être opposées (produit scalaire proche de -1)
				if defender_facing.dot(attacker_facing) < -0.5:
					block_successful = true
					print("Block successful!")
					if body.has_method("_on_block_success"):
						body._on_block_success()
			
			# Appliquer les dégâts seulement si le blocage a échoué
			if not block_successful:
				if body.has_method("_hurt"):
					body._hurt()
				body._deal_damage(1)
		if body.has_method("destroy"):
			body.destroy()
		if body.has_method("interact"):
			body.interact()

func _on_sprite_2d_animation_finished() -> void:
	if "attack".is_subsequence_of(animated_sprite.get_animation()):
		current_state = STATE.IDLE
		has_attacked = false
		var dir_name = _find_dir_name(facing_direction)
		animated_sprite.set_animation("idle" + dir_name)
		animated_sprite.frame = 0
	elif "hurt".is_subsequence_of(animated_sprite.get_animation()):
		current_state = STATE.IDLE
		if opacity_tween:
			opacity_tween.kill()
		if animated_sprite.material and animated_sprite.material.get_shader_parameter("opacity") != null:
			animated_sprite.material.set_shader_parameter("opacity", 0.0)
		else:
			animated_sprite.modulate.a = 1.0
	elif "block".is_subsequence_of(animated_sprite.get_animation()):
		current_state = STATE.IDLE
		var dir_name = _find_dir_name(facing_direction)
		animated_sprite.set_animation("idle" + dir_name)
		animated_sprite.frame = 0
	elif "parry".is_subsequence_of(animated_sprite.get_animation()):
		current_state = STATE.IDLE
		var dir_name = _find_dir_name(facing_direction)
		animated_sprite.set_animation("idle" + dir_name)
		animated_sprite.frame = 0

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

func set_color(target_color: Color, duration: float = 0.3) -> void:
	if opacity_tween:
		opacity_tween.kill()
	opacity_tween = create_tween()
	if animated_sprite.material and animated_sprite.material.get_shader_parameter("flash_color") != null:
		var current_color = animated_sprite.material.get_shader_parameter("flash_color")
		opacity_tween.tween_method(func(value): animated_sprite.material.set_shader_parameter("flash_color", value), current_color, target_color, duration)
	else:
		opacity_tween.tween_property(animated_sprite, "modulate", target_color, duration)

func flash_opacity(min_opacity: float = 0.3, flash_duration: float = 0.1, flash_count: int = 3) -> void:
	if opacity_tween:
		opacity_tween.kill()
	opacity_tween = create_tween()
	var current_opacity = 1.0
	if animated_sprite.material and animated_sprite.material.get_shader_parameter("opacity") != null:
		# Remettre flash_color à blanc pour le hurt normal
		animated_sprite.material.set_shader_parameter("flash_color", Color.WHITE)
		current_opacity = animated_sprite.material.get_shader_parameter("opacity")
		for i in flash_count:
			opacity_tween.tween_method(func(value): animated_sprite.material.set_shader_parameter("opacity", value), current_opacity, min_opacity, flash_duration)
			opacity_tween.tween_method(func(value): animated_sprite.material.set_shader_parameter("opacity", value), min_opacity, 1.0, flash_duration)
			current_opacity = 1.0
	else:
		for i in flash_count:
			opacity_tween.tween_property(animated_sprite, "modulate:a", min_opacity, flash_duration)
			opacity_tween.tween_property(animated_sprite, "modulate:a", 1.0, flash_duration)

func flash_color(flash_color_value: Color = Color.YELLOW, flash_duration: float = 0.1, flash_count: int = 3) -> void:
	if opacity_tween:
		opacity_tween.kill()
	opacity_tween = create_tween()
	if animated_sprite.material and animated_sprite.material.get_shader_parameter("flash_color") != null:
		# Définir la couleur du flash
		animated_sprite.material.set_shader_parameter("flash_color", flash_color_value)
		# Faire clignoter l'opacité entre 0 et 1
		for i in flash_count:
			opacity_tween.tween_method(func(value): animated_sprite.material.set_shader_parameter("opacity", value), 0.0, 0.8, flash_duration)
			opacity_tween.tween_method(func(value): animated_sprite.material.set_shader_parameter("opacity", value), 0.8, 0.0, flash_duration)
		# Remettre à 0 à la fin
		opacity_tween.tween_callback(func(): animated_sprite.material.set_shader_parameter("opacity", 0.0))
	else:
		for i in flash_count:
			opacity_tween.tween_property(animated_sprite, "modulate", flash_color_value, flash_duration)
			opacity_tween.tween_property(animated_sprite, "modulate", Color.WHITE, flash_duration)
		opacity_tween.tween_callback(func(): animated_sprite.modulate = Color.WHITE)
	
func set_hp(amount: int) -> void:
	current_health = Maths.clampi(amount, 0, max_health)

func get_hp() -> int:
	return current_health

func _deal_damage(damage: int) -> void:
	# Ignorer les dégâts si l'acteur est déjà mort
	if current_state == STATE.DEAD:
		return
	
	set_hp(current_health - damage)
	print("Actor HP: ", current_health)

func _start_parry_window() -> void:
	parry_window_timer = parry_window_duration

func _on_parry_success() -> void:
	current_state = STATE.PARRY
	parry_window_timer = 0.0
	var dir_name = _find_dir_name(facing_direction)
	if dir_name != "" and animated_sprite.sprite_frames.has_animation("parry" + dir_name):
		_set_animation("parry" + dir_name)
	else:
		print("Warning: parry animation not found for direction", dir_name)

func _get_stunned(duration: float) -> void:
	current_state = STATE.STUNNED
	stun_timer = duration
	flash_color(Color.YELLOW, 0.15, int(duration / 0.3))
	var dir_name = _find_dir_name(facing_direction)
	if dir_name != "" and animated_sprite.sprite_frames.has_animation("hurt" + dir_name):
		_set_animation("hurt" + dir_name)
	print("Actor stunned for", duration, "seconds")

func die() -> void:
	# Empêcher de mourir plusieurs fois
	if current_state == STATE.DEAD:
		return
	
	current_state = STATE.DEAD
	EVENTS.emit_signal("actor_died", self)
	
	var dir_name = _find_dir_name(facing_direction)
	if dir_name != "" and animated_sprite.sprite_frames.has_animation("dead" + dir_name):
		_set_animation("dead" + dir_name)
		await animated_sprite.animation_finished
	
	queue_free()
