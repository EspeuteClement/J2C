tool
extends Node2D

enum Dir {
	Right,
	Top,
	Left,	
	Down,
	Count
};


# Editor stuff ==============
export var card_name : String setget set_name;
export(String, MULTILINE) var activation_text : String setget set_activation_text;
export(String, MULTILINE) var effect_text : String setget set_effect_text;
export(Array, int) var values : Array = [0,0,0,0] setget set_values;

onready var Labels = [$Right, $Top, $Left , $Down];

onready var CardName = $CardName;
onready var ActivationText = $ActivationText;
onready var EffectText = $EffectText;


func set_values(new_values : Array):
	if (new_values.size() != 4):
		return;
	values = new_values;
	update_card_numbers();
	
func set_name(new_value : String) :
	card_name = new_value;
	update_card_numbers();

func set_activation_text(new_value : String) :
	activation_text = new_value;
	update_card_numbers();

func set_effect_text(new_value : String) :
	effect_text = new_value;
	update_card_numbers();
	
func update_card_numbers():
	if (!Labels || Labels.size() != 4):
		return
	for direction in range(0, Dir.Count):
		Labels[direction].text = str(values[direction]);
		
	if (CardName):
		CardName.text = card_name;
		
	if (ActivationText):
		ActivationText.bbcode_text = activation_text;
	if (EffectText):
		EffectText.bbcode_text = effect_text;
	update();
	

# Game stuff

var choucroute = false;
var hovered = false;

func _ready() -> void:
	update_card_numbers();
	pass # Replace with function body.
	
func _physics_process(delta: float) -> void:
	if (choucroute == true):
		position = get_global_mouse_position();
		modulate = Color.red;
	elif (hovered == true):
		modulate = Color.gray;
	else:
		modulate = Color.white;

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT && event.pressed && hovered:
			choucroute = true;
			print("Pressed %s" % str(self))
			get_tree().set_input_as_handled();
		elif event.button_index == BUTTON_LEFT && event.pressed == false && choucroute:
			choucroute = false;
			print("Unpressed %s" % str(self))
			get_tree().set_input_as_handled();



func _on_Node2D_mouse_entered() -> void:
	hovered = true;


func _on_Node2D_mouse_exited() -> void:
	hovered = false;
