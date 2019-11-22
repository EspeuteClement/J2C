tool
extends Node2D

enum Dir {
	Top,
	Right,
	Down,
	Left,
	Count
};

export(Array, int) var values : Array = [0,0,0,0] setget set_values;

var held = false;

onready var Labels = [$Top, $Right, $Down, $Left];

func set_values(new_values : Array):
	if (new_values.size() != 4):
		return;
	values = new_values;
	update_card_numbers();
	
func update_card_numbers():
	if (!Labels || Labels.size() != 4):
		return
	for direction in range(0, Dir.Count):
		Labels[direction].text = str(values[direction]);
	update();
	

func _ready() -> void:
	update_card_numbers();
	pass # Replace with function body.

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			held = true;
			get_tree().set_input_as_handled()
			print("Inpoute");
		elif event.button_index == BUTTON_LEFT and !event.pressed:
			held = false;

