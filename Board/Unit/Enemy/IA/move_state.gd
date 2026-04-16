extends IAState

var path: Array[Vector2i] = []


func enter():
	print("Move State")
	entity.animator.change_animation("Walk")
	path = move_towards()
	if path.is_empty() and not entity.is_moving:
		print("No path → end turn")
		ai.evaluate_best_action()
		return
	
	apply_move()
	
func move_towards():
	var from = entity.current_tile
	var to = get_best_target_tile()
	var pm = entity.unit_data.current_pm
	
	var raw_path = entity.board.compute_path(from, to)
	
	var valid_path: Array[Vector2i] = []
	var steps := 0
	
	for tile in raw_path:
		if not entity.board.is_walkable(tile):
			print("not walkable")
			break
		if steps >= pm:
			print("no more steps")
			break
		
		valid_path.append(tile)
		steps += 1
	
	entity.unit_data.use_pm(steps)
	print("TARGET:", to)
	print("VALID PATH:", valid_path)
	return valid_path
	
func apply_move():
	if path.is_empty():
		return
	entity.set_path(path)
	await entity.stopped_moving
	ai.evaluate_best_action()

func get_tiles_around(tile: Vector2i) -> Array[Vector2i]:
	return [
		tile + Vector2i(1, 0),
		tile + Vector2i(-1, 0),
		tile + Vector2i(0, 1),
		tile + Vector2i(0, -1)
	]
	
func get_best_target_tile() -> Vector2i:
	var player_tile = ai.player.current_tile
	var candidates = get_tiles_around(player_tile)
	
	var best_tile: Vector2i = entity.current_tile
	var best_distance := INF
	
	for tile in candidates:
		if not entity.board.is_walkable(tile):
			continue
		
		var path = entity.board.compute_path(entity.current_tile, tile)
		if path.is_empty():
			continue
		
		var dist = path.size()
		
		if dist < best_distance:
			best_distance = dist
			best_tile = tile
	
	return best_tile
