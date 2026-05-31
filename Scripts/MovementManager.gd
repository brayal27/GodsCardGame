extends Node

const MOVE_TIME := 0.2
const BOARD_CARD_SCALE := Vector2(0.6, 0.55)


func try_select_move_slot(battle_manager, target_slot) -> void:
	if not battle_manager.move_selection_active:
		return
	
	if battle_manager.selected_moving_slot == null:
		battle_manager.move_selection_active = false
		return
	
	if target_slot == null:
		print("No hay slot seleccionado")
		return
	
	if target_slot.card_in_slot:
		print("Ese slot está ocupado")
		return
	
	if not battle_manager.ability_manager.are_slots_adjacent(
		battle_manager.selected_moving_slot,
		target_slot
	):
		print("Solo puedes moverte una casilla")
		return
	
	var card = battle_manager.selected_moving_slot.current_card
	
	if card == null:
		print("La carta seleccionada ya no existe")
		battle_manager.move_selection_active = false
		battle_manager.selected_moving_slot = null
		return
	
	move_card_to_slot(battle_manager, battle_manager.selected_moving_slot, target_slot)
	
	battle_manager.selected_attacker_slot = target_slot
	battle_manager.move_selection_active = false
	battle_manager.selected_moving_slot = null
	
	var enemy_slots = battle_manager.get_adjacent_enemy_slots(target_slot)
	
	if enemy_slots.size() == 0:
		print("La carta se ha movido, pero no hay enemigos cerca")
		battle_manager.register_player_action("girar_y_mover")
		return
	
	battle_manager.duel_selection_active = true
	battle_manager.waiting_for_attack_after_move = true
	
	print("Movimiento realizado. Selecciona una carta enemiga adyacente para atacar")
	


func move_card_to_slot(battle_manager, origin_slot, target_slot) -> void:
	var card = origin_slot.current_card
	
	if card == null:
		return
	
	var owner = origin_slot.slot_owner
	
	origin_slot.remove_card()
	
	if origin_slot not in battle_manager.empty_slot:
		battle_manager.empty_slot.append(origin_slot)
	
	battle_manager.empty_slot.erase(target_slot)
	
	target_slot.card_in_slot = true
	target_slot.current_card = card
	target_slot.slot_owner = owner
	
	card.current_slot = target_slot
	card.card_owner = owner
	card.is_on_board = true
	card.starting_position = target_slot.global_position
	
	var tween = get_tree().create_tween()
	
	tween.parallel().tween_property(
		card,
		"global_position",
		target_slot.global_position,
		MOVE_TIME
	)
	
	tween.parallel().tween_property(
		card,
		"scale",
		BOARD_CARD_SCALE,
		MOVE_TIME
	)
	
	print("Carta movida a:", target_slot.name)
