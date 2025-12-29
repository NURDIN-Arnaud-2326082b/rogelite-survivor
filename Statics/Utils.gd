extends Object 
class_name Utils

const DIRECTIONS_4 = {
    "Up": Vector2.UP,
    "Down": Vector2.DOWN,
    "Left": Vector2.LEFT,
    "Right": Vector2.RIGHT
}

static func get_adjacents_cells(cell: Vector2) -> Array:
    var adjacents = []
    for direction in DIRECTIONS_4.values():
        adjacents.append(cell + direction)
    return adjacents