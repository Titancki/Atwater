extends Node3D
@onready var player = $UAL1_Standard/AnimationPlayer

func change_animation(anim_name : String):
	print("Animating:", self, " parent:", get_parent())
	if anim_name == "Walk":
		player.speed_scale = 2.0
	else:
		player.speed_scale = 1.0
	player.play(anim_name)

func update_facing(dir: Vector2):
	if dir.length() < 0.01:
		return

	# Convert to angle (2D)
	var angle = dir.angle()

	# Snap to 90° (PI/2)
	var limit = round(angle / ((-PI)/2)) * (PI/2)

	$UAL1_Standard.rotation.y = limit + PI/2

func look_at_tile(from_tile: Vector2i, target_tile: Vector2i):
	print(from_tile, target_tile)
	var dir = (target_tile - from_tile)
	print(dir)

	# Convert to Vector2
	var dir2 = Vector2(dir.x, dir.y)

	update_facing(dir2)
	
func play_walk_and_wait():
	player.play("Walk")
	await player.animation_finished
