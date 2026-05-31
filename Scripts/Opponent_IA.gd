extends Node

const MOVE_TIME := 0.2


func opponent_turn(battle_manager) -> void:
	battle_manager.current_turn = "opponent"
	
	battle_manager.duel_selection_active = false
	battle_manager.selected_attacker_slot = null
	
	$"../FinTurno".visible = false
	$"../FinTurno".disabled = true
	
	battle_manager.battle_timer.start()
	await battle_manager.battle_timer.timeout
	
	$"../OpponentDeck".draw_until_hand_full()
	
	if battle_manager.game_over:
		return
	
	if battle_manager.hostilities_started:
		var attacked := await opponent_try_best_attack(battle_manager)
		
		if not attacked:
			await play_card_high_might(battle_manager)
	else:
		await play_card_high_might(battle_manager)
	
	if battle_manager.game_over:
		return
	
	$"../OpponentDeck".draw_until_hand_full()
	
	battle_manager.end_opponent_turn()


func play_card_high_might(battle_manager) -> void:
	var enemy_hand = $"../EnemyHand".enemy_hand
	
	if enemy_hand.size() == 0:
		return
	
	if battle_manager.empty_slot.size() == 0:
		return
	
	var random_empty_slot = battle_manager.empty_slot[
		randi_range(0, battle_manager.empty_slot.size() - 1)
	]
	
	while random_empty_slot.card_in_slot and battle_manager.empty_slot.size() > 0:
		battle_manager.empty_slot.erase(random_empty_slot)
		
		if battle_manager.empty_slot.size() == 0:
			return
		
		random_empty_slot = battle_manager.empty_slot[
			randi_range(0, battle_manager.empty_slot.size() - 1)
		]
	
	var card_with_high_might = enemy_hand[0]
	
	for card in enemy_hand:
		if card.attack > card_with_high_might.attack:
			card_with_high_might = card
	
	battle_manager.empty_slot.erase(random_empty_slot)
	
	var placed = random_empty_slot.place_card(card_with_high_might, false, "opponent")
	
	if not placed:
		return
	
	var board_card_scale := Vector2(0.6, 0.55)
	
	card_with_high_might.z_index = 1
	card_with_high_might.starting_position = random_empty_slot.global_position
	
	var tween = get_tree().create_tween()
	
	tween.parallel().tween_property(
		card_with_high_might,
		"global_position",
		random_empty_slot.global_position,
		MOVE_TIME
	)
	
	tween.parallel().tween_property(
		card_with_high_might,
		"scale",
		board_card_scale,
		MOVE_TIME
	)
	
	await tween.finished
	
	card_with_high_might.global_position = random_empty_slot.global_position
	card_with_high_might.scale = board_card_scale
	
	if card_with_high_might.has_node("Area2D/CollisionShape2D"):
		card_with_high_might.get_node("Area2D/CollisionShape2D").disabled = false
	
	if card_with_high_might.has_node("AnimationPlayer"):
		card_with_high_might.get_node("AnimationPlayer").play("Flip")
		await card_with_high_might.get_node("AnimationPlayer").animation_finished
		
		card_with_high_might.global_position = random_empty_slot.global_position
		card_with_high_might.scale = board_card_scale
	
	$"../EnemyHand".remove_card_from_hand(card_with_high_might)


func opponent_try_best_attack(battle_manager) -> bool:
	if not battle_manager.hostilities_started:
		return false
	
	var best_attacker_slot = null
	var best_target_slot = null
	var best_score := -999999
	
	for attacker_slot in battle_manager.get_all_slots():
		if attacker_slot.current_card == null:
			continue
		
		if attacker_slot.slot_owner != "opponent":
			continue
		
		var possible_targets = battle_manager.get_adjacent_enemy_slots(attacker_slot)
		
		for target_slot in possible_targets:
			if target_slot.current_card == null:
				continue
			
			var attacker_attack = battle_manager.ability_manager.get_card_attack(
				attacker_slot.current_card,
				attacker_slot,
				battle_manager.current_turn,
				battle_manager.get_all_slots()
			)
			
			var target_attack = battle_manager.ability_manager.get_card_attack(
				target_slot.current_card,
				target_slot,
				battle_manager.current_turn,
				battle_manager.get_all_slots()
			)
			
			# El rival no ataca si va a perder.
			# Sí ataca si gana o empata, porque en empate mueren ambas.
			if attacker_attack < target_attack:
				continue
			
			var score = target_attack
			
			# Priorizamos matar cartas fuertes.
			# Si empata, le damos menos prioridad que si gana.
			if attacker_attack == target_attack:
				score -= 1
			
			if score > best_score:
				best_score = score
				best_attacker_slot = attacker_slot
				best_target_slot = target_slot
	
	if best_attacker_slot == null or best_target_slot == null:
		print("El rival no tiene ataques favorables")
		print("El rival usa su acción para atacar:")
		battle_manager.add_battle_log("El rival usa su acción para atacar")
		return false
	
	print("El rival usa su acción para atacar:")
	battle_manager.add_battle_log("El rival no tiene ataques favorables")
	print(
		best_attacker_slot.current_card.get_node("Nombre").text,
		" contra ",
		best_target_slot.current_card.get_node("Nombre").text
	)
	
	await battle_manager.start_duel(best_attacker_slot, best_target_slot)
	return true


func opponent_try_start_duel(battle_manager, attacker_slot) -> void:
	if not battle_manager.hostilities_started:
		print("El rival no puede combatir todavía")
		battle_manager.add_battle_log("El rival no puede combatir todavía")
		return
	
	if attacker_slot == null:
		return
	
	if attacker_slot.current_card == null:
		return
	
	if attacker_slot.slot_owner != "opponent":
		print("El atacante del rival no pertenece al rival")
		battle_manager.add_battle_log("El atacante del rival no pertenece al rival")
		return
	
	var player_slots = battle_manager.get_adjacent_enemy_slots(attacker_slot)
	
	print("Rival busca enemigos cercanos:", player_slots.size())
	
	if player_slots.size() == 0:
		print("El rival no tiene objetivos cercanos")
		battle_manager.add_battle_log("El rival no tiene objetivos cercanos")
		return
	
	var best_target = player_slots[0]
	
	for slot in player_slots:
		if slot.current_card.attack > best_target.current_card.attack:
			best_target = slot
	
	print("El rival inicia combate:")
	battle_manager.add_battle_log("El rival inicia combate:")
	
	print(
		attacker_slot.current_card.get_node("Nombre").text,
		" contra ",
		best_target.current_card.get_node("Nombre").text
	)
	
	await battle_manager.start_duel(attacker_slot, best_target)


func opponent_try_any_duel(battle_manager) -> void:
	if not battle_manager.hostilities_started:
		return
	
	var opponent_slots := []
	
	for slot in battle_manager.get_all_slots():
		if slot.card_in_slot and slot.slot_owner == "opponent":
			var targets = battle_manager.get_adjacent_enemy_slots(slot)
			
			if targets.size() > 0:
				opponent_slots.append(slot)
	
	if opponent_slots.size() == 0:
		print("El rival no tiene ningún combate disponible")
		battle_manager.add_battle_log("El rival no tiene ningún combate disponible")
		return
	
	var attacker_slot = opponent_slots[0]
	
	for slot in opponent_slots:
		if slot.current_card.attack > attacker_slot.current_card.attack:
			attacker_slot = slot
	
	await opponent_try_start_duel(battle_manager, attacker_slot)


func opponent_try_all_possible_duels(battle_manager) -> void:
	if not battle_manager.hostilities_started:
		print("El rival no puede combatir todavía")
		battle_manager.add_battle_log("El rival no puede combatir todavía")
		return
	
	var duels_done := 0
	var keep_fighting := true
	
	while keep_fighting:
		keep_fighting = false
		
		var best_attacker_slot = null
		var best_target_slot = null
		var best_score := -999999
		
		for attacker_slot in battle_manager.get_all_slots():
			if attacker_slot.current_card == null:
				continue
			
			if attacker_slot.slot_owner != "opponent":
				continue
			
			var possible_targets = battle_manager.get_adjacent_enemy_slots(attacker_slot)
			
			for target_slot in possible_targets:
				if target_slot.current_card == null:
					continue
				
				var attacker_attack = attacker_slot.current_card.attack
				var target_attack = target_slot.current_card.attack
				
				# El rival solo elige combates que puede ganar.
				if attacker_attack <= target_attack:
					continue
				
				# Prioriza matar cartas fuertes.
				var score = target_attack
				
				if score > best_score:
					best_score = score
					best_attacker_slot = attacker_slot
					best_target_slot = target_slot
		
		if best_attacker_slot != null and best_target_slot != null:
			print("El rival encadena combate:")
			battle_manager.add_battle_log("El rival encadena combate:")
			
			print(
				best_attacker_slot.current_card.get_node("Nombre").text,
				" contra ",
				best_target_slot.current_card.get_node("Nombre").text
			)
			
			await battle_manager.start_duel(best_attacker_slot, best_target_slot)
			duels_done += 1
			keep_fighting = true
			
			await get_tree().create_timer(0.4).timeout
	
	print("Combates del rival realizados:", duels_done)
