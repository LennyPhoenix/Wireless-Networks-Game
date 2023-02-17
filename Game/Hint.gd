class_name Hint
extends Control

var data: HintData setget set_data

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var title: Label = $"%Title"
onready var description: Label = $"%Description"


func set_data(new_data: HintData) -> void:
	data = new_data
	title.text = "Hint (%d)" % data.tier
	description.text = data.description


func _on_Panel_mouse_entered() -> void:
	animation_player.play("Show")


func _on_Panel_mouse_exited() -> void:
	animation_player.play_backwards("Show")
