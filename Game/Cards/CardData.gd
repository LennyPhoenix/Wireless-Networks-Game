class_name CardData
extends Resource

enum Type {
	ATTACK,
	DEFENCE,
}

export var name := ""
export var image: Texture = preload("res://icon.png")
export(String, MULTILINE) var description := ""
export(Type) var type
