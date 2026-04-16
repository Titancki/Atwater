extends Node3D
@onready var anim_player = $UAL1_Standard/AnimationPlayer

func change_animation(anim_name : String):
	print("Animating:", self, " parent:", get_parent())
	if anim_name == "Walk":
		anim_player.speed_scale = 2.0
	else:
		anim_player.speed_scale = 1.0
	anim_player.play(anim_name)

func update_facing(dir: Vector2):
	if dir.length() < 0.01:
		return

	# Convert to angle (2D)
	var angle = dir.angle()

	# Snap to 90° (PI/2)
	var snapped = round(angle / (PI/2)) * (PI/2)

	# Convert to 3D Y rotation
	# IMPORTANT: invert because Godot forward is -Z
	rotation.y = -snapped
