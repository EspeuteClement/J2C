tool
extends Node2D

class_name CardNew

var id : int;
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
	VOLT,
	DUAL,
	GLASS,
	EARTH,
	LIFE,
	STAR,
	NECRO,
	HOLY,
	WIND
};

const attribute_animation_name = {
	CardAttribute.NEUTRAL: "neutral",
	CardAttribute.FIRE: "fire",
	CardAttribute.ICE: "ice",
	CardAttribute.IRON: "iron",
	CardAttribute.VOLT: "volt",
	CardAttribute.DUAL: "dual",
	CardAttribute.GLASS: "glass",
	CardAttribute.EARTH: "earth",
	CardAttribute.LIFE: "life",
	CardAttribute.STAR: "star",
	CardAttribute.NECRO: "necro",
	CardAttribute.HOLY: "holy",
	CardAttribute.WIND: "wind",
	
};

enum CardCondition {
	ACTIVATION,
	PERSISTENT,
	SWIFT,
	SLOW,
	ARTEFACT,
	SPECIAL
};

const condition_animation_name = {
	CardCondition.ACTIVATION: "activation",
	CardCondition.PERSISTENT: "persistent",
	CardCondition.SWIFT: "swift",
	CardCondition.SLOW: "slow",
	CardCondition.ARTEFACT: "artefact",
	CardCondition.SPECIAL: "special",
};

# Editor stuff ==============
export var card_name : String;
export var has_two_effects : bool = false;

var card_effects = Array();

#export(Array, int) 
var values : Array = [0,0,0,0];
export var card_value = 0;
export var card_id = 0;
export var notch_flags : int = 0;

export var card_attribute = "";


export var card_x = 0;
export var card_y = 0;
export var card_deck_id = 0;
export var card_export_id = 0;

onready var CardName = $CardName;

onready var EffectWidgets = [
	{
		"widget": $Effect_1
#		"activation" : $Effect_1/ActivationText,
#		"effect" : $Effect_1/EffectText,
#		"condition" : $Effect_1/Condition
	},
	{
#		"activation" : $Effect_2/ActivationText,
#		"effect" : $Effect_2/EffectText,
#		"condition" : $Effect_2/Condition
		"widget": $Effect_2
	},
	{
		"activation" : $Effect_Solo/ActivationText_Solo,
		"effect" : $Effect_Solo/EffectText_Solo,
		"condition" : $Effect_Solo/Condition_Solo
	}
];



onready var CardBorders = [$RightNotch, $TopNotch, $LeftNotch, $DownNotch, $CardTemplate];

func update_card():
	for direction in range(0, Dir.Count):
		if (values[direction] >= 0):
			pass
		else:
			CardBorders[direction].visible = false;
	
	if (CardName):
		CardName.text = card_name;
		var base_size = 172;
		yield(get_tree(), "idle_frame");
		CardName.rect_scale.x = min(1.0,base_size/CardName.rect_size.x);
	else:
		printerr("CANT FIND CARD NAME");
	
	var start = 0;
	var end = 1;
	if (!has_two_effects):
		start = 2;
		end = 2;

	$Effect_Solo.visible = !has_two_effects;
	$Effect_1.visible = has_two_effects;
	$Effect_2.visible = has_two_effects;
	
	if (!has_two_effects):
		for i in range(start, end+1):
			var item = i if has_two_effects else 0
			EffectWidgets[i].activation.bbcode_text = card_effects[item].activation;
			EffectWidgets[i].effect.bbcode_text = card_effects[item].effect;
			var cond = card_effects[item].condition;
			if (cond >=0):
				EffectWidgets[i].condition.play(condition_animation_name[card_effects[item].condition]);
	else:
		for i in range(start, end+1):
			var item = i if has_two_effects else 0
			EffectWidgets[i].widget.activation_text = card_effects[item].activation;
			EffectWidgets[i].widget.effect_text = card_effects[item].effect;
			var cond = card_effects[item].condition;
			if (cond >=0):
				EffectWidgets[i].widget.condition_anim = condition_animation_name[card_effects[item].condition];
		
			
	if($Attribute):
		$Attribute.play(attribute_animation_name[card_attribute]);
		
	if($DamageScale/DamageValue):
		$DamageScale/DamageValue.text = "%d" % [card_value];
	update();

# Game stuff

func _ready() -> void:
	var i = 0;
	pass # Replace with function body.
	
func _physics_process(delta: float) -> void:
	pass
