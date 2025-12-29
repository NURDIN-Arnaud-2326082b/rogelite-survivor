extends Node
class_name Walker

var max_steps: int = 0
var nb_steps: int = 0

var cell = Vector2.INF:
	set(value):
		if value != cell:
			cell = value
			moved.emit(cell)

var sub_walkers_steps := Array()

signal moved(cell)
signal arrived()
signal created_sub_walker

func _init(_max_steps: int, _cell: Vector2, nb_sub_walkers : int) -> void:
	max_steps = _max_steps
	cell = _cell
	nb_steps = 0
	choose_sub_walker_steps(nb_sub_walkers)

func step(accesibles_cells: Array) -> void:
	if accesibles_cells.size() == 0:
		arrived.emit()
		return
	
	nb_steps += 1
	var new_cell = choose_new_cell(accesibles_cells)
	cell = new_cell

	if nb_steps in sub_walkers_steps:
		sub_walkers_steps.erase(nb_steps)
		created_sub_walker.emit(cell,4,0)

	if nb_steps >= max_steps:
		arrived.emit()
		return

func choose_new_cell(accesibles_cells: Array) -> Vector2:
	var rand_idx = randi() % accesibles_cells.size()
	return accesibles_cells[rand_idx]

func choose_sub_walker_steps(nb_walkers : int) -> void:
	var steps_array = range(max_steps)
	steps_array.shuffle()
	for i in range(nb_walkers):
		if steps_array.size() == 0:
			break
		var step_value = steps_array.pop_front()
		sub_walkers_steps.append(step_value)
