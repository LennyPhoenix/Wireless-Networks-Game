class_name Grid
extends Node2D

signal cell_selected(x, y)
signal building_placed()
signal pregame_complete()
signal attack_complete()
signal defence_complete()
signal wap_discovered()
signal request_card()

var cells := []
var buildings := []

var attacked := false
var defended := false
var wna_discovered := false
var hint_level := 1

export var building_scene: PackedScene
export var cell_scene: PackedScene
export var card_scene: PackedScene
export var hint_scene: PackedScene
export(Array, Resource) var devices := []

onready var cell_group: Node2D = $Cells
onready var building_group: Node2D = $Buildings
onready var end_turn: Button = $CanvasLayer/EndTurn
onready var dialogue_box: Control = $CanvasLayer/DialogueBox
onready var defence_ui: Control = $CanvasLayer/DefenceUI
onready var draw: Button = $CanvasLayer/DefenceUI/Draw
onready var card_group: HBoxContainer = $CanvasLayer/DefenceUI/Cards
onready var offense_ui: Control = $CanvasLayer/OffenseUI
onready var hint_group: HBoxContainer = $CanvasLayer/OffenseUI/Hints
onready var new_game: Button = $CanvasLayer/NewGame


func _ready() -> void:
	build_grid()
	visible = false


func _on_Card_used(data: CardData) -> void:
	# TODO
	pass


func pregame() -> void:
	visible = true
	if Constants.first_game:
		dialogue_box.display(dialogue_box.DialogueTypes.WAPs)
		yield(dialogue_box, "read")
	place_building(preload("res://Game/Buildings/WAP.tres"))
	yield(self, "building_placed")

	if Constants.first_game:
		dialogue_box.display(dialogue_box.DialogueTypes.WNAs)
		yield(dialogue_box, "read")
	for data in devices:
		place_building(data)
		yield(self, "building_placed")

	end_turn.visible = true
	yield(end_turn, "button_up")
	end_turn.visible = false

	visible = false
	emit_signal("pregame_complete")


func add_card(data: CardData) -> void:
	var card: Card = card_scene.instance()
	card_group.add_child(card)
	card.data = data
	var _result = card.connect("used", self, "_on_Card_used")


func add_hint(data: HintData) -> void:
	var hint: Hint = hint_scene.instance()
	hint_group.add_child(hint)
	hint.data = data


func defend() -> void:
	visible = true
	defence_ui.visible = true
	draw.visible = true

	if not defended and Constants.first_game:
		dialogue_box.display(dialogue_box.DialogueTypes.DEFENCE)
		yield(dialogue_box, "read")
		defended = true

	yield(draw, "button_up")
	draw.visible = false
	emit_signal("request_card")

	end_turn.visible = true
	yield(end_turn, "button_up")
	end_turn.visible = false

	defence_ui.visible = false
	visible = false
	emit_signal("defence_complete")


func angle_to_comp(direction: float) -> String:
	var comp_dir: String
	if 22.5 > direction and direction >= -22.5:
		comp_dir = "East"
	elif 67.5 > direction and direction >= 22.5:
		comp_dir = "South-East"
	elif 112.5 > direction and direction >= 67.5:
		comp_dir = "South"
	elif 157.5 > direction and direction >= 112.5:
		comp_dir = "South-West"
	elif direction >= 157.5 or direction < -157.5:
		comp_dir = "West"
	elif -157.5 <= direction and direction < -112.5:
		comp_dir = "North-West"
	elif -112.5 <= direction and direction < -67.5:
		comp_dir = "North"
	elif -67.5 <= direction and direction < -22.5:
		comp_dir = "North-East"
	return comp_dir


func construct_hint(building: Building) -> void:
	var hint := HintData.new()
	hint.tier = hint_level
	match hint_level:
		HintData.HintTier.TIER1:
			var shortest := 0
			for start in building.get_positions():
				for i in range(Constants.GRID_SIZE):
					for j in range(Constants.GRID_SIZE):
						var cell = cells[i][j]
						if not cell.checked and cell.state == Cell.State.WNA:
							var distance = int(ceil((Vector2(i, j) - start).length()))
							if shortest == 0:
								shortest = distance
							else:
								shortest = min(shortest, distance)
			hint.description = "There is a WNA device %d cell(s) away from the %s." % [shortest, building.data.name]
		HintData.HintTier.TIER2:
			var shortest := 0
			var selected: Cell
			for start in building.get_positions():
				for i in range(Constants.GRID_SIZE):
					for j in range(Constants.GRID_SIZE):
						var cell = cells[i][j]
						if not cell.checked and cell.state == Cell.State.WNA:
							var distance = int(ceil((Vector2(i, j) - start).length()))
							if shortest == 0 or shortest > distance:
								shortest = distance
								selected = cell
			var direction = rad2deg(selected.global_position.angle_to_point(building.global_position))
			var comp = angle_to_comp(direction)
			hint.description = "There is a WNA device %s from the %s." % [comp, building.data.name]
		HintData.HintTier.TIER3:
			var shortest := 0
			for start in building.get_positions():
				for i in range(Constants.GRID_SIZE):
					for j in range(Constants.GRID_SIZE):
						var cell = cells[i][j]
						if not cell.checked and cell.state == Cell.State.WAP:
							var distance = int(ceil((Vector2(i, j) - start).length()))
							if shortest == 0:
								shortest = distance
							else:
								shortest = min(shortest, distance)
			hint.description = "The WAP device is %d cell(s) away from the %s." % [shortest, building.data.name]
		HintData.HintTier.TIER4:
			var shortest := 0
			var selected: Cell
			for start in building.get_positions():
				for i in range(Constants.GRID_SIZE):
					for j in range(Constants.GRID_SIZE):
						var cell = cells[i][j]
						if not cell.checked and cell.state == Cell.State.WAP:
							var distance = int(ceil((Vector2(i, j) - start).length()))
							if shortest == 0 or shortest > distance:
								shortest = distance
								selected = cell
			var direction = rad2deg(selected.global_position.angle_to_point(building.global_position))
			var comp = angle_to_comp(direction)
			hint.description = "The WAP device is %s from the %s." % [comp, building.data.name]
		HintData.HintTier.TIER5:
			for i in range(Constants.GRID_SIZE):
				for j in range(Constants.GRID_SIZE):
					var cell = cells[i][j]
					if cell.state == Cell.State.WAP:
						hint.description = "The WAP has an X coordinate of %d (starting from 1 on the left)." % (i+1)
						break
	add_hint(hint)
	hint_level += 1
	if hint_level > HintData.HintTier.TIER5:
		hint_level = HintData.HintTier.TIER5


func attack() -> void:
	for building in buildings:
		building.visible = building.discovered
	visible = true
	offense_ui.visible = true

	if not attacked and Constants.first_game:
		dialogue_box.display(dialogue_box.DialogueTypes.ATTACK)
		yield(dialogue_box, "read")
		attacked = true

	while true:
		var pos = yield(self, "cell_selected")
		var cell = cells[pos[0]][pos[1]]
		if cell.checked:
			continue
		else:
			cell.checked = true
			for building in buildings:
				var positions = building.get_positions()
				if Vector2(pos[0], pos[1]) in positions:
					building.discovered = true
					building.visible = true
					for position in positions:
						cells[position.x][position.y].checked = true

					if building.data.type == BuildingData.Type.WNA:
						if not wna_discovered and Constants.first_game:
							dialogue_box.display(dialogue_box.DialogueTypes.WNA_DISCOVERED)
							yield(dialogue_box, "read")
							wna_discovered = true
						construct_hint(building)
					else:
						if Constants.first_game:
							dialogue_box.display(dialogue_box.DialogueTypes.WAP_DISCOVERED)
							yield(dialogue_box, "read")
							Constants.first_game = false
						new_game.visible = true
						emit_signal("wap_discovered")
						return
			break

	end_turn.visible = true
	yield(end_turn, "button_up")
	end_turn.visible = false

	offense_ui.visible = false
	visible = false
	for building in buildings:
		building.visible = true
	emit_signal("attack_complete")


func place_building(data: BuildingData) -> void:
	var current_building = building_scene.instance()
	building_group.add_child(current_building)
	current_building.data = data

	var valid = false
	while not valid:
		current_building.follow()
		yield(current_building, "placed")
		valid = true
		for coords in current_building.get_positions():
			if cells[coords.x][coords.y].state != Cell.State.EMPTY:
				valid = false

	buildings.push_back(current_building)
	for coords in current_building.get_positions():
		if current_building.data.type == BuildingData.Type.WAP:
			cells[coords.x][coords.y].state = Cell.State.WAP
		else:
			cells[coords.x][coords.y].state = Cell.State.WNA
	emit_signal("building_placed")


func build_grid() -> void:
	for column in cells:
		for cell in column:
			cell.queue_free()

	cells = []

	for x in range(Constants.GRID_SIZE):
		cells.push_back([])
		for y in range(Constants.GRID_SIZE):
			var cell: Cell = cell_scene.instance()
			cell.x = x
			cell.y = y
			var _result = cell.connect("selected", self, "_on_Cell_selected")

			cell_group.add_child(cell)
			cells[x].push_back(cell)


func _on_Cell_selected(x: int, y: int) -> void:
	emit_signal("cell_selected", x, y)


func _on_NewGame_button_up() -> void:
	get_tree().change_scene("res://Game/Game.tscn")
