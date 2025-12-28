extends StaticBody2D
class_name Door

@onready var door_sprite: AnimatedSprite2D = $DoorSprite
@onready var grid_sprite: AnimatedSprite2D = $GridSprite
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EVENTS.connect("room_finished", Callable(self, "_on_room_finished"))

func open() -> void:
	door_sprite.play("Open")
	grid_sprite.play("Lock",true)
	collision_shape.disabled = true

func _on_room_finished() -> void:
	open()
