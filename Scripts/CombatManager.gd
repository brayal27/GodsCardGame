extends Node


func try_reveal_card_for_duel(battle_manager, slot) -> void:
	print("Intentando revelar/iniciar duelo con carta:", slot.name)
	
	if slot.slot_owner != "player":
		print("Solo puedes usar tus propias cartas")
		battle_manager.add_battle_log("Solo puedes usar tus propias cartas")
		return
	
	if slot.current_card == null:
		print("Este slot no tiene carta")
		battle_manager.add_battle_log("Este slot no tiene carta")
		return
	
	if slot.current_card.is_face_down:
		slot.current_card.reveal_card()
		print("Carta girada:", slot.current_card.get_node("Nombre").text)
		
	else:
		print("La carta ya estaba boca arriba:", slot.current_card.get_node("Nombre").text)
	
	var enemy_slots = get_adjacent_enemy_slots(battle_manager, slot)
	
	print("Enemigos cercanos encontrados:", enemy_slots.size())
	
	if enemy_slots.size() == 0:
		print("Carta revelada, pero no hay enemigos cerca")
		battle_manager.add_battle_log("Carta revelada, pero no hay enemigos cerca")
		battle_manager.selected_attacker_slot = null
		battle_manager.duel_selection_active = false
		return
	
	battle_manager.selected_attacker_slot = slot
	battle_manager.duel_selection_active = true
	
	print("Carta preparada para combatir:", slot.current_card.get_node("Nombre").text)
	battle_manager.add_battle_log("Carta preparada para combatir: " + slot.current_card.get_node("Nombre").text)
	
	print("Selecciona una carta enemiga cercana para iniciar el duelo.")
	battle_manager.add_battle_log("Selecciona una carta enemiga cercana para iniciar el duelo.")


func try_select_duel_target(battle_manager, target_slot) -> void:
	print("Intentando seleccionar objetivo:", target_slot.name)
	
	if battle_manager.selected_attacker_slot == null:
		print("No hay carta atacante seleccionada")
		battle_manager.add_battle_log("No hay carta atacante seleccionada")
		
		battle_manager.duel_selection_active = false
		return
	
	if target_slot.current_card == null:
		print("Ese slot no tiene carta")
		battle_manager.add_battle_log("Ese slot no tiene carta")
		return
	
	print("Atacante:", battle_manager.selected_attacker_slot.name, battle_manager.selected_attacker_slot.slot_owner)
	
	print("Objetivo:", target_slot.name, target_slot.slot_owner)
	
	if target_slot.slot_owner == battle_manager.selected_attacker_slot.slot_owner:
		print("Debes seleccionar una carta enemiga")
		battle_manager.add_battle_log("Debes seleccionar una carta enemiga")
		return
	
	if not battle_manager.ability_manager.are_slots_adjacent(battle_manager.selected_attacker_slot, target_slot):
		print("La carta enemiga no está cerca")
		battle_manager.add_battle_log("La carta enemiga no está cerca")
		return
	
	print("Objetivo válido. Iniciando duelo.")
	battle_manager.add_battle_log("Objetivo válido. Iniciando duelo.")
	
	await start_duel(battle_manager, battle_manager.selected_attacker_slot, target_slot)
	
	battle_manager.selected_attacker_slot = null
	battle_manager.duel_selection_active = false
	battle_manager.waiting_for_attack_after_move = false
	
	battle_manager.register_player_action("girar_y_atacar")


func check_for_duel(battle_manager, slot) -> void:
	if not battle_manager.hostilities_started:
		print("Todavía no pueden empezar los combates")
		battle_manager.add_battle_log("Todavía no pueden empezar los combates")
		return
	
	if slot.current_card == null:
		return
	
	var enemy_slots = get_adjacent_enemy_slots(battle_manager, slot)
	
	if enemy_slots.size() == 0:
		print("No hay enemigos cerca")
		battle_manager.add_battle_log("No hay enemigos cerca")
		return
	
	var enemy_slot = enemy_slots[0]
	await start_duel(battle_manager, slot, enemy_slot)


func start_duel(battle_manager, attacker_slot, defender_slot) -> void:
	var attacker = attacker_slot.current_card
	var defender = defender_slot.current_card
	
	if attacker == null or defender == null:
		return
	
	
	print("DUELO INICIADO")
	battle_manager.add_battle_log("DUELO INICIADO")
	print(attacker.get_node("Nombre").text, " VS ", defender.get_node("Nombre").text)
	
	if attacker.is_face_down:
		attacker.reveal_card()
	
	if defender.is_face_down:
		defender.reveal_card()
	
	await get_tree().create_timer(0.3).timeout
	
	var attacker_power = battle_manager.ability_manager.get_card_attack(
		attacker,
		attacker_slot,
		battle_manager.current_turn,
		battle_manager.get_all_slots()
	)

	var defender_power = battle_manager.ability_manager.get_card_attack(
		defender,
		defender_slot,
		battle_manager.current_turn,
		battle_manager.get_all_slots()
	)
	
	var attacker_health = attacker.health
	var defender_health = defender.health
	
	var defender_dies = attacker_power >= defender_health
	var attacker_dies = defender_power >= attacker_health
	
	print("Ataque atacante:", attacker_power, " / Vida defensor:", defender_health)
	
	print("Ataque defensor:", defender_power, " / Vida atacante:", attacker_health)
	
	if attacker_dies and defender_dies:
		print("Ambas cartas mueren")
		battle_manager.add_battle_log("Ambas cartas mueren")
		
		battle_manager.kill_card(attacker_slot)
		battle_manager.kill_card(defender_slot)
	
	elif defender_dies:
		print("Muere la carta defensora")
		battle_manager.add_battle_log("Muere la carta defensora")
		
		battle_manager.kill_card(defender_slot)
	
	elif attacker_dies:
		print("Muere la carta atacante")
		battle_manager.add_battle_log("Muere la carta atacante")
		
		battle_manager.kill_card(attacker_slot)
	
	battle_manager.check_game_over()


func get_adjacent_enemy_slots(battle_manager, slot) -> Array:
	var result := []
	
	for other_slot in battle_manager.get_all_slots():
		if other_slot == slot:
			continue
		
		if not other_slot.card_in_slot:
			continue
		
		if other_slot.slot_owner == slot.slot_owner:
			continue
		
		if battle_manager.ability_manager.are_slots_adjacent(slot, other_slot):
			result.append(other_slot)
	
	return result


func is_valid_duel_target_card(battle_manager, card) -> bool:
	if not battle_manager.duel_selection_active:
		return false
	
	if battle_manager.selected_attacker_slot == null:
		return false
	
	if card == null:
		return false
	
	if not card.is_on_board:
		return false
	
	if card.current_slot == null:
		return false
	
	var target_slot = card.current_slot
	
	if target_slot.current_card == null:
		return false
	
	if target_slot.slot_owner == battle_manager.selected_attacker_slot.slot_owner:
		return false
	
	if not battle_manager.ability_manager.are_slots_adjacent(battle_manager.selected_attacker_slot, target_slot):
		return false
	
	return true


func animate_duel(attacker, defender) -> void:
	var attacker_original_pos = attacker.global_position
	var defender_original_pos = defender.global_position
	
	attacker.z_index = 50
	defender.z_index = 49
	
	var direction = (defender.global_position - attacker.global_position).normalized()
	
	var tween = get_tree().create_tween()
	
	tween.tween_property(
		attacker,
		"global_position",
		attacker.global_position + direction * 40,
		0.15
	)
	
	tween.tween_property(
		attacker,
		"global_position",
		attacker_original_pos,
		0.15
	)
	
	await tween.finished
	
	var shake_tween = get_tree().create_tween()
	
	shake_tween.tween_property(
		defender,
		"global_position",
		defender_original_pos + Vector2(10, 0),
		0.05
	)
	
	shake_tween.tween_property(
		defender,
		"global_position",
		defender_original_pos + Vector2(-10, 0),
		0.05
	)
	
	shake_tween.tween_property(
		defender,
		"global_position",
		defender_original_pos,
		0.05
	)
	
	await shake_tween.finished
	
	attacker.z_index = 1
	defender.z_index = 1
