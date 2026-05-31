extends Node2D

const CARD_SCENE_PATH = "res://Escenas/EnemyCard.tscn"
const Characters = preload("res://Scripts/Characters.gd")
const speed = 0.2
const MAX_HAND_SIZE = 4

const NORDIC_FRONT_TEXTURE = preload("res://Assets/Carta.jpg")
const NORDIC_BACK_TEXTURE = preload("res://Assets/Faccion nordica.jpg")

const GREEK_FRONT_TEXTURE = preload("res://Assets/Faccion_Griega_anverso.jpg")
const GREEK_BACK_TEXTURE = preload("res://Assets/Faccion_Griega.jpg")

var opponent_faction 
var opponent_deck := []


func _ready() -> void:
	randomize()
	$RichTextLabel2.text = "0"

func setup_deck(faction_name: String) -> void:
	opponent_faction = faction_name
	opponent_deck.clear()
	opponent_deck = Characters.create_deck_from_faction(opponent_faction)
	$RichTextLabel2.text = str(opponent_deck.size())
	draw_until_hand_full()

func draw_until_hand_full():
	var enemy_hand = $"../EnemyHand".enemy_hand

	while enemy_hand.size() < MAX_HAND_SIZE and not opponent_deck.is_empty():
		robar_carta()


func robar_carta():
	if opponent_deck.is_empty():
		return

	var card_drawn_name = opponent_deck[0]
	opponent_deck.erase(card_drawn_name)

	if not Characters.CHARACTERS.has(card_drawn_name):
		print("No existe el personaje en Characters.gd:", card_drawn_name)
		$RichTextLabel2.text = str(opponent_deck.size())
		return

	if opponent_deck.size() == 0:
		if has_node("Deck/Sprite2D"):
			$Deck/Sprite2D.visible = false

		if has_node("Deck/RichTextLabel"):
			$Deck/RichTextLabel.visible = false

	$RichTextLabel2.text = str(opponent_deck.size())

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
	$"../EnemyHand".add_card_to_hand(new_card, speed)
	
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

func apply_faction_textures(card, faction_name: String) -> void:
	var card_image = card.get_node_or_null("CardImage")
	var card_back = card.get_node_or_null("Back")

	if card_image == null:
		push_warning("La carta enemiga no tiene nodo CardImage")
		return

	if card_back == null:
		push_warning("La carta enemiga no tiene nodo Back")
		return

	match faction_name:
		"nordicos":
			card_image.texture = NORDIC_FRONT_TEXTURE
			card_back.texture = NORDIC_BACK_TEXTURE

		"griegos":
			card_image.texture = GREEK_FRONT_TEXTURE
			card_back.texture = GREEK_BACK_TEXTURE

		_:
			push_warning("Facción desconocida en carta enemiga: " + faction_name)
			card_image.texture = NORDIC_FRONT_TEXTURE
			card_back.texture = NORDIC_BACK_TEXTURE
func apply_character_image(card, character_data: Dictionary) -> void:
	var character_image = card.get_node_or_null("CharacterImage")

	if character_image == null:
		print("ERROR: No existe CharacterImage en la carta")
		return

	var image_path = character_data.get("image", "")

	print("Intentando cargar imagen:", image_path)

	if image_path == "":
		print("ERROR: El personaje no tiene image:", character_data.get("name", "SIN NOMBRE"))
		character_image.visible = false
		return

	if not ResourceLoader.exists(image_path):
		print("ERROR: No existe el archivo:", image_path)
		character_image.visible = false
		return

	character_image.texture = load(image_path)
	character_image.visible = true
	character_image.z_index = 5

	print("Imagen cargada correctamente:", image_path)
