extends Node2D

# Constantes que definen las capas de colisión
# Sirven para diferenciar entre cartas y slots del tablero
const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_SLOT = 2

# Variables principales del sistema
var screen_size                    # Tamaño de la pantalla
var card_being_dragged            # Carta que se está arrastrando actualmente
var is_hovering_on_card           # Indica si el ratón está sobre una carta
var player_hand_reference


# Se ejecuta al iniciar la escena
func _ready()-> void:
	# Guardamos el tamaño de la pantalla para limitar el movimiento
	screen_size = get_viewport_rect().size
	player_hand_reference = $"../PlayerHand"


# Se ejecuta cada frame
func _process(delta: float) -> void:
	# Si hay una carta siendo arrastrada...
	if card_being_dragged:
		# Obtenemos la posición del ratón
		var mouse_pos = get_global_mouse_position()
		
		# Movemos la carta siguiendo al ratón (limitado a la pantalla)
		card_being_dragged.position = Vector2(
			clamp(mouse_pos.x, 0, screen_size.x), 
			clamp(mouse_pos.y, 0, screen_size.y)
		)


# Detecta eventos de entrada (click del ratón)
func _input(event):
	# Comprobamos si es click izquierdo
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		
		if event.pressed:
			# Cuando se pulsa → comprobamos si hay una carta debajo del ratón
			var card = raycast_check_for_card()
			if card:
				start_drag(card)
		else:
			# Cuando se suelta → soltamos la carta si hay alguna
			if card_being_dragged:
				finish_drag(card_being_dragged)


# Inicia el arrastre de una carta
func start_drag(card):
	card_being_dragged = card
	
	# Ajustamos escala al empezar a arrastrar
	card.scale = Vector2(1, 1)


# Finaliza el arrastre de la carta
func finish_drag(card):
	# Pequeño efecto visual al soltar
	card_being_dragged.scale = Vector2(1.05, 1.05)
	
	# Comprobamos si hay un slot debajo del ratón
	var card_slot_found = raycast_check_for_card_slot()
	
	# Si hay slot y está libre...
	if card_slot_found and not card_slot_found.card_in_slot:
		# Colocamos la carta en el slot
		card_being_dragged.position = card_slot_found.position
		player_hand_reference.remove_card_from_hand(card_being_dragged)
		# Desactivamos colisión para que no interfiera más
		card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
		
		# Marcamos el slot como ocupado
		card_slot_found.card_in_slot = true
	
	else:
		player_hand_reference.add_card_to_hand(card_being_dragged)
	
	# Dejamos de arrastrar
	card_being_dragged = null


# Conecta las señales de una carta al manager
func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)


# Se ejecuta cuando el ratón entra en una carta
func on_hovered_over_card(card):
	if !is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)


# Se ejecuta cuando el ratón sale de una carta
func on_hovered_off_card(card):
	# Quitamos highlight de la carta actual
	highlight_card(card, false)
	
	# Comprobamos si hay otra carta debajo del ratón
	var new_card_hovered = raycast_check_for_card()
	
	if new_card_hovered:
		# Si hay otra, la resaltamos
		highlight_card(new_card_hovered, true)
	else:
		# Si no hay ninguna, reseteamos estado
		is_hovering_on_card = false


# Aplica o quita el efecto visual de "hover"
func highlight_card(card, hovered):
	if hovered:
		# Aumentamos tamaño y la ponemos por delante
		card.scale = Vector2(1.05, 1.05)
		card.z_index = 2
	else:
		# Restauramos tamaño y orden
		card.scale = Vector2(1, 1)
		card.z_index = 1


# Detecta si hay una carta bajo el ratón
func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	
	# Solo detecta objetos en la capa de cartas
	parameters.collision_mask = COLLISION_MASK_CARD
	
	var result = space_state.intersect_point(parameters)
	
	if result.size()> 0:
		# Devuelve la carta con mayor z_index (la que está delante)
		return get_card_with_highest_z_index(result)
	
	return null


# Detecta si hay un slot bajo el ratón
func raycast_check_for_card_slot():
	var space_state = get_world_2d().direct_space_state
	
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	
	# Solo detecta slots
	parameters.collision_mask = COLLISION_MASK_CARD_SLOT
	
	var result = space_state.intersect_point(parameters)
	
	if result.size()> 0:
		return result[0].collider.get_parent()
	
	return null


# Devuelve la carta con mayor z_index (la que está encima visualmente)
func get_card_with_highest_z_index(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	
	# Recorremos todas las cartas detectadas
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		
		# Si encontramos una con mayor z_index, la guardamos
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	
	return highest_z_card
