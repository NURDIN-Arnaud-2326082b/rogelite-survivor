extends Actor

const SPEED = 100.0
const CHASE_SPEED = 100.0
const DETECTION_RANGE = 200.0
const ATTACK_RANGE = 33.0
const WANDER_TIME = 2.0
const IDLE_TIME = 1.5
const PATH_UPDATE_INTERVAL = 0.5
const ATTACK_COOLDOWN = 1.0

enum AI_STATE {
	WANDER,
	CHASE,
	ATTACK
}

var current_ai_state: AI_STATE = AI_STATE.WANDER
var target: Character = null
var wander_timer: float = 0.0
var wander_direction: Vector2 = Vector2.ZERO
var idle_timer: float = 0.0
var is_wandering: bool = false
var path_update_timer: float = 0.0
var attack_cooldown_timer: float = 0.0

@onready var detection_area: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

func _ready() -> void:
	if navigation_agent:
		navigation_agent.path_desired_distance = 4.0
		navigation_agent.target_desired_distance = 4.0
		navigation_agent.avoidance_enabled = true
		navigation_agent.radius = 16.0
	
	if animated_sprite:
		animated_sprite.animation_finished.connect(_on_animation_finished)
		animated_sprite.frame_changed.connect(_on_frame_changed)
	
	if detection_area:
		detection_area.body_entered.connect(_on_detection_area_body_entered)
		detection_area.body_exited.connect(_on_detection_area_body_exited)
	
	call_deferred("_start_wander")

func _physics_process(delta: float) -> void:
	if attack_cooldown_timer > 0:
		attack_cooldown_timer -= delta
	
	if target and global_position.distance_to(target.global_position) <= ATTACK_RANGE:
		current_ai_state = AI_STATE.ATTACK
	elif target:
		current_ai_state = AI_STATE.CHASE
	else:
		current_ai_state = AI_STATE.WANDER
	
	print("Current AI State: ", current_ai_state)
	match current_ai_state:
		AI_STATE.WANDER:
			_ai_wander(delta)
		AI_STATE.CHASE:
			_ai_chase()
		AI_STATE.ATTACK:
			_ai_attack()
	
	if moving_direction != Vector2.ZERO:
		facing_direction = moving_direction.normalized()
		facing_direction = _get_cardinal_direction(facing_direction)
	_update_attack_hitbox_position()

	var dir_name = _find_dir_name(facing_direction)
	
	if current_state == STATE.HURT:
		return
	
	if dir_name != "":
		match current_ai_state:
			AI_STATE.WANDER:
				if is_wandering:
					_set_animation("move" + dir_name)
				else:
					_set_animation("idle" + dir_name)
			AI_STATE.CHASE:
				_set_animation("move" + dir_name)
			AI_STATE.ATTACK:
				var attack_anim_name = "attack" + dir_name
				if target:
					facing_direction = _get_cardinal_direction((target.global_position - global_position).normalized())
					dir_name = _find_dir_name(facing_direction)
					attack_anim_name = "attack" + dir_name
				
				if attack_cooldown_timer <= 0 and (not animated_sprite.is_playing() or animated_sprite.get_animation() != attack_anim_name):
					current_state = STATE.ATTACK
					_set_animation(attack_anim_name)
					attack_cooldown_timer = ATTACK_COOLDOWN

func _ai_wander(delta: float) -> void:
	if is_wandering:
		wander_timer -= delta
		if wander_timer <= 0:
			is_wandering = false
			idle_timer = IDLE_TIME
			moving_direction = Vector2.ZERO
			velocity = Vector2.ZERO
		else:
			if navigation_agent.is_navigation_finished():
				_start_wander()
			else:
				var next_position = navigation_agent.get_next_path_position()
				var direction = (next_position - global_position).normalized()
				moving_direction = direction
				velocity = direction * SPEED
				move_and_slide()
	else:
		idle_timer -= delta
		if idle_timer <= 0:
			_start_wander()
		moving_direction = Vector2.ZERO
		velocity = Vector2.ZERO

func _start_wander() -> void:
	is_wandering = true
	wander_timer = WANDER_TIME
	var angle = randf() * TAU
	var distance = randf_range(100.0, 300.0)
	var target_position = global_position + Vector2(cos(angle), sin(angle)) * distance
	
	if navigation_agent:
		navigation_agent.target_position = target_position
	
	wander_direction = (target_position - global_position).normalized()
	facing_direction = _get_cardinal_direction(wander_direction)

func _get_cardinal_direction(dir: Vector2) -> Vector2:
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			return Vector2.RIGHT
		else:
			return Vector2.LEFT
	else:
		if dir.y > 0:
			return Vector2.DOWN
		else:
			return Vector2.UP

func _ai_chase() -> void:
	if target and navigation_agent:
		path_update_timer -= get_physics_process_delta_time()
		if path_update_timer <= 0:
			navigation_agent.target_position = target.global_position
			path_update_timer = PATH_UPDATE_INTERVAL
		
		if not navigation_agent.is_navigation_finished():
			var next_position = navigation_agent.get_next_path_position()
			var direction = (next_position - global_position).normalized()
			moving_direction = direction
			velocity = direction * CHASE_SPEED
			move_and_slide()

func _ai_attack() -> void:
	moving_direction = Vector2.ZERO
	velocity = Vector2.ZERO

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body is Character:
		target = body

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == target:
		target = null

func _on_animation_finished() -> void:
	if "attack".is_subsequence_of(animated_sprite.get_animation()):
		current_state = STATE.IDLE

func _on_frame_changed() -> void:
	if "attack".is_subsequence_of(animated_sprite.get_animation()):
		if animated_sprite.frame == 2:
			_attack_effect()

func _hurt() -> void:
	if current_state != STATE.HURT:
		current_state = STATE.HURT
		attack_cooldown_timer = ATTACK_COOLDOWN
		flash_opacity(0.3, 0.1, 3)
		var dir_name = _find_dir_name(facing_direction)
		if dir_name != "":
			_set_animation("hurt" + dir_name)
