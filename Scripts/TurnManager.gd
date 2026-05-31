extends Node


func start_initial_roll(battle_manager) -> void:
	battle_manager.roll_panel = $"../RollPanel"
	battle_manager.player_roll_label = $"../RollPanel/VBoxContainer/PlayerRollLabel"
	battle_manager.opponent_roll_label = $"../RollPanel/VBoxContainer/OpponentRollLabel"
	battle_manager.roll_result_label = $"../RollPanel/VBoxContainer/RollResultLabel"
	battle_manager.fin_turno_button = $"../FinTurno"

	var faction_select = $"../RollPanel/VBoxContainer/FactionSelect"
	var faction_panel = $"../RollPanel/VBoxContainer/FactionPanel"

	faction_select.visible = false
	faction_panel.visible = false

	battle_manager.fin_turno_button.visible = false
	battle_manager.fin_turno_button.disabled = true

	battle_manager.roll_panel.visible = true
	battle_manager.player_roll_label.visible = true
	battle_manager.opponent_roll_label.visible = true
	battle_manager.roll_result_label.visible = true

	battle_manager.player_roll_label.text = "Jugador: -"
	battle_manager.opponent_roll_label.text = "Rival: -"
	battle_manager.roll_result_label.text = "Realizando sorteo..."

	battle_manager.battle_timer.start()
	await battle_manager.battle_timer.timeout

	await roll_starting_player(battle_manager)


func roll_starting_player(battle_manager) -> void:
	battle_manager.battle_timer.wait_time = 2.0
	
	battle_manager.player_roll = randi_range(1, 20)
	battle_manager.opponent_roll = randi_range(1, 20)
	
	battle_manager.player_roll_label.text = "Jugador: " + str(battle_manager.player_roll)
	battle_manager.opponent_roll_label.text = "Rival: " + str(battle_manager.opponent_roll)
	
	if battle_manager.player_roll > battle_manager.opponent_roll:
		battle_manager.roll_result_label.text = "Empieza el jugador"
		
		battle_manager.battle_timer.start()
		await battle_manager.battle_timer.timeout
		
		start_player_turn(battle_manager)
	
	elif battle_manager.opponent_roll > battle_manager.player_roll:
		battle_manager.roll_result_label.text = "Empieza el rival"
		
		battle_manager.battle_timer.start()
		await battle_manager.battle_timer.timeout
		
		battle_manager.roll_panel.visible = false
		await battle_manager.opponent_turn()
	
	else:
		battle_manager.roll_result_label.text = "Empate. Repitiendo sorteo..."
		
		battle_manager.battle_timer.start()
		await battle_manager.battle_timer.timeout
		
		await roll_starting_player(battle_manager)


func start_player_turn(battle_manager) -> void:
	if battle_manager.game_over:
		return
	
	battle_manager.current_turn = "player"
	battle_manager.roll_panel.visible = false
	
	battle_manager.duel_selection_active = false
	battle_manager.selected_attacker_slot = null
	
	battle_manager.move_selection_active = false
	battle_manager.selected_moving_slot = null
	battle_manager.waiting_for_attack_after_move = false
	
	battle_manager.player_action_used = false
	
	$"../FinTurno".visible = true
	$"../FinTurno".disabled = false
	$"../FinTurno".text = "LISTO"
	
	print("Empieza el turno del jugador")
	battle_manager.add_battle_log("Empieza el turno del jugador")


func can_player_do_action(battle_manager) -> bool:
	if battle_manager.current_turn != "player":
		print("No es tu turno")
		battle_manager.add_battle_log("No es tu turno")
		return false
	
	if battle_manager.player_action_used:
		print("Ya has realizado una acción este turno")
		battle_manager.add_battle_log("Ya has realizado una acción este turno")
		return false
	
	return true


func can_player_play_card(battle_manager) -> bool:
	if not can_player_do_action(battle_manager):
		return false
	
	# Antes del turno 4 solo se puede jugar carta.
	if not battle_manager.hostilities_started:
		return true
	
	# Desde turno 4 también se puede jugar carta como una de las opciones.
	return true


func register_player_action(battle_manager, action_name: String) -> void:
	battle_manager.player_action_used = true
	
	battle_manager.duel_selection_active = false
	battle_manager.selected_attacker_slot = null
	
	battle_manager.move_selection_active = false
	battle_manager.selected_moving_slot = null
	battle_manager.waiting_for_attack_after_move = false
	
	print("Acción realizada:", action_name)
	print("Pulsa listo para terminar el turno")

	battle_manager.add_battle_log("Acción realizada: " + action_name)
	battle_manager.add_battle_log("Pulsa listo para terminar el turno")


func end_player_turn(battle_manager) -> void:
	battle_manager.current_turn = "opponent"
	
	battle_manager.duel_selection_active = false
	battle_manager.selected_attacker_slot = null
	
	# Al acabar el turno, el jugador roba hasta volver a tener 4 cartas.
	$"../Deck".draw_until_hand_full()
	
	register_turn_finished(battle_manager)
	
	$"../FinTurno".visible = false
	$"../FinTurno".disabled = true
	
	await battle_manager.opponent_turn()


func end_opponent_turn(battle_manager) -> void:
	register_turn_finished(battle_manager)
	start_player_turn(battle_manager)


func register_turn_finished(battle_manager) -> void:
	battle_manager.turns_finished_this_round += 1
	
	if battle_manager.turns_finished_this_round >= 2:
		battle_manager.turns_finished_this_round = 0
		advance_turn(battle_manager)
	else:
		update_turn_label(battle_manager)


func advance_turn(battle_manager) -> void:
	battle_manager.turn_number += 1
	
	if battle_manager.turn_number >= 4:
		battle_manager.hostilities_started = true
	
	update_turn_label(battle_manager)


func update_turn_label(battle_manager) -> void:
	battle_manager.turn_label = $"../TurnLabel"
	
	if battle_manager.hostilities_started:
		battle_manager.turn_label.text = "Turno " + str(battle_manager.turn_number) 
	else:
		battle_manager.turn_label.text = "Turno " + str(battle_manager.turn_number) 
