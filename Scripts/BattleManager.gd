extends Node

const speed = 0.2

var battle_timer
var empty_slot = []

var current_turn := "player"

var player_roll
var opponent_roll

var roll_panel 
var player_roll_label 
var opponent_roll_label 
var roll_result_label 
var fin_turno_button
var turn_label 

var turn_number := 1
var turns_finished_this_round := 0
var hostilities_started := false

var player_kills := 0
var opponent_kills := 0

var duel_selection_active := false
var selected_attacker_slot = null


func _ready() -> void:
	randomize()
	
	battle_timer = $"../BattleTimer"
	battle_timer.one_shot = true
	battle_timer.wait_time = 1.0
	
	empty_slot.append($"../Card_slots/CardSlot00")
	empty_slot.append($"../Card_slots/CardSlot01")
	empty_slot.append($"../Card_slots/CardSlot02")
	empty_slot.append($"../Card_slots/CardSlot03")
	empty_slot.append($"../Card_slots/CardSlot10")
	empty_slot.append($"../Card_slots/CardSlot11")
	empty_slot.append($"../Card_slots/CardSlot12")
	empty_slot.append($"../Card_slots/CardSlot13")
	empty_slot.append($"../Card_slots/CardSlot20")
	empty_slot.append($"../Card_slots/CardSlot21")
	empty_slot.append($"../Card_slots/CardSlot22")
	empty_slot.append($"../Card_slots/CardSlot23")
	empty_slot.append($"../Card_slots/CardSlot30")
	empty_slot.append($"../Card_slots/CardSlot31")
	empty_slot.append($"../Card_slots/CardSlot32")
	empty_slot.append($"../Card_slots/CardSlot33")
	
	update_turn_label()
	update_kill_labels()
	start_initial_roll()


func start_initial_roll() -> void:
	roll_panel = $"../RollPanel"
	player_roll_label = $"../RollPanel/VBoxContainer/PlayerRollLabel"
	opponent_roll_label = $"../RollPanel/VBoxContainer/OpponentRollLabel"
	roll_result_label = $"../RollPanel/VBoxContainer/RollResultLabel"
	fin_turno_button = $"../FinTurno"
	
	fin_turno_button.visible = false
	fin_turno_button.disabled = true
	
	roll_panel.visible = true
	player_roll_label.text = "Jugador: -"
	opponent_roll_label.text = "Rival: -"
	roll_result_label.text = "Realizando sorteo..."
	
	battle_timer.start()
	await battle_timer.timeout
	
	roll_starting_player()


func roll_starting_player() -> void:
	battle_timer.wait_time = 2.0
	
	player_roll = randi_range(1, 20)
	opponent_roll = randi_range(1, 20)
	
	player_roll_label.text = "Jugador: " + str(player_roll)
	opponent_roll_label.text = "Rival: " + str(opponent_roll)
	
	if player_roll > opponent_roll:
		roll_result_label.text = "Empieza el jugador"
		
		battle_timer.start()
		await battle_timer.timeout
		
		start_player_turn()
	
	elif opponent_roll > player_roll:
		roll_result_label.text = "Empieza el rival"
		
		battle_timer.start()
		await battle_timer.timeout
		
		roll_panel.visible = false
		opponent_turn()
	
	else:
		roll_result_label.text = "Empate. Repitiendo sorteo..."
		
		battle_timer.start()
		await battle_timer.timeout
		
		roll_starting_player()


func start_player_turn() -> void:
	current_turn = "player"
	roll_panel.visible = false
	
	duel_selection_active = false
	selected_attacker_slot = null
	
	$"../FinTurno".visible = true
	$"../FinTurno".disabled = false
	
	print("Empieza el turno del jugador")


func _on_fin_turno_pressed() -> void:
	if current_turn != "player":
		return
	
	end_player_turn()


func end_player_turn() -> void:
	current_turn = "opponent"
	
	duel_selection_active = false
	selected_attacker_slot = null
	
	# Al acabar el turno, el jugador roba hasta volver a tener 4 cartas.
	$"../Deck".draw_until_hand_full()
	
	register_turn_finished()
	
	$"../FinTurno".visible = false
	$"../FinTurno".disabled = true
	
	opponent_turn()


func opponent_turn() -> void:
	current_turn = "opponent"
	
	duel_selection_active = false
	selected_attacker_slot = null
	
	$"../FinTurno".visible = false
	$"../FinTurno".disabled = true
	
	battle_timer.start()
	await battle_timer.timeout
	
	# El rival roba al empezar su turno para asegurarse de tener cartas.
	$"../OpponentDeck".draw_until_hand_full()
	
	if empty_slot.size() == 0:
		await opponent_try_all_possible_duels()
		end_opponent_turn()
		return
	
	await play_card_high_might()
	
	await opponent_try_all_possible_duels()
	
	# Opcional: vuelve a robar al final para quedarse con 4 cartas.
	$"../OpponentDeck".draw_until_hand_full()
	await battle_timer.start
	
	end_opponent_turn()


func end_opponent_turn() -> void:
	register_turn_finished()
	
	current_turn = "player"
	
	$"../FinTurno".visible = true
	$"../FinTurno".disabled = false
	
	print("Empieza el turno del jugador")


func register_turn_finished() -> void:
	turns_finished_this_round += 1
	
	if turns_finished_this_round >= 2:
		turns_finished_this_round = 0
		advance_turn()
	else:
		update_turn_label()


func advance_turn() -> void:
	turn_number += 1
	
	if turn_number >= 4:
		hostilities_started = true
	
	update_turn_label()


func update_turn_label() -> void:
	turn_label = $"../TurnLabel"
	
	if hostilities_started:
		turn_label.text = "Turno " + str(turn_number) + " - Hostilidades activas"
	else:
		turn_label.text = "Turno " + str(turn_number) + " - Preparación"


func play_card_high_might():
	var enemy_hand = $"../EnemyHand".enemy_hand
	
	if enemy_hand.size() == 0:
		return
	
	if empty_slot.size() == 0:
		return
	
	var random_empty_slot = empty_slot[randi_range(0, empty_slot.size() - 1)]
	
	while random_empty_slot.card_in_slot and empty_slot.size() > 0:
		empty_slot.erase(random_empty_slot)
		
		if empty_slot.size() == 0:
			return
		
		random_empty_slot = empty_slot[randi_range(0, empty_slot.size() - 1)]
	
	var card_with_high_might = enemy_hand[0]
	
	for card in enemy_hand:
		if card.attack > card_with_high_might.attack:
			card_with_high_might = card
	
	empty_slot.erase(random_empty_slot)
	
	var placed = random_empty_slot.place_card(card_with_high_might, false, "opponent")
	
	if not placed:
		return
	
	var board_card_scale := Vector2(0.7, 0.6)
	
	card_with_high_might.z_index = 1
	card_with_high_might.starting_position = random_empty_slot.global_position
	
	var tween = get_tree().create_tween()
	
	tween.parallel().tween_property(
		card_with_high_might,
		"global_position",
		random_empty_slot.global_position,
		speed
	)
	
	tween.parallel().tween_property(
		card_with_high_might,
		"scale",
		board_card_scale,
		speed
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
	


func handle_board_card_clicked(card):
	print("Click en carta de mesa:", card.name)
	
	if current_turn != "player":
		print("No es tu turno")
		return
	
	if not hostilities_started:
		print("No puedes iniciar duelos hasta el turno 4")
		return
	
	if card.current_slot == null:
		print("Esta carta no tiene slot asignado")
		return
	
	var clicked_slot = card.current_slot
	
	print("Slot clicado:", clicked_slot.name)
	print("Dueño del slot:", clicked_slot.slot_owner)
	print("Modo selección activo:", duel_selection_active)
	
	if not duel_selection_active:
		try_reveal_card_for_duel(clicked_slot)
	else:
		try_select_duel_target(clicked_slot)


func try_reveal_card_for_duel(slot):
	print("Intentando iniciar duelo con carta:", slot.name)
	
	if slot.slot_owner != "player":
		print("Solo puedes usar tus propias cartas")
		return
	
	if slot.current_card == null:
		print("Este slot no tiene carta")
		return
	
	var enemy_slots = get_adjacent_enemy_slots(slot)
	
	print("Enemigos cercanos encontrados:", enemy_slots.size())
	
	if enemy_slots.size() == 0:
		print("No hay cartas enemigas cerca")
		return
	
	if slot.current_card.is_face_down:
		slot.current_card.reveal_card()
	
	selected_attacker_slot = slot
	duel_selection_active = true
	
	print("Carta preparada para combatir:", slot.current_card.get_node("Nombre").text)
	print("Selecciona una carta enemiga cercana para iniciar el duelo.")


func try_select_duel_target(target_slot):
	print("Intentando seleccionar objetivo:", target_slot.name)
	
	if selected_attacker_slot == null:
		print("No hay carta atacante seleccionada")
		duel_selection_active = false
		return
	
	if target_slot.current_card == null:
		print("Ese slot no tiene carta")
		return
	
	print("Atacante:", selected_attacker_slot.name, selected_attacker_slot.slot_owner)
	print("Objetivo:", target_slot.name, target_slot.slot_owner)
	
	if target_slot.slot_owner == selected_attacker_slot.slot_owner:
		print("Debes seleccionar una carta enemiga")
		return
	
	if not are_slots_adjacent(selected_attacker_slot, target_slot):
		print("La carta enemiga no está cerca")
		return
	
	print("Objetivo válido. Iniciando duelo.")
	
	start_duel(selected_attacker_slot, target_slot)
	
	selected_attacker_slot = null
	duel_selection_active = false


func check_for_duel(slot):
	if not hostilities_started:
		print("Todavía no pueden empezar las hostilidades")
		return
	
	if slot.current_card == null:
		return
	
	var enemy_slots = get_adjacent_enemy_slots(slot)
	
	if enemy_slots.size() == 0:
		print("No hay enemigos cerca")
		return
	
	var enemy_slot = enemy_slots[0]
	start_duel(slot, enemy_slot)

func opponent_try_start_duel(attacker_slot):
	if not hostilities_started:
		print("El rival no puede combatir todavía")
		return
	
	if attacker_slot == null:
		return
	
	if attacker_slot.current_card == null:
		return
	
	if attacker_slot.slot_owner != "opponent":
		print("El atacante del rival no pertenece al rival")
		return
	
	var player_slots = get_adjacent_enemy_slots(attacker_slot)
	
	print("Rival busca enemigos cercanos:", player_slots.size())
	
	if player_slots.size() == 0:
		print("El rival no tiene objetivos cercanos")
		return
	
	var best_target = player_slots[0]
	
	for slot in player_slots:
		if slot.current_card.attack > best_target.current_card.attack:
			best_target = slot
	
	print("El rival inicia combate:")
	print(attacker_slot.current_card.get_node("Nombre").text, " contra ", best_target.current_card.get_node("Nombre").text)
	
	start_duel(attacker_slot, best_target)

func opponent_try_any_duel():
	if not hostilities_started:
		return
	
	var opponent_slots := []
	
	for slot in get_all_slots():
		if slot.card_in_slot and slot.slot_owner == "opponent":
			var targets = get_adjacent_enemy_slots(slot)
			
			if targets.size() > 0:
				opponent_slots.append(slot)
	
	if opponent_slots.size() == 0:
		print("El rival no tiene ningún combate disponible")
		return
	
	var attacker_slot = opponent_slots[0]
	
	for slot in opponent_slots:
		if slot.current_card.attack > attacker_slot.current_card.attack:
			attacker_slot = slot
	
	opponent_try_start_duel(attacker_slot)

func opponent_try_all_possible_duels():
	if not hostilities_started:
		print("El rival no puede combatir todavía")
		return
	
	var duels_done := 0
	var keep_fighting := true
	
	while keep_fighting:
		keep_fighting = false
		
		var best_attacker_slot = null
		var best_target_slot = null
		var best_score := -999999
		
		for attacker_slot in get_all_slots():
			if attacker_slot.current_card == null:
				continue
			
			if attacker_slot.slot_owner != "opponent":
				continue
			
			var possible_targets = get_adjacent_enemy_slots(attacker_slot)
			
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
			print(
				best_attacker_slot.current_card.get_node("Nombre").text,
				" contra ",
				best_target_slot.current_card.get_node("Nombre").text
			)
			
			start_duel(best_attacker_slot, best_target_slot)
			duels_done += 1
			keep_fighting = true
			
			await get_tree().create_timer(0.4).timeout
	
	print("Combates del rival realizados:", duels_done)


func start_duel(attacker_slot, defender_slot):
	var attacker = attacker_slot.current_card
	var defender = defender_slot.current_card
	
	if attacker == null or defender == null:
		return
	
	print("DUELO INICIADO")
	print(attacker.get_node("Nombre").text, " VS ", defender.get_node("Nombre").text)
	
	if attacker.is_face_down:
		attacker.reveal_card()
	
	if defender.is_face_down:
		defender.reveal_card()
	
	var attacker_power = attacker.attack
	var defender_power = defender.attack
	
	if attacker_power > defender_power:
		kill_card(defender_slot)
	elif defender_power > attacker_power:
		kill_card(attacker_slot)
	else:
		print("Empate: mueren ambas")
		kill_card(defender_slot)
		kill_card(attacker_slot)


func get_adjacent_enemy_slots(slot) -> Array:
	var result := []
	
	for other_slot in get_all_slots():
		if other_slot == slot:
			continue
		
		if not other_slot.card_in_slot:
			continue
		
		if other_slot.slot_owner == slot.slot_owner:
			continue
		
		if are_slots_adjacent(slot, other_slot):
			result.append(other_slot)
	
	return result


func get_slot_grid_position(slot) -> Vector2i:
	var slot_name := str(slot.name)
	
	var row := int(slot_name.substr(slot_name.length() - 2, 1))
	var col := int(slot_name.substr(slot_name.length() - 1, 1))
	
	return Vector2i(row, col)


func are_slots_adjacent(slot_a, slot_b) -> bool:
	var pos_a = get_slot_grid_position(slot_a)
	var pos_b = get_slot_grid_position(slot_b)
	
	var distance = abs(pos_a.x - pos_b.x) + abs(pos_a.y - pos_b.y)
	
	return distance == 1


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

func is_valid_duel_target_card(card) -> bool:
	if not duel_selection_active:
		return false
	
	if selected_attacker_slot == null:
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
	
	if target_slot.slot_owner == selected_attacker_slot.slot_owner:
		return false
	
	if not are_slots_adjacent(selected_attacker_slot, target_slot):
		return false
	
	return true

func kill_card(slot):
	var card = slot.current_card
	
	if card == null:
		return
	
	print("Carta derrotada:", card.get_node("Nombre").text)
	
	if slot.slot_owner == "player":
		opponent_kills += 1
	else:
		player_kills += 1
	
	update_kill_labels()
	
	slot.remove_card()
	
	if slot not in empty_slot:
		empty_slot.append(slot)
	
	card.queue_free()
	
	if player_kills >= 7:
		print("Gana el jugador")
	
	if opponent_kills >= 7:
		print("Gana el rival")


func update_kill_labels():
	$"../Marcador/PlayerKillsLabel".text = "Jugador: " + str(player_kills) + "/7"
	$"../Marcador/OpponentKillsLabel".text = "Rival: " + str(opponent_kills) + "/7"
