class_name Building
extends Node2D

signal placed()

var following := false

var data: BuildingData setget set_data
var type: int
var discovered := false

onready var sprite: Sprite = $Sprite
onready var animation_player: AnimationPlayer = $AnimationPlayer


func set_data(new_data: BuildingData) -> void:
	data = new_data
	sprite.texture = data.image
	sprite.position = Vector2(0.5*(new_data.width - 1), 0.5*(new_data.height - 1)) * Constants.CELL_SIZE

	type = new_data.type


func get_positions() -> PoolVector2Array:
	var positions = []
	var coordinates := (position / Constants.CELL_SIZE).round()
	for i in range(data.width):
		for j in range(data.height):
			positions.push_back(Vector2(i + coordinates.x, j + coordinates.y))
	return PoolVector2Array(positions)

func follow() -> void:
	animation_player.play("Placing")
	following = true


func place() -> void:
	animation_player.play("RESET")
	following = false


func _process(_delta: float) -> void:
	if following:
		var coordinates := (get_global_mouse_position() / Constants.CELL_SIZE).round()

		position = Vector2(
			max(0, min(coordinates.x, Constants.GRID_SIZE - data.width)),
			max(0, min(coordinates.y, Constants.GRID_SIZE - data.height))
		) * Constants.CELL_SIZE

		if Input.is_action_just_pressed("select"):
			place()
			emit_signal("placed")
