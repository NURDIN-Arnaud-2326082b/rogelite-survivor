extends Node2D

func _ready() -> void:
	EVENTS.connect("actor_died", Callable(self, "_on_actor_died"))
	
func _on_actor_died(actor: Actor) -> void:
	if actor is Skeleton:
		var enemies_array = get_tree().get_nodes_in_group("Enemies")
		if enemies_array == [actor]:
			EVENTS.emit_signal("room_finished")
