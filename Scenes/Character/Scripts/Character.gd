extends CharacterBody2D


const SPEED = 300.0

func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	var h_movement = Input.get_axis("ui_left", "ui_right")
	var v_movement = Input.get_axis("ui_up", "ui_down")
	
	velocity = Vector2(h_movement * SPEED, v_movement * SPEED)
	move_and_slide()
