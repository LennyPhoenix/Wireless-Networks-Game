extends Node2D

var deck := []

export(Array, Resource) var cards := []

onready var screen_cover: Panel = $CanvasLayer/ScreenCover
onready var p1: Grid = $Player1
onready var p2: Grid = $Player2
onready var title: Label = $CanvasLayer/Title


func restock_deck() -> void:
	var card_list := cards.duplicate(false)
	randomize()
	card_list.shuffle()
	deck.append_array(card_list)


func get_card() -> CardData:
	if len(deck) == 0:
		restock_deck()

	return deck.pop_front()


func _ready() -> void:
	pregame()


func pregame() -> void:
	title.text = "Pregame"

	screen_cover.cover(screen_cover.Player.PLAYER1)
	yield(screen_cover, "closed")
	p1.pregame()
	yield(p1, "pregame_complete")

	screen_cover.cover(screen_cover.Player.PLAYER2)
	yield(screen_cover, "closed")
	p2.pregame()
	yield(p2, "pregame_complete")

	attack()


func attack() -> void:
	title.text = "Attack Phase"

	screen_cover.cover(screen_cover.Player.PLAYER1)
	yield(screen_cover, "closed")
	p2.attack()
	yield(p2, "attack_complete")

	screen_cover.cover(screen_cover.Player.PLAYER2)
	yield(screen_cover, "closed")
	p1.attack()
	yield(p1, "attack_complete")

	defend()


func defend() -> void:
	title.text = "Defence Phase"

	screen_cover.cover(screen_cover.Player.PLAYER1)
	yield(screen_cover, "closed")
	p1.defend()
	yield(p1, "defence_complete")

	screen_cover.cover(screen_cover.Player.PLAYER2)
	yield(screen_cover, "closed")
	p2.defend()
	yield(p2, "defence_complete")

	attack()


func _on_Player1_wap_discovered() -> void:
	title.text = "Player 2 Wins!"


func _on_Player2_wap_discovered() -> void:
	title.text = "Player 1 Wins!"


func _on_Player1_request_card() -> void:
	p1.add_card(get_card())


func _on_Player2_request_card() -> void:
	p2.add_card(get_card())
