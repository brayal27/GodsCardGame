extends Node

# Calcula el ataque real de una carta teniendo en cuenta sus habilidades activas.
func get_card_attack(card, slot, current_turn: String, all_slots: Array) -> int:
	if card == null or slot == null:
		return 0
	
	var final_attack = card.attack
	
	final_attack += get_position_attack_bonus(card, slot)
	final_attack += get_turn_attack_bonus(card, slot, current_turn)
	final_attack += get_isolated_attack_bonus(card, slot, all_slots)
	final_attack += get_support_attack_bonus(slot, all_slots)
	final_attack -= get_weaken_attack_penalty(slot, all_slots)
	
	return max(final_attack, 0)


# Bonus por estar en esquina, lateral o centro.
func get_position_attack_bonus(card, slot) -> int:
	var bonus := 0
	var grid_pos = get_slot_grid_position(slot)
	
	var is_corner = (
		(grid_pos.x == 0 and grid_pos.y == 0)
		or (grid_pos.x == 0 and grid_pos.y == 3)
		or (grid_pos.x == 3 and grid_pos.y == 0)
		or (grid_pos.x == 3 and grid_pos.y == 3)
	)
	
	var is_side = (
		grid_pos.x == 0
		or grid_pos.x == 3
		or grid_pos.y == 0
		or grid_pos.y == 3
	)
	
	var is_center = not is_side
	
	if is_corner and card.has_ability("ESQUINA"):
		bonus += card.get_ability_value("ESQUINA")
	
	if is_side and not is_corner and card.has_ability("LATERAL"):
		bonus += card.get_ability_value("LATERAL")
	
	if is_center and card.has_ability("CENTRO"):
		bonus += card.get_ability_value("CENTRO")
	
	return bonus


# Bonus según si la carta está en su turno o en el turno rival.
func get_turn_attack_bonus(card, slot, current_turn: String) -> int:
	var bonus := 0
	
	if current_turn == slot.slot_owner:
		if card.has_ability("OFENSIVO"):
			bonus += card.get_ability_value("OFENSIVO")
	else:
		if card.has_ability("DEFENSIVO"):
			bonus += card.get_ability_value("DEFENSIVO")
	
	return bonus


# Bonus si la carta no tiene ninguna unidad adyacente.
func get_isolated_attack_bonus(card, slot, all_slots: Array) -> int:
	if not card.has_ability("AISLADO"):
		return 0
	
	var adjacent_units = get_adjacent_slots_with_cards(slot, all_slots)
	
	if adjacent_units.size() == 0:
		return card.get_ability_value("AISLADO")
	
	return 0


# Suma el apoyo de unidades aliadas adyacentes.
func get_support_attack_bonus(slot, all_slots: Array) -> int:
	var bonus := 0
	
	for other_slot in all_slots:
		if other_slot == slot:
			continue
		
		if other_slot.current_card == null:
			continue
		
		if other_slot.slot_owner != slot.slot_owner:
			continue
		
		if not are_slots_adjacent(slot, other_slot):
			continue
		
		var support_card = other_slot.current_card
		
		if support_card.has_ability("APOYO"):
			bonus += support_card.get_ability_value("APOYO")
	
	return bonus


# Resta ataque por unidades enemigas adyacentes con Debilitar.
func get_weaken_attack_penalty(slot, all_slots: Array) -> int:
	var penalty := 0
	
	for other_slot in all_slots:
		if other_slot == slot:
			continue
		
		if other_slot.current_card == null:
			continue
		
		if other_slot.slot_owner == slot.slot_owner:
			continue
		
		if not are_slots_adjacent(slot, other_slot):
			continue
		
		var enemy_card = other_slot.current_card
		
		if enemy_card.has_ability("DEBILITAR"):
			penalty += enemy_card.get_ability_value("DEBILITAR")
	
	return penalty


# Devuelve cualquier slot adyacente que tenga carta.
func get_adjacent_slots_with_cards(slot, all_slots: Array) -> Array:
	var result := []
	
	for other_slot in all_slots:
		if other_slot == slot:
			continue
		
		if not other_slot.card_in_slot:
			continue
		
		if are_slots_adjacent(slot, other_slot):
			result.append(other_slot)
	
	return result


# Saco la posición del slot a partir del nombre CardSlotXY.
func get_slot_grid_position(slot) -> Vector2i:
	var slot_name := str(slot.name)
	
	var row := int(slot_name.substr(slot_name.length() - 2, 1))
	var col := int(slot_name.substr(slot_name.length() - 1, 1))
	
	return Vector2i(row, col)


# Comprueba si dos slots están juntos en vertical u horizontal.
func are_slots_adjacent(slot_a, slot_b) -> bool:
	var pos_a = get_slot_grid_position(slot_a)
	var pos_b = get_slot_grid_position(slot_b)
	
	var distance = abs(pos_a.x - pos_b.x) + abs(pos_a.y - pos_b.y)
	
	return distance == 1
