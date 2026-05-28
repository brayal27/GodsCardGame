extends Node2D

var attack := 0
var health := 0

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
	
	if has_node("Ataque"):
		$Ataque.visible = true
	
	if has_node("Vida"):
		$Vida.visible = true
	
	if has_node("Nombre"):
		$Nombre.visible = true


func set_face_down():
	is_face_down = true
	
	if has_node("CardImage"):
		$CardImage.visible = false
	
	if has_node("Back"):
		$Back.visible = true
	
	if has_node("Ataque"):
		$Ataque.visible = false
	
	if has_node("Vida"):
		$Vida.visible = false
	
	if has_node("Nombre"):
		$Nombre.visible = false


func reveal_card():
	set_face_up()
