class_name BuildingData
extends Resource

enum Type {
	WAP,
	WNA,
}

export var name := ""
export var width := 1
export var height := 1
export var image: Texture
export(Type) var type
