extends Node2D

@export var start_pos_player : Vector2i
@export var start_pos_enemy : Array[Vector2i]
@export var enemies: Array[Unit]
var units_position := {}
@onready var ground = $Ground
var astar := AStarGrid2D.new()

func _ready():
	if not start_pos_player : push_error("Player is missing start position")
	if start_pos_enemy.size() < enemies.size(): push_error("Enemies are missing start positions")
	$TurnManager/Player.setup(start_pos_player)
	for i in range(enemies.size()):
		enemies[i].setup(start_pos_enemy[i])
	setup_astar()

func world_to_tile(world_pos: Vector2) -> Vector2i:
	var local = ground.to_local(world_pos)
	return ground.local_to_map(local)

func tile_to_world(tile: Vector2i) -> Vector2:
	return ground.map_to_local(tile)

func is_walkable(tile: Vector2i) -> bool:
	if ground.get_cell_source_id(tile) == -1:
		return false

	if units_position.has(tile):
		return false

	return true

func compute_path(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
	if not astar.is_in_boundsv(from) or not astar.is_in_boundsv(to):
		return []

	# TEMP: allow starting tile
	var was_solid = astar.is_point_solid(from)
	astar.set_point_solid(from, false)

	var result = astar.get_id_path(from, to)

	# restore state
	astar.set_point_solid(from, was_solid)

	if result.size() > 0:
		result.remove_at(0)

	return result

func setup_astar():
	var used = ground.get_used_cells()
	if used.is_empty():
		return

	var min_x = used[0].x
	var max_x = used[0].x
	var min_y = used[0].y
	var max_y = used[0].y

	for cell in used:
		min_x = min(min_x, cell.x)
		max_x = max(max_x, cell.x)
		min_y = min(min_y, cell.y)
		max_y = max(max_y, cell.y)

	astar.region = Rect2i(
		Vector2i(min_x, min_y),
		Vector2i(max_x - min_x + 1, max_y - min_y + 1)
	)

	astar.cell_size = Vector2(1, 1)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()

	for x in range(min_x, max_x + 1):
		for y in range(min_y, max_y + 1):
			var pos = Vector2i(x, y)

			if ground.get_cell_source_id(pos) == -1:
				astar.set_point_solid(pos, true)

func move_astar_obstacle(from: Vector2i, to = null):
	if to :
		astar.set_point_solid(from, false)
		astar.set_point_solid(to, true)
	else :
		astar.set_point_solid(from, true)
	
