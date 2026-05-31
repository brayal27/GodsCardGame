extends Node2D

signal hovered
signal hovered_off

var starting_position

var is_face_down = false
var is_on_board = false

var card_owner = ""
var current_slot = null
var attack = 0
var health = 0
var abilities = {}
var faction = ""

var card_front 
var card_back


func _ready() -> void:
	get_parent().connect_card_signals(self)
	set_face_up()


func set_face_up():
	is_face_down = false
	
	card_front = $CardImage
	card_back = $Back
	
	card_front.visible = true
	card_back.visible = false
	
	if has_node("CharacterImage"):
		$CharacterImage.visible = true
	
	if has_node("Might"):
		$Might.visible = true
	
	if has_node("Vida"):
		$Vida.visible = true
	
	if has_node("Nombre"):
		$Nombre.visible = true
	
	if has_node("AbilityContainer"):
		$AbilityContainer.visible = true
	
	print("Carta boca arriba")


func set_face_down():
	is_face_down = true
	
	card_front = $CardImage
	card_back = $Back
	
	card_front.visible = false
	card_back.visible = true
	
	if has_node("CharacterImage"):
		$CharacterImage.visible = false
	
	if has_node("Might"):
		$Might.visible = false
	
	if has_node("Vida"):
		$Vida.visible = false
	
	if has_node("Nombre"):
		$Nombre.visible = false
	
	if has_node("AbilityContainer"):
		$AbilityContainer.visible = false
	
	card_back.scale = Vector2(0.23, 0.26)
	
	print("Carta boca abajo")
	

func has_ability(ability_name: String) -> bool:
	return abilities.has(ability_name)


func get_ability_value(ability_name: String, default_value = 0):
	if not abilities.has(ability_name):
		return default_value
	
	return abilities[ability_name]

func reveal_card():
	set_face_up()


func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)


func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)
