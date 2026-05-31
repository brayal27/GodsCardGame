extends Node2D

var attack := 0
var health := 0
var abilities := {}
var faction := ""

var card_owner := ""
var current_slot = null
var is_on_board := false
var is_face_down := false

var starting_position


func set_face_up():
	is_face_down = false
	
	if has_node("CardImage"):
		$CardImage.visible = true
	
	if has_node("Back"):
		$Back.visible = false
	
	if has_node("Might"):
		$Might.visible = true
	
	if has_node("Vida"):
		$Vida.visible = true
	
	if has_node("Nombre"):
		$Nombre.visible = true
	
	if has_node("AbilityContainer"):
		$AbilityContainer.visible = true
		
	if has_node("CharacterImage"):
		$CharacterImage.visible = true


func set_face_down():
	is_face_down = true
	
	if has_node("CardImage"):
		$CardImage.visible = false
	
	if has_node("Back"):
		$Back.visible = true
	
	if has_node("Might"):
		$Might.visible = false
	
	if has_node("Vida"):
		$Vida.visible = false
	
	if has_node("Nombre"):
		$Nombre.visible = false
	
	if has_node("AbilityContainer"):
		$AbilityContainer.visible = false
	
	if has_node("CharacterImage"):
		$CharacterImage.visible = false

func reveal_card():
	set_face_up()


func has_ability(ability_name: String) -> bool:
	return abilities.has(ability_name)


func get_ability_value(ability_name: String, default_value = 0):
	if not abilities.has(ability_name):
		return default_value

	return abilities[ability_name]
