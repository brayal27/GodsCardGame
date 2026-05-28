extends Node2D

const CARD_SCENE_PATH = "res://Escenas/card.tscn"
const speed = 0.2
const MAX_HAND_SIZE = 4

var player_deck = ["Thor", "Thor", "Odin", "Hela", "Thor", "Thor", "Odin", "Hela"]
var characters_reference


func _ready() -> void:
	player_deck.shuffle()
	characters_reference = preload("res://Scripts/Characters.gd")
	update_deck_counter()
	
	# Mano inicial de 4 cartas
	draw_until_hand_full()


func draw_until_hand_full():
	var player_hand = $"../PlayerHand".player_hand
	
	while player_hand.size() < MAX_HAND_SIZE and not player_deck.is_empty():
		draw_card()
	
	update_deck_visual_state()


func draw_card():
	if player_deck.is_empty():
		print("No quedan cartas en el mazo")
		return
	
	var card_drawn_name = player_deck[0]
	player_deck.erase(card_drawn_name)
	
	update_deck_counter()
	
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	
	new_card.get_node("Nombre").text = characters_reference.CHARACTERS[card_drawn_name][0]
	new_card.get_node("Ataque").text = str(characters_reference.CHARACTERS[card_drawn_name][1])
	new_card.get_node("Vida").text = str(characters_reference.CHARACTERS[card_drawn_name][2])
	
	new_card.attack = characters_reference.CHARACTERS[card_drawn_name][1]
	new_card.health = characters_reference.CHARACTERS[card_drawn_name][2]
	
	$"../CardManager".add_child(new_card)
	new_card.name = "Card"
	$"../PlayerHand".add_card_to_hand(new_card, speed)
	
	if new_card.has_node("AnimationPlayer"):
		new_card.get_node("AnimationPlayer").play("Flip")


func update_deck_counter():
	$RichTextLabel.text = str(player_deck.size())


func update_deck_visual_state():
	if player_deck.is_empty():
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		$RichTextLabel.visible = false
	else:
		# Ya no queremos que el jugador robe manualmente clicando el mazo
		# El robo será automático al final del turno.
		$Area2D/CollisionShape2D.disabled = true
