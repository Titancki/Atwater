extends UnitState

var path: Array[Vector2i] = []
var current_step := 0

func enter(data = {}):
	print("Move State")
	unit.animator.change_animation("Walk")
	var target: Vector2i = data.get("target", null)
	if target == null:
		state_machine.change_state("Idle")
		return

	path = _compute_path(target)

	if path.is_empty():
		state_machine.change_state("Idle")
		return

	# Consume PM
	unit.data.use_pm(path.size())

	current_step = 0	
	_move_next()

func update(_delta):
	# Wait until unit reaches current target
	if not unit.is_arrived():
		return

	# Continue path
	if current_step < path.size():
		_move_next()
	else:
		_finish_move()

func _move_next():
	var next_tile = path[current_step]
	current_step += 1

	unit.animator.look_at_tile(unit.current_tile, next_tile)

	unit.move_to_tile(next_tile)

func _finish_move():
	state_machine.change_state("Idle")

func _compute_path(target: Vector2i) -> Array[Vector2i]:
	var from = unit.current_tile
	var pm = unit.data.current_pm

	var raw_path = unit.board.compute_path(from, target)

	var valid_path: Array[Vector2i] = []
	var steps := 0

	for tile in raw_path:
		if not unit.board.is_walkable(tile):
			break
		if steps >= pm:
			break

		valid_path.append(tile)
		steps += 1

	return valid_path
