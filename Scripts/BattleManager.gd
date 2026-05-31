extends Node

var battle_timer
var empty_slot = []

# Managers
var ability_manager
var graveyard_manager
var turn_manager
var opponent_ia
var combat_manager
var movement_manager

# Turnos
var current_turn := "player"
var player_roll
var opponent_roll
var turn_number := 1
var turns_finished_this_round := 0
var hostilities_started := false
var player_action_used := false

# Facción
var player_faction := ""
var opponent_faction := ""

var faction_panel
var faction_select
var greek_button
var nordic_button

# UI de turnos
var roll_panel 
var player_roll_label 
var opponent_roll_label 
var roll_result_label 
var fin_turno_button
var turn_label 

# Marcador
var player_kills := 0
var opponent_kills := 0
var game_over := false

# Combate
var duel_selection_active := false
var selected_attacker_slot = null
var battle_log_manager

# Movimiento
var move_selection_active := false
var selected_moving_slot = null
var waiting_for_attack_after_move := false

func _ready() -> void:
	randomize()
	
	ability_manager = $"../AbilityManager"
	graveyard_manager = $"../GraveyardManager"
	turn_manager = $"../TurnManager"
	opponent_ia = $"../OpponentIA"
	combat_manager = $"../CombatManager"
	movement_manager = $"../MovementManager"
	battle_log_manager = get_node_or_null("../BattleLogManager")
	if battle_log_manager == null:
		push_error("No se encuentra BattleLogManager. Revisa que el nodo exista y se llame exactamente BattleLogManager.")
	else:
		add_battle_log("Log iniciado")
	
	battle_timer = $"../BattleTimer"
	battle_timer.one_shot = true
	battle_timer.wait_time = 1.0
	
	empty_slot = get_all_slots().duplicate()
	
	update_turn_label()
	update_kill_labels()
	setup_faction_selection()

# =========================
# FACCIÓN
# =========================

func setup_faction_selection() -> void:
	roll_panel = $"../RollPanel"
	player_roll_label = $"../RollPanel/VBoxContainer/PlayerRollLabel"
	opponent_roll_label = $"../RollPanel/VBoxContainer/OpponentRollLabel"
	roll_result_label = $"../RollPanel/VBoxContainer/RollResultLabel"

	faction_select = $"../RollPanel/VBoxContainer/FactionSelect"
	faction_panel = $"../RollPanel/VBoxContainer/FactionPanel"
	nordic_button = $"../RollPanel/VBoxContainer/FactionPanel/NordicButton"
	greek_button = $"../RollPanel/VBoxContainer/FactionPanel/GreekButton"

	fin_turno_button = $"../FinTurno"

	roll_panel.visible = true

	# Ocultamos el sorteo mientras se elige facción
	player_roll_label.visible = false
	opponent_roll_label.visible = false
	roll_result_label.visible = false

	# Mostramos elección de facción
	faction_select.visible = true
	faction_panel.visible = true
	nordic_button.visible = true
	greek_button.visible = true

	nordic_button.disabled = false
	greek_button.disabled = false

	# Todavía no se puede acabar turno
	fin_turno_button.visible = false
	fin_turno_button.disabled = true

	if not nordic_button.pressed.is_connected(_on_nordic_button_pressed):
		nordic_button.pressed.connect(_on_nordic_button_pressed)

	if not greek_button.pressed.is_connected(_on_greek_button_pressed):
		greek_button.pressed.connect(_on_greek_button_pressed)


func _on_greek_button_pressed() -> void:
	await select_faction("griegos")


func _on_nordic_button_pressed() -> void:
	await select_faction("nordicos")


func select_faction(selected_faction: String) -> void:
	player_faction = selected_faction

	if player_faction == "nordicos":
		opponent_faction = "griegos"
	else:
		opponent_faction = "nordicos"

	add_battle_log("Jugador elige facción: " + player_faction)
	add_battle_log("El rival usará facción: " + opponent_faction)

	$"../Deck".setup_deck(player_faction)
	$"../OpponentDeck".setup_deck(opponent_faction)

	# Ocultamos elección de facción
	faction_select.visible = false
	faction_panel.visible = false

	nordic_button.disabled = true
	greek_button.disabled = true

	# Mostramos sorteo
	player_roll_label.visible = true
	opponent_roll_label.visible = true
	roll_result_label.visible = true

	start_initial_roll()

# =========================
# TURN MANAGER
# =========================

func start_initial_roll() -> void:
	await turn_manager.start_initial_roll(self)

func roll_starting_player() -> void:
	await turn_manager.roll_starting_player(self)

func start_player_turn() -> void:
	turn_manager.start_player_turn(self)

func can_player_do_action() -> bool:
	return turn_manager.can_player_do_action(self)

func can_player_play_card() -> bool:
	return turn_manager.can_player_play_card(self)

func register_player_action(action_name: String):
	turn_manager.register_player_action(self, action_name)

func end_player_turn() -> void:
	await turn_manager.end_player_turn(self)

func end_opponent_turn() -> void:
	turn_manager.end_opponent_turn(self)

func register_turn_finished() -> void:
	turn_manager.register_turn_finished(self)

func advance_turn() -> void:
	turn_manager.advance_turn(self)

func update_turn_label() -> void:
	turn_manager.update_turn_label(self)

# =========================
# OPPONENT AI
# =========================

func opponent_turn() -> void:
	await opponent_ia.opponent_turn(self)

func play_card_high_might() -> void:
	await opponent_ia.play_card_high_might(self)

func opponent_try_best_attack() -> bool:
	return await opponent_ia.opponent_try_best_attack(self)

func opponent_try_start_duel(attacker_slot) -> void:
	await opponent_ia.opponent_try_start_duel(self, attacker_slot)

func opponent_try_any_duel() -> void:
	await opponent_ia.opponent_try_any_duel(self)

func opponent_try_all_possible_duels() -> void:
	await opponent_ia.opponent_try_all_possible_duels(self)

# =========================
# COMBAT MANAGER
# =========================

func try_reveal_card_for_duel(slot) -> void:
	combat_manager.try_reveal_card_for_duel(self, slot)

func try_select_duel_target(target_slot) -> void:
	await combat_manager.try_select_duel_target(self, target_slot)

func check_for_duel(slot) -> void:
	await combat_manager.check_for_duel(self, slot)

func start_duel(attacker_slot, defender_slot) -> void:
	await combat_manager.start_duel(self, attacker_slot, defender_slot)

func get_adjacent_enemy_slots(slot) -> Array:
	return combat_manager.get_adjacent_enemy_slots(self, slot)
	
func is_valid_duel_target_card(card) -> bool:
	return combat_manager.is_valid_duel_target_card(self, card)

func animate_duel(attacker, defender) -> void:
	await combat_manager.animate_duel(attacker, defender)

func add_battle_log(message: String) -> void:
	print("[LOG DESDE BATTLEMANAGER] " + message)

	if battle_log_manager != null and battle_log_manager.has_method("add_message"):
		battle_log_manager.add_message(message)
	else:
		push_warning("No se pudo enviar mensaje al BattleLogManager: " + message)

# =========================
# MOVEMENT MANAGER
# =========================
func try_select_move_slot(target_slot) -> void:
	movement_manager.try_select_move_slot(self, target_slot)

func move_card_to_slot(origin_slot, target_slot) -> void:
	movement_manager.move_card_to_slot(self, origin_slot, target_slot)


func _on_fin_turno_pressed() -> void:
	if current_turn != "player":
		return
	
	if not player_action_used:
		print("Primero debes realizar una acción")
		add_battle_log("Primero debes realizar una acción")
		return
	
	if game_over:
		return
	end_player_turn()

func handle_board_card_clicked(card):
	print("Click en carta de mesa:", card.name)
	
	if current_turn != "player":
		print("No es tu turno")
		return
	
	if card.current_slot == null:
		print("Esta carta no tiene slot asignado")
		return
	
	var clicked_slot = card.current_slot
	
	if clicked_slot.slot_owner != "player":
		print("No puedes usar cartas del rival")
		return
	
	if not hostilities_started:
		print("Antes del turno 4 solo puedes jugar cartas")
		return
	
	if not can_player_do_action():
		return
	
	if card.is_face_down:
		card.reveal_card()
		print("Carta girada:", card.get_node("Nombre").text)
	else:
		print("La carta ya estaba boca arriba")
	
	var enemy_slots = get_adjacent_enemy_slots(clicked_slot)
	
	if enemy_slots.size() > 0:
		selected_attacker_slot = clicked_slot
		duel_selection_active = true
		
		move_selection_active = false
		selected_moving_slot = null
		waiting_for_attack_after_move = false
		
		print("Hay enemigos cerca. Selecciona una carta enemiga para atacar.")
		return
	
	selected_moving_slot = clicked_slot
	move_selection_active = true
	
	selected_attacker_slot = null
	duel_selection_active = false
	waiting_for_attack_after_move = false
	
	print("No hay enemigos cerca. Selecciona una casilla adyacente vacía para mover la carta.")
	
	if game_over:
		return

func get_all_slots() -> Array:
	return [
		$"../Card_slots/CardSlot00",
		$"../Card_slots/CardSlot01",
		$"../Card_slots/CardSlot02",
		$"../Card_slots/CardSlot03",
		$"../Card_slots/CardSlot10",
		$"../Card_slots/CardSlot11",
		$"../Card_slots/CardSlot12",
		$"../Card_slots/CardSlot13",
		$"../Card_slots/CardSlot20",
		$"../Card_slots/CardSlot21",
		$"../Card_slots/CardSlot22",
		$"../Card_slots/CardSlot23",
		$"../Card_slots/CardSlot30",
		$"../Card_slots/CardSlot31",
		$"../Card_slots/CardSlot32",
		$"../Card_slots/CardSlot33"
	]

func kill_card(slot):
	var card = slot.current_card
	
	if card == null:
		return
	
	var dead_owner = slot.slot_owner
	
	print("Carta derrotada:", card.get_node("Nombre").text)
	
	if dead_owner == "player":
		opponent_kills += 1
	else:
		player_kills += 1
	
	update_kill_labels()
	
	slot.remove_card()
	
	if slot not in empty_slot:
		empty_slot.append(slot)
	
	graveyard_manager.send_card_to_graveyard(card, dead_owner)
	

func update_kill_labels():
	$"../Marcador/PlayerKillsLabel".text = "Jugador: " + str(player_kills) + "/7"
	$"../Marcador/OpponentKillsLabel".text = "Rival: " + str(opponent_kills) + "/7"

func check_game_over():
	if game_over:
		return
	
	if player_kills >= 7 and opponent_kills >= 7:
		end_game("Empate")
	elif player_kills >= 7:
		end_game("Gana el jugador")
	elif opponent_kills >= 7:
		end_game("Gana el rival")

func end_game(result_text: String):
	game_over = true
	current_turn = "game_over"
	
	duel_selection_active = false
	selected_attacker_slot = null
	
	move_selection_active = false
	selected_moving_slot = null
	waiting_for_attack_after_move = false
	
	print("PARTIDA TERMINADA:", result_text)
	
	$"../FinTurno".visible = false
	$"../FinTurno".disabled = true
	
	if has_node("../EndGame"):
		$"../EndGame".visible = true
		
		if has_node("../EndGame/VBoxContainer/Winner"):
			$"../EndGame/VBoxContainer/Winner".text = result_text
	else:
		$"../TurnLabel".text = result_text
