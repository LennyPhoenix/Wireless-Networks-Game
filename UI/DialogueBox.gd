extends Control

signal read()

enum DialogueTypes {
	WAPs,
	WNAs,
	ATTACK,
	DEFENCE,
	WNA_DISCOVERED,
	WAP_DISCOVERED,
}

onready var button: Button = $Panel/MarginContainer/VBoxContainer/Button
onready var dialogue: Label = $Panel/MarginContainer/VBoxContainer/Dialogue


func _ready() -> void:
	visible = false


func display(type: int) -> void:
	var text: String
	match type:
		DialogueTypes.WAPs:
			text = "A Wireless Network Adapter (or WAP for short) is the central node that all your wireless traffic must go through. In a home WiFi network, this is your router (this is what your opponent must hack to win). Begin your network by placing your router somewhere on the grid."
		DialogueTypes.WNAs:
			text = "Next, we need some devices with Wireless Network Adapters (WNAs) to connect to our network, place down all the given devices to finish constructing your wireless network."
		DialogueTypes.ATTACK:
			text = "This is the attack phase, you may pick a single tile to attempt to hack. If you are lucky, you might discover a WNA device!"
		DialogueTypes.DEFENCE:
			text = "This is the defence phase, you must draw a card, and then may use any number of cards in your hand before ending your turn. (Didn't have time to make these work sadly)"
		DialogueTypes.WNA_DISCOVERED:
			text = "You have discovered a device with a WNA! A clue has been added to your hand."
		DialogueTypes.WAP_DISCOVERED:
			text = "You hacked the opponents WAP! Congratulations, you win!"
	dialogue.text = text

	visible = true
	yield(button, "button_up")
	visible = false
	emit_signal("read")
