extends Node2D

signal room_finished

var cell_position : Vector2
var distance_from_entry : int
var level_order : int  # 0 = entrée, dernier = sortie
var total_levels : int

var previous_level  # Level précédent dans le chemin
var next_level      # Level suivant dans le chemin

func set_cell_data(cell: Vector2, distance: int, order: int, total: int) -> void:
	cell_position = cell
	distance_from_entry = distance
	level_order = order
	total_levels = total
	print("Level #", order, "/", total, " - Distance: ", distance)

func set_navigation(prev, next, order: int) -> void:
	previous_level = prev
	next_level = next
	level_order = order

func go_to_next_level():
	if next_level != null:
		print("Teleporting to next level: ", next_level.level_order)
		_teleport_player_to_level(next_level)
		EVENTS.emit_signal("change_level", next_level)

func go_to_previous_level():
	if previous_level != null:
		print("Teleporting to previous level: ", previous_level.level_order)
		_teleport_player_to_level(previous_level)
		EVENTS.emit_signal("change_level", previous_level)

func _teleport_player_to_level(target_level: Node2D) -> void:
	# Trouver le joueur dans ce level
	var player = null
	for child in get_children():
		if child.is_in_group("Player"):
			player = child
			break
	
	if player == null:
		print("Warning: No player found in current level!")
		return
	
	# Retirer le joueur de ce level
	remove_child(player)
	
	# Ajouter le joueur au level suivant
	target_level.add_child(player)
	
	# Positionner le joueur au centre du nouveau level
	player.position = Vector2(960, 540)
	
	print("Player teleported to level ", target_level.level_order)

func _ready() -> void:
	EVENTS.connect("actor_died", Callable(self, "_on_actor_died"))
	# Compter les ennemis au démarrage
	await get_tree().process_frame
	_count_enemies()

func _count_enemies() -> void:
	var count = 0
	for child in get_children():
		if child is Skeleton:
			count += 1
	print("Level ", level_order, " has ", count, " enemies")
	
func _on_actor_died(actor: Actor) -> void:
	if not (actor is Skeleton):
		return
	
	# Vérifier si cet acteur est dans CE level
	if not is_ancestor_of(actor):
		return
	
	print("Enemy died in level ", level_order)
	
	# Attendre la prochaine frame pour que l'acteur soit bien traité
	await get_tree().process_frame
	
	# Compter les ennemis encore vivants dans CE level uniquement
	var enemies_count = 0
	for child in get_children():
		if child is Skeleton and is_instance_valid(child) and not child.is_queued_for_deletion():
			enemies_count += 1
	
	print("Enemies remaining in level ", level_order, ": ", enemies_count)
	
	# Si plus aucun ennemi vivant dans ce level, la room est terminée
	if enemies_count == 0:
		print("Room ", level_order, " finished! All enemies defeated.")
		room_finished.emit()  # Signal local du level
		EVENTS.emit_signal("room_finished")  # Signal global pour autres systèmes si besoin
