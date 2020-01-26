extends Node2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

export var big : bool setget set_is_big;
func set_is_big(new_value : bool):
	big = new_value;
	
export var condition_anim : String setget set_condition;
func set_condition(new_value : String):
	condition_anim = new_value;
	$Condition.play(condition_anim);
	
export var activation_text : String setget set_activation_text;
func set_activation_text(new_value : String):
	activation_text = new_value;
	$ActivationText.text = activation_text;

export var effect_text : String setget set_effect_text;
func set_effect_text(new_value : String):
	effect_text = new_value;
	$EffectText.text = effect_text;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
#	Workaround for godot wonky duplication
	set_effect_text(effect_text);
	set_activation_text(activation_text);
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
