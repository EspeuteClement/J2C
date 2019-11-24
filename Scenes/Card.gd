tool
extends Node2D

class_name Card

enum Dir {
	Right,
	Top,
	Left,	
	Down,
	Count
};

enum CardType {
	OFFENSE,
	DEFENSE
};

var animation_names = ["off", "def"];

enum CardAttribute {
	NEUTRAL,
	FIRE,
	ICE,
	IRON,
	VOLT
};

const attribute_animation_name = {
	CardAttribute.NEUTRAL: "neutral",
	CardAttribute.FIRE: "fire",
	CardAttribute.ICE: "ice",
	CardAttribute.IRON: "iron",
	CardAttribute.VOLT: "volt",
};

enum CardCondition {
	ACTIVATION,
	PERSISTENT,
	SWIFT,	
};

const condition_animation_name = {
	CardCondition.ACTIVATION: "activation",
	CardCondition.PERSISTENT: "persistent",
	CardCondition.SWIFT: "swift",
};

# Editor stuff ==============
export var card_name : String setget set_name;
export(String, MULTILINE) var activation_text : String setget set_activation_text;
export(String, MULTILINE) var effect_text : String setget set_effect_text;
export(Array, int) var values : Array = [0,0,0,0] setget set_values;
export(String) var card_damage setget set_card_damage;


export(CardType) var card_type setget set_card_type;
export(CardAttribute) var card_attribute setget set_card_attribute;
export(CardCondition) var card_condition setget set_card_condition;


onready var Labels = [$Right, $Top, $Left , $Down];
onready var LabelsNotch = [$RightNotchNumber, $TopNotchNumber, $LeftNotchNumber , $DownNotchNumber];


onready var CardName = $CardName;
onready var ActivationText = $ActivationText;
onready var EffectText = $EffectText;

onready var CardBorders = [$RightNotch, $TopNotch, $LeftNotch, $DownNotch, $CardTemplate];

func set_card_damage(new_value : String):
	card_damage = new_value;
	update_card_numbers();

func set_card_condition(new_value : int):
	card_condition = new_value;
	update_card_numbers();

func set_card_type(new_value : int):
	card_type = new_value;
	update_card_numbers();

func set_card_attribute(new_value : int):
	card_attribute = new_value;
	update_card_numbers();

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
		if (values[direction] >= 0):
			Labels[direction].text = str(values[direction]);
			LabelsNotch[direction].text = str(values[direction]);
		else:
			CardBorders[direction].visible = false;
			Labels[direction].visible = false;
			LabelsNotch[direction].visible = false;
	
	if (CardName):
		CardName.text = card_name;
		
	if (ActivationText):
		ActivationText.bbcode_text = "[center]%s[/center]" % activation_text;
	if (EffectText):
		EffectText.bbcode_text = "[center]%s[/center]" % effect_text;
	
	if (CardBorders.size() != 0):
		for border in CardBorders:
			border.play(animation_names[card_type]);
			
	if($Attribute):
		$Attribute.play(attribute_animation_name[card_attribute]);
	
	if($Condition):
		$Condition.play(condition_animation_name[card_condition]);
		
	if($DamageScale/DamageValue):
		$DamageScale/DamageValue.text = card_damage;
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
