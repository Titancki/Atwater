class_name UnitData
extends Resource

@export var max_pm := 5
@export var max_pa := 3
@export var max_life := 100
@export var initiative := 10

@export var current_pm := 0
@export var current_pa := 0
@export var current_life := 0

signal damaged(value: int)
signal healed(value: int)
signal life_changed(current: int, max: int)

func reset_turn_values():
	current_pm = max_pm
	current_pa = max_pa
	save()

func initialize():
	current_life = max_life
	reset_turn_values()
	save()

func use_pm(value: int):
	current_pm = max(current_pm - value, 0)
	save()

func use_pa(value: int):
	current_pa = max(current_pa - value, 0)
	save()

func take_damage(value: int):
	current_life = max(current_life - value, 0)
	damaged.emit(value)
	life_changed.emit(current_life, max_life)
	save()

func heal(value: int):
	current_life = min(current_life + value, max_life)
	healed.emit(value)
	life_changed.emit(current_life, max_life)
	save()

func save():
	ResourceSaver.save(self, get_save_path())

func get_save_path() -> String:
	return "res://Data/Units/%s.tres" % resource_name
