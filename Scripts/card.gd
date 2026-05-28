extends Node2D

signal hovered
signal hovered_off

var starting_position

var is_face_down := false
var is_on_board := false

var card_owner := ""
var current_slot = null
var attack := 0
var health := 0

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
	
	$Ataque.visible = true
	$Vida.visible = true
	$Nombre.visible = true
	
	print("Carta boca arriba")


func set_face_down():
	is_face_down = true
	
	card_front = $CardImage
	card_back = $Back
	
	card_front.visible = false
	card_back.visible = true
	$Ataque.visible = false
	$Vida.visible = false
	$Nombre.visible = false
	card_back.scale = Vector2(0.23, 0.26)
	
	print("Carta boca abajo")


func reveal_card():
	set_face_up()


func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)


func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)
