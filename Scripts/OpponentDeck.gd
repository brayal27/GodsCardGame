extends Node2D

const CARD_SCENE_PATH = "res://Escenas/EnemyCard.tscn"
const speed = 0.2
const MAX_HAND_SIZE = 4

var opponent_deck =["Thor", "Thor", "Odin","Hela","Thor", "Thor", "Odin","Hela"]
var characters_reference

var drawn_card_this_turn = false


func _ready() -> void:
	opponent_deck.shuffle()
	$RichTextLabel2.text = str(opponent_deck.size())
	characters_reference = preload("res://Scripts/Characters.gd")

func draw_until_hand_full():
	var enemy_hand = $"../EnemyHand".enemy_hand
	
	while enemy_hand.size() < MAX_HAND_SIZE and not opponent_deck.is_empty():
		robar_carta()

func robar_carta():
	var card_drawn_name = opponent_deck[0]
	opponent_deck.erase(card_drawn_name)
	
	# Si no hay más cartas en el deck, lo hago invisible
	if opponent_deck.size() == 0:
		if has_node("Deck/Sprite2D"):
			$Deck/Sprite2D.visible = false
		
		if has_node("Deck/RichTextLabel"):
			$Deck/RichTextLabel.visible = false
	
	# Actualizar contador visual
	$RichTextLabel2.text = str(opponent_deck.size())
	
	# Instanciar nueva carta
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	
	# Asignar datos a la carta
	new_card.get_node("Nombre").text = characters_reference.CHARACTERS[card_drawn_name][0]
	new_card.attack = characters_reference.CHARACTERS[card_drawn_name][1]
	new_card.health = characters_reference.CHARACTERS[card_drawn_name][2]
	new_card.get_node("Ataque").text = str(characters_reference.CHARACTERS[card_drawn_name][1])
	new_card.get_node("Vida").text = str(characters_reference.CHARACTERS[card_drawn_name][2])
	
	# Añadir al juego
	$"../CardManager".add_child(new_card)
	new_card.name = "Card"
	$"../EnemyHand".add_card_to_hand(new_card, speed)
