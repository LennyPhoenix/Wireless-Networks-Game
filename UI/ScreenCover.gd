tool
extends Panel

signal closed()

enum Player {
	PLAYER1,
	PLAYER2,
}

onready var title := $"%PlayerTitle"


func _ready() -> void:
	visible = false


func cover(player: int) -> void:
	match player:
		Player.PLAYER1:
			title.text = "Player 1's Turn!"
		Player.PLAYER2:
			title.text = "Player 2's Turn!"
	visible = true


func _on_Button_button_up() -> void:
	visible = false
	emit_signal("closed")
