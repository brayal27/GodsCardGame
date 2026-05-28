extends Node2D

# Constantes que definen las capas de colisión
# Sirven para diferenciar entre cartas y slots del tablero
const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_SLOT = 2

# Variables principales del sistema
var screen_size
var card_being_dragged
var is_hovering_on_card := false
var player_hand_reference
var colocar_boca_abajo := false


# Se ejecuta al iniciar la escena
func _ready() -> void:
	screen_size = get_viewport_rect().size
	player_hand_reference = $"../PlayerHand"
	$"../InputManager".connect("boton_izquierdo_raton_liberado", on_left_click_released)


# Se ejecuta cada frame
func _process(_delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.global_position = Vector2(
			clamp(mouse_pos.x, 0, screen_size.x),
			clamp(mouse_pos.y, 0, screen_size.y)
		)


func start_drag(card):
	var battle_manager = $"../BattleManager"
	
	# Si estamos seleccionando objetivo de duelo,
	# ignoramos la carta detectada y miramos el slot bajo el ratón.
	if battle_manager.duel_selection_active:
		var target_slot = raycast_check_for_card_slot()
		
		if target_slot:
			battle_manager.try_select_duel_target(target_slot)
		else:
			print("No hay slot bajo el ratón para seleccionar objetivo")
		
		return
	
	# Si la carta ya está en mesa, no se arrastra.
	# Se usa para revelar/iniciar duelo.
	if card.is_on_board:
		battle_manager.handle_board_card_clicked(card)
		return
	
	# Si está en la mano, se arrastra normalmente.
	card_being_dragged = card
	card_being_dragged.z_index = 100
	card.scale = Vector2(1, 1)


# Finaliza el arrastre de la carta
func finish_drag(_card):
	var dragged_card = card_being_dragged
	
	if dragged_card == null:
		return
	
	var card_slot_found = raycast_check_for_card_slot()
	
	if card_slot_found and card_slot_found.can_place_card():
		var face_down := colocar_boca_abajo
		
		var placed = card_slot_found.place_card(dragged_card, face_down, "player")
		
		if not placed:
			if card_being_dragged == dragged_card:
				card_being_dragged = null
			return
		
		player_hand_reference.remove_card_from_hand(dragged_card)
		
		dragged_card.z_index = 1
		dragged_card.starting_position = card_slot_found.global_position
		
		var tween = get_tree().create_tween()
		
		tween.parallel().tween_property(
			dragged_card,
			"global_position",
			card_slot_found.global_position,
			0.15
		)
		
		tween.parallel().tween_property(
			dragged_card,
			"scale",
			Vector2(0.6, 0.55),
			0.15
		)
		
		await tween.finished
		
		if is_instance_valid(dragged_card):
			dragged_card.global_position = card_slot_found.global_position
			dragged_card.scale = Vector2(0.6, 0.55)
			
			if dragged_card.has_node("Area2D/CollisionShape2D"):
				dragged_card.get_node("Area2D/CollisionShape2D").disabled = false
		
		if has_node("../BattleManager"):
			$"../BattleManager".empty_slot.erase(card_slot_found)
		
		if card_being_dragged == dragged_card:
			card_being_dragged = null
		
		return
	
	if card_being_dragged == dragged_card:
		card_being_dragged = null


# Conecta las señales de una carta al manager
func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)


func on_left_click_released():
	if card_being_dragged:
		finish_drag(card_being_dragged)


# Se ejecuta cuando el ratón entra en una carta
func on_hovered_over_card(card):
	if not is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)


# Se ejecuta cuando el ratón sale de una carta
func on_hovered_off_card(card):
	highlight_card(card, false)
	
	var new_card_hovered = raycast_check_for_card()
	
	if new_card_hovered:
		highlight_card(new_card_hovered, true)
	else:
		is_hovering_on_card = false


func highlight_card(card, hovered):
	# Las cartas que ya están en mesa NO deben subir z_index con hover.
	# Si suben, pueden tapar otras cartas y romper la selección de objetivo.
	if card.is_on_board:
		card.z_index = 1
		return
	
	var tween = get_tree().create_tween()
	
	if hovered:
		card.z_index = 2
		
		var hover_position = card.starting_position + Vector2(0, -290)
		
		tween.parallel().tween_property(card, "scale", Vector2(1.1, 1.1), 0.1)
		tween.parallel().tween_property(card, "position", hover_position, 0.1)
	else:
		card.z_index = 1
		
		tween.parallel().tween_property(card, "scale", Vector2(1, 1), 0.1)
		tween.parallel().tween_property(card, "position", card.starting_position, 0.1)


# Detecta si hay una carta bajo el ratón
func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	
	var result = space_state.intersect_point(parameters)
	
	if result.size() > 0:
		return get_card_with_highest_z_index(result)
	
	return null


# Detecta si hay un slot bajo el ratón
func raycast_check_for_card_slot():
	var space_state = get_world_2d().direct_space_state
	
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD_SLOT
	
	var result = space_state.intersect_point(parameters)
	
	if result.size() > 0:
		return result[0].collider.get_parent()
	
	return null


# Devuelve la carta con mayor z_index
func get_card_with_highest_z_index(cards):
	var battle_manager = $"../BattleManager"
	
	# Si estamos seleccionando objetivo de duelo,
	# damos prioridad a una carta enemiga válida.
	if battle_manager.duel_selection_active:
		for i in range(cards.size()):
			var current_card = cards[i].collider.get_parent()
			
			if battle_manager.is_valid_duel_target_card(current_card):
				return current_card
	
	# Comportamiento normal: carta con mayor z_index
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	
	return highest_z_card


func set_face_down_mode(value: bool):
	colocar_boca_abajo = value


func toggle_face_down_mode():
	colocar_boca_abajo = not colocar_boca_abajo
	print("Modo boca abajo:", colocar_boca_abajo)


func _on_face_up_pressed() -> void:
	set_face_down_mode(false)
	print("Modo seleccionado: boca arriba")


func _on_face_down_pressed() -> void:
	set_face_down_mode(true)
	print("Modo seleccionado: boca abajo")
