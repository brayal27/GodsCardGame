extends Node2D

signal boton_izquierdo_raton_pulsado
signal boton_izquierdo_raton_liberado

var card_manager_reference


func _ready() -> void:
	card_manager_reference = $"../CardManager"


func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			emit_signal("boton_izquierdo_raton_pulsado")
			raycast_en_cursor()
		else:
			emit_signal("boton_izquierdo_raton_liberado")


func raycast_en_cursor():
	var battle_manager = $"../BattleManager"

	if battle_manager.move_selection_active:
		var target_slot = card_manager_reference.raycast_check_for_card_slot()

		if target_slot:
			battle_manager.try_select_move_slot(target_slot)
		else:
			print("No se detectó slot para mover")

		return

	if battle_manager.duel_selection_active:
		var target_slot = card_manager_reference.raycast_check_for_card_slot()

		if target_slot:
			battle_manager.try_select_duel_target(target_slot)
		else:
			print("No se detectó slot objetivo")

		return

	var carta_encontrada = card_manager_reference.raycast_check_for_card()

	if carta_encontrada:
		card_manager_reference.start_drag(carta_encontrada)
