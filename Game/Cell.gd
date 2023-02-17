tool
class_name Cell
extends Node2D

enum State {
	EMPTY,
	WAP,
	WNA,
}

signal selected(x, y)

var checked := false setget set_checked
var state: int = State.EMPTY

var x := 0 setget set_x
var y := 0 setget set_y

onready var checked_sprite: Sprite = $Checked


func set_x(new_x: int):
	x = new_x
	position.x = x * Constants.CELL_SIZE


func set_y(new_y: int):
	y = new_y
	position.y = y * Constants.CELL_SIZE

func set_checked(new_checked: bool):
	if new_checked != checked:
		checked = new_checked
		checked_sprite.visible = new_checked


func _on_Area2D_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("select"):
		emit_signal("selected", x, y)
