extends Node2D
class_name DungeonGenerator

enum CELL_TYPE {
	EMPTY,
	WALL
}

@export var grid_size := Vector2(10,10)
@export var entry_tile_source := 1  
@export var entry_tile_id := Vector2i(0, 0)
@export var exit_tile_source := 2   
@export var exit_tile_id := Vector2i(0, 0)
@export var level_scene : PackedScene  # La scène level à instancier
@export var player_scene : PackedScene  # La scène du player
@export var enemy_scenes : Array[PackedScene] = []  # Les scènes d'ennemis à spawner
@export var min_enemies_per_level := 1  # Nombre minimum d'ennemis par level
@export var max_enemies_per_level := 5  # Nombre maximum d'ennemis par level
@export var spawn_radius := 300.0  # Rayon de spawn autour du centre du level
@export var level_spacing := Vector2(1920, 1080)  # Espacement entre chaque level (taille d'un level)
var grid : Array = []
@onready var tile_map : TileMapLayer = $TileMapLayer
@onready var control : Control = $Celldistances

var walker_array : Array = []
var djikstra_map : Array = []
var level_instances : Array = []

var entry_cell : Vector2 
var exit_cell : Vector2 

func get_djikstra_map() -> Array:
	return djikstra_map

func get_entry_cell() -> Vector2:
	return entry_cell

func get_exit_cell() -> Vector2:
	return exit_cell

func get_distance_to_entry(cell: Vector2) -> int:
	var cell_dist = get_djikstra_cell_dist(cell)
	if cell_dist != null:
		return cell_dist.distance
	return -1 

func _ready() -> void:
	control.position = tile_map.position
	_generate_dungeon()

func _generate_dungeon() -> void:
	print("Starting dungeon generation")
	_clear_levels()
	_init_grid()
	entry_cell = _get_rdm_cell()
	_place_walker(entry_cell)
	while (!walker_array.is_empty()):
		for walker in walker_array:
			var accesibles_cells = _get_accessible_cells(walker.cell)
			walker.step(accesibles_cells)
	_update_grid()
	entry_cell = _find_random_empty_cell()
	djikstra_map.clear()
	compute_cell_distance(entry_cell)
	exit_cell = _find_farthest_cell()
	_place_entry_and_exit_cells()
	_display_djikstra_map()
	_generate_levels()
	print("Dungeon generation completed")
	# Spawner le player après un court délai
	get_tree().create_timer(0.1).timeout.connect(_spawn_player)

func _init_grid() -> void:
	grid.clear()
	for x in range(grid_size.x):
		grid.append([])
		for y in range(grid_size.y):
			grid[x].append(CELL_TYPE.WALL)

func _update_grid() -> void:
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var cell_type = grid[x][y]
			tile_map.set_cell(Vector2i(x, y), 0, Vector2i(cell_type - 1, 0))

func set_cell(cell: Vector2, cell_type: int) -> void:
	grid[cell.x][cell.y] = cell_type

func _place_walker(cell : Vector2, max_steps := 9, nb_sub_walkers := 2) -> void:
	var walker = Walker.new(max_steps, cell, nb_sub_walkers)
	walker_array.append(walker)
	add_child(walker)
	walker.connect("moved", Callable(self, "_on_walker_moved"))
	walker.connect("arrived", Callable(self, "_on_walker_arrived").bind(walker))
	walker.connect("created_sub_walker", Callable(self, "_on_created_sub_walker"))

func _get_accessible_cells(cell: Vector2) -> Array:
	var adjacents = Utils.get_adjacents_cells(cell)
	var accesibles_cells = []
	for adjacent in adjacents:
		if is_inside_grid(adjacent) and grid[adjacent.x][adjacent.y] == CELL_TYPE.WALL:
			accesibles_cells.append(adjacent)
	return accesibles_cells

func is_inside_grid(cell: Vector2) -> bool:
	return cell.x >= 0 and cell.x < grid_size.x and cell.y >= 0 and cell.y < grid_size.y

func _get_rdm_cell() -> Vector2:
	return Vector2(randi() % int(grid_size.x), randi() % int(grid_size.y))

func _find_random_empty_cell() -> Vector2:
	var empty_cells = []
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			if grid[x][y] == CELL_TYPE.EMPTY:
				empty_cells.append(Vector2(x, y))
	
	if empty_cells.size() > 0:
		return empty_cells[randi() % empty_cells.size()]
	return Vector2(0, 0)

func _find_farthest_cell() -> Vector2:
	if djikstra_map.is_empty():
		return Vector2(0, 0)
	
	var max_distance = 0
	for cell_distance in djikstra_map:
		if cell_distance.distance > max_distance:
			max_distance = cell_distance.distance
	
	# Si la distance max est inférieure à 6, régénérer
	if max_distance < 6:
		_generate_dungeon()
		return exit_cell
	
	var farthest_cells = []
	for cell_distance in djikstra_map:
		if cell_distance.distance == max_distance:
			farthest_cells.append(cell_distance.cell)
	
	if farthest_cells.size() > 0:
		return farthest_cells[randi() % farthest_cells.size()]
	return Vector2(0, 0)

func compute_cell_distance(cell : Vector2, distance : int = 0) -> void:
	if djikstra_map.size() == 0:
		djikstra_map.append(CellDistance.new(cell, 0))
	
	distance += 1
	var adjacents = Utils.get_adjacents_cells(cell)
	for adjacent in adjacents:
		if !is_inside_grid(adjacent) or grid[int(adjacent.x)][int(adjacent.y)] != CELL_TYPE.EMPTY:
			continue
		
		var cell_distance = get_djikstra_cell_dist(adjacent)
		if cell_distance == null:
			djikstra_map.append(CellDistance.new(adjacent, distance)) 
			compute_cell_distance(adjacent, distance)
		elif  cell_distance.distance > distance:
			cell_distance.distance = distance
			compute_cell_distance(adjacent, distance)

func get_djikstra_cell_dist(cell : Vector2) -> CellDistance:
	for cell_distance in djikstra_map:
		if cell_distance.cell.is_equal_approx(cell):
			return cell_distance
	return null

func _display_djikstra_map() -> void:
	for child in control.get_children():
		child.queue_free()
	for cell_distance in djikstra_map:
		var label = Label.new()
		label.text = str(cell_distance.distance)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		var world_pos = tile_map.map_to_local(Vector2i(cell_distance.cell))
		var tile_size = Vector2(tile_map.tile_set.tile_size)
		label.position = world_pos - tile_size / 2
		label.size = tile_size
		control.add_child(label)

func _generate_levels() -> void:
	if level_scene == null:
		print("Warning: No level scene assigned!")
		return
	
	# S'assurer que level_instances est vide
	level_instances.clear()
	
	# Trier les cellules par distance croissante (de l'entrée vers la sortie)
	var sorted_cells = djikstra_map.duplicate()
	sorted_cells.sort_custom(func(a, b): return a.distance < b.distance)
	
	print("Generating ", sorted_cells.size(), " levels from djikstra map")
	
	var level_index = 0
	for cell_distance in sorted_cells:
		var level_instance = level_scene.instantiate()
		
		# Positionner le level avec l'espacement défini
		var level_pos = cell_distance.cell * level_spacing
		level_instance.position = level_pos
		
		# Passer des informations au level avec l'ordre
		if level_instance.has_method("set_cell_data"):
			level_instance.set_cell_data(cell_distance.cell, cell_distance.distance, level_index, len(sorted_cells))
		
		# Déterminer le level suivant pour la navigation
		var next_level = level_instances[level_index - 1] if level_index > 0 else null
		var prev_level = null
		
		if level_instance.has_method("set_navigation"):
			level_instance.set_navigation(prev_level, next_level, level_index)
		
		add_child(level_instance)
		level_instances.append(level_instance)
		level_index += 1
	
	print("Created ", level_instances.size(), " level instances")
	
	# Vérifier la cohérence
	if level_instances.size() != sorted_cells.size():
		print("ERROR: Level count mismatch! Instances: ", level_instances.size(), ", Cells: ", sorted_cells.size())
	
	# Spawner les ennemis APRES que tous les levels soient ajoutés
	await get_tree().process_frame
	
	for i in range(level_instances.size()):
		var level = level_instances[i]
		var cell_dist = sorted_cells[i]
		_spawn_enemies_in_level(level, cell_dist.distance)
	
	# Maintenant que tous les levels sont créés, mettre à jour les références next/prev
	for i in range(level_instances.size()):
		var current = level_instances[i]
		var next_level = level_instances[i + 1] if i < level_instances.size() - 1 else null
		var prev_level = level_instances[i - 1] if i > 0 else null
		
		if current.has_method("set_navigation"):
			current.set_navigation(prev_level, next_level, i)

func _spawn_player() -> void:
	if player_scene == null:
		print("Warning: No player scene assigned!")
		return
	
	if level_instances.is_empty():
		print("Warning: No levels generated!")
		return
	
	# Attendre que tout soit bien initialisé
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Instancier le player
	var player = player_scene.instantiate()
	var first_level = level_instances[0]
	
	# Définir la position AVANT d'ajouter à la scène
	player.position = Vector2(960, 540)
	
	# Ajouter le player
	first_level.add_child(player)
	
	print("Player spawned in first level at ", player.position)

func _spawn_enemies_in_level(level_instance: Node2D, distance: int) -> void:
	if enemy_scenes.is_empty():
		return
	
	# Calculer le nombre d'ennemis en fonction de la distance (plus loin = plus d'ennemis)
	var base_count = randi_range(min_enemies_per_level, max_enemies_per_level)
	var distance_bonus = int(distance / 3.0)  # +1 ennemi tous les 3 tiles de distance
	var enemy_count = min(base_count + distance_bonus, max_enemies_per_level * 2)
	
	# Définir une zone centrale pour le spawn (zone sûre loin des murs)
	var center = Vector2(960, 540)
	var safe_zone = 250.0  # Zone de 500x500 au centre
	
	for i in range(enemy_count):
		# Choisir un ennemi aléatoirement
		var enemy_scene = enemy_scenes[randi() % enemy_scenes.size()]
		var enemy = enemy_scene.instantiate()
		
		# Position aléatoire dans la zone centrale
		var offset_x = randf_range(-safe_zone, safe_zone)
		var offset_y = randf_range(-safe_zone, safe_zone)
		var spawn_pos = center + Vector2(offset_x, offset_y)
		
		# Définir la position AVANT d'ajouter à la scène
		enemy.position = spawn_pos
		level_instance.add_child(enemy)
	
	print("Spawned ", enemy_count, " enemies in level at distance ", distance)

func _clear_levels() -> void:
	for level_instance in level_instances:
		if is_instance_valid(level_instance):
			level_instance.queue_free()
	level_instances.clear()

func _place_entry_and_exit_cells() -> void:
	tile_map.set_cell(Vector2i(int(entry_cell.x), int(entry_cell.y)), entry_tile_source, entry_tile_id)
	tile_map.set_cell(Vector2i(int(exit_cell.x), int(exit_cell.y)), exit_tile_source, exit_tile_id)

func _on_walker_moved(new_cell: Vector2) -> void:
	set_cell(new_cell, CELL_TYPE.EMPTY)

func _on_walker_arrived(walker: Walker) -> void:
	walker_array.erase(walker)
	walker.queue_free()

func _on_created_sub_walker(cell: Vector2, max_steps: int, nb_sub_walkers: int) -> void:
	_place_walker(cell, max_steps, nb_sub_walkers)

class CellDistance :
	var cell := Vector2.INF
	var distance : int = -1

	func _init(_cell : Vector2, _distance : int) -> void:
		cell = _cell
		distance = _distance
