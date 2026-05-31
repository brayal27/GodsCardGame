extends Node2D

var card_in_slot = false
var current_card = null
var slot_owner = ""


func can_place_card() -> bool:
	return not card_in_slot


func place_card(card, face_down: bool, new_owner: String) -> bool:
	if card_in_slot:
		print("Este slot ya está ocupado")
		return false
	
	card_in_slot = true
	current_card = card
	slot_owner = new_owner
	
	card.is_on_board = true
	card.current_slot = self
	card.card_owner = new_owner
	
	if face_down:
		card.set_face_down()
	else:
		card.set_face_up()
	
	return true


func remove_card():
	if current_card != null:
		current_card.is_on_board = false
		current_card.current_slot = null
		current_card.card_owner = ""
	
	card_in_slot = false
	current_card = null
	slot_owner = ""


func has_enemy_card(other_owner: String) -> bool:
	if not card_in_slot:
		return false
	
	return slot_owner != other_owner


func has_player_card() -> bool:
	return card_in_slot and slot_owner == "player"


func has_opponent_card() -> bool:
	return card_in_slot and slot_owner == "opponent"
