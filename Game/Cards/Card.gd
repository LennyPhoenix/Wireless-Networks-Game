class_name Card
extends Control

signal used(data)

var data: CardData setget set_data
var used := false

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var title: Label = $"%Title"
onready var image: TextureRect = $"%Image"
onready var description: Label = $"%Description"


func set_data(new_data: CardData) -> void:
	data = new_data
	title.text = data.name
	image.texture = data.image
	description.text = data.description


func _on_Panel_mouse_entered() -> void:
	if not used:
		animation_player.play("Show")


func _on_Panel_mouse_exited() -> void:
	if not used:
		animation_player.play_backwards("Show")


func _on_Panel_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("select") and not used:
		used = true
		emit_signal("used", data)
		animation_player.play("Use")
