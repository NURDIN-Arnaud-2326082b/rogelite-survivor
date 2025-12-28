extends Behavior
class_name CollectableBehavior

enum CollectableState {
	IDLE,
	FOLLOWING,
	COLLECTED
}

var current_state: int = CollectableState.IDLE
var target: Node2D = null
var speed: float = 400.0
var spawn_timer: float = 0.0

@export var idle_animation: String = "Rotation"
@export var following_animation: String = "Idle"
@export var collect_distance: float = 10.0


func _ready() -> void:
	if object == null:
		object = get_parent()
		
	# Chercher l'Area2D dans le parent et se connecter automatiquement
	for child in object.get_children():
		if child is Area2D:
			child.body_entered.connect(on_body_entered)
			print("CollectableBehavior connected to Area2D")
			break

func _physics_process(delta: float) -> void:
	if object == null:
		return

		
	if current_state == CollectableState.FOLLOWING and target != null:
		_follow_target(delta)
	elif current_state == CollectableState.IDLE:
		_idle_behavior()

func _follow_target(delta: float) -> void:
	if object.has_method("_set_animation"):
		object._set_animation(following_animation)
	
	var direction: Vector2 = (target.global_position - object.global_position).normalized()
	object.global_position += direction * speed * delta

	if object.global_position.distance_to(target.global_position) < collect_distance:
		_collect()

func _idle_behavior() -> void:
	if object.has_method("_set_animation"):
		object._set_animation(idle_animation)

func on_body_entered(body: Node2D) -> void:
	print("Body entered collectable: ", body.name)
	if spawn_timer > 0:
		print("Still in spawn delay, ignoring")
		return
	if current_state != CollectableState.IDLE:
		print("Already collecting, ignoring")
		return
	current_state = CollectableState.FOLLOWING
	target = body
	print("Started following target")

func _collect() -> void:
	current_state = CollectableState.COLLECTED
	if object.has_method("_on_collected"):
		object._on_collected()
	
	if "item_data" in object and object.item_data != null:
		EVENTS.emit_signal("object_collected", object.item_data)
