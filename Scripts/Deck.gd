extends Node2D

const CARD_SCENE_PATH = "res://Escenas/card.tscn"
const Characters = preload("res://Scripts/Characters.gd")
const speed = 0.2
const MAX_HAND_SIZE = 4

const NORDIC_FRONT_TEXTURE = preload("res://Assets/Carta.jpg")
const NORDIC_BACK_TEXTURE = preload("res://Assets/Faccion nordica.jpg")

const GREEK_FRONT_TEXTURE = preload("res://Assets/Faccion_Griega_anverso.jpg")
const GREEK_BACK_TEXTURE = preload("res://Assets/Faccion_Griega.jpg")

var player_faction 
var player_deck := []


func _ready() -> void:
	randomize()
	update_deck_counter()
	update_deck_visual_state()

func setup_deck(faction_name: String) -> void:
	player_faction = faction_name
	player_deck.clear()
	player_deck = Characters.create_deck_from_faction(player_faction)
	update_deck_counter()
	update_deck_visual_state()
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

	if not Characters.CHARACTERS.has(card_drawn_name):
		print("No existe el personaje en Characters.gd:", card_drawn_name)
		update_deck_counter()
		return

	update_deck_counter()

	var character_data = Characters.CHARACTERS[card_drawn_name]
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()

	new_card.get_node("Nombre").text = character_data["name"]
	new_card.get_node("Might/Ataque").text = str(character_data["attack"])
	new_card.get_node("Vida/TextoVida").text = str(character_data["health"])

	new_card.attack = character_data["attack"]
	new_card.health = character_data["health"]
	new_card.faction = character_data.get("faction", "")
	new_card.abilities = character_data.get("abilities", {}).duplicate(true)
	
	apply_character_image(new_card, character_data)
	
	apply_faction_textures(new_card, new_card.faction)
	
	update_card_ability_labels(new_card, new_card.abilities)

	$"../CardManager".add_child(new_card)
	new_card.name = "Card"
	$"../PlayerHand".add_card_to_hand(new_card, speed)

	if new_card.has_node("AnimationPlayer"):
		new_card.get_node("AnimationPlayer").play("Flip")

func update_card_ability_labels(card, abilities: Dictionary) -> void:
	var ability_label_1 = card.get_node_or_null("AbilityContainer/AbilityLabel")
	var ability_label_2 = card.get_node_or_null("AbilityContainer/AbilityLabel2")
	
	if ability_label_1 != null:
		ability_label_1.text = ""
	
	if ability_label_2 != null:
		ability_label_2.text = ""
	
	var labels = [
		ability_label_1,
		ability_label_2
	]
	
	var index := 0
	
	for ability_name in abilities.keys():
		if index >= labels.size():
			break
		
		if labels[index] == null:
			index += 1
			continue
		
		var ability_value = abilities[ability_name]
		var formatted_name = format_ability_name(str(ability_name))
		
		labels[index].text = formatted_name + " " + str(ability_value)
		labels[index].visible = true
		
		index += 1

func format_ability_name(ability_name: String) -> String:
	match ability_name:
		"guard":
			return "Guardia"
		"frost":
			return "Frío"
		"support":
			return "Apoyo"
		"weaken":
			return "Debilitar"
		"isolated":
			return "Aislado"
		"turn_bonus":
			return "Impulso"
		_:
			return ability_name.capitalize()

func update_deck_counter():
	$RichTextLabel.text = str(player_deck.size())


func update_deck_visual_state():
	if player_deck.is_empty():
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		$RichTextLabel.visible = false
	else:
		$Area2D/CollisionShape2D.disabled = false
		$Sprite2D.visible = true
		$RichTextLabel.visible = true

func apply_faction_textures(card, faction_name: String) -> void:
	var card_image = card.get_node_or_null("CardImage")
	var card_back = card.get_node_or_null("Back")

	if card_image == null:
		push_warning("La carta no tiene nodo CardImage")
		return

	if card_back == null:
		push_warning("La carta no tiene nodo Back")
		return

	match faction_name:
		"nordicos":
			card_image.texture = NORDIC_FRONT_TEXTURE
			card_back.texture = NORDIC_BACK_TEXTURE

		"griegos":
			card_image.texture = GREEK_FRONT_TEXTURE
			card_back.texture = GREEK_BACK_TEXTURE

		_:
			push_warning("Facción desconocida en carta del jugador: " + faction_name)
			card_image.texture = NORDIC_FRONT_TEXTURE
			card_back.texture = NORDIC_BACK_TEXTURE
func apply_character_image(card, character_data: Dictionary) -> void:
	var character_image = card.get_node_or_null("CharacterImage")

	if character_image == null:
		print("ERROR: No existe CharacterImage en la carta")
		return

	var image_path = character_data.get("image", "")

	print("Intentando cargar imagen:", image_path)

	character_image.texture = load(image_path)
	character_image.visible = true
	character_image.z_index = 5

	print("Imagen cargada correctamente:", image_path)
