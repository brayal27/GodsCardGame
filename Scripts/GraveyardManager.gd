extends Node

var player_graveyard_cards := []
var opponent_graveyard_cards := []

const GRAVEYARD_CARD_SCALE := Vector2(0.95, 0.85)
const GRAVEYARD_CARD_OFFSET := Vector2(0, 0)


func send_card_to_graveyard(card, dead_owner: String) -> void:
	if card == null:
		return
	
	if not is_instance_valid(card):
		return
	
	var graveyard_node: Node2D
	var graveyard_index := 0
	
	if dead_owner == "player":
		graveyard_node = $"../PlayerGraveyard"
		graveyard_index = player_graveyard_cards.size()
		player_graveyard_cards.append(card)
	else:
		graveyard_node = $"../OpponentGraveyard"
		graveyard_index = opponent_graveyard_cards.size()
		opponent_graveyard_cards.append(card)
	
	# Si muere boca abajo, la mostramos antes de mandarla al cementerio.
	if card.is_face_down:
		card.reveal_card()
	
	card.is_on_board = false
	card.current_slot = null
	
	# Desactivar colisiones para que no se pueda clicar ni arrastrar.
	if card.has_node("Area2D/CollisionShape2D"):
		card.get_node("Area2D/CollisionShape2D").disabled = true
	
	var hit_tween = get_tree().create_tween()
	
	hit_tween.tween_property(
		card,
		"scale",
		card.scale * 1.15,
		0.08
	)
	
	hit_tween.tween_property(
		card,
		"scale",
		card.scale,
		0.08
	)
	
	await hit_tween.finished
	
	# La sacamos de donde esté y la ponemos dentro del cementerio.
	card.reparent(graveyard_node, true)
	
	var final_position = graveyard_node.global_position + GRAVEYARD_CARD_OFFSET * graveyard_index
	
	card.z_index = 20 + graveyard_index
	
	var tween = get_tree().create_tween()
	
	tween.parallel().tween_property(
		card,
		"global_position",
		final_position,
		0.25
	)
	
	tween.parallel().tween_property(
		card,
		"scale",
		GRAVEYARD_CARD_SCALE,
		0.25
	)
