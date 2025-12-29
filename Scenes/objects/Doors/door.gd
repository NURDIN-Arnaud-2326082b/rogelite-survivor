extends StaticBody2D
class_name Door

@onready var door_sprite: AnimatedSprite2D = $DoorSprite
@onready var grid_sprite: AnimatedSprite2D = $GridSprite
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var area: Area2D

var is_open := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_setup_area()
	# Attendre que le parent soit prêt
	await get_tree().process_frame
	var level = get_parent()
	if level.has_signal("room_finished"):
		level.room_finished.connect(_on_room_finished)
	else:
		print("Warning: Door's parent level doesn't have room_finished signal")

func _setup_area() -> void:
	area = Area2D.new()
	var area_collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = collision_shape.shape.size
	area_collision.shape = shape
	area.add_child(area_collision)
	add_child(area)
	area.body_entered.connect(_on_body_entered)
	print("Door area setup complete")

func open() -> void:
	door_sprite.play("Open")
	grid_sprite.play("Lock",true)
	collision_shape.disabled = true
	is_open = true
	print("Door opened!")

func _on_body_entered(body: Node2D) -> void:
	print("Door collision detected with: ", body.name, ", is_open: ", is_open, ", in Player group: ", body.is_in_group("Player"))
	if is_open and body.is_in_group("Player"):
		print("Player entering door, teleporting...")
		var level = get_parent()
		if level.has_method("go_to_next_level"):
			level.go_to_next_level()
		else:
			print("Error: Level doesn't have go_to_next_level method!")

func _on_room_finished() -> void:
	print("Room finished signal received by door")
	open()
