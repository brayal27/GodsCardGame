extends Node2D

signal boton_izquierdo_raton_pulsado
signal boton_izquierdo_raton_liberado

const COLLISION_MASK_CARD =1
const COLLISION_MASK_DECK = 4

var card_manager_reference
var deck_reference

func _ready() -> void:
	card_manager_reference = $"../CardManager"
	deck_reference = $"../Deck"

func _input(event):
	# Comprobamos si es click izquierdo
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		
		if event.pressed:
			emit_signal("boton_izquierdo_raton_pulsado")
			raycast_en_cursor()
		else:
			# Cuando se suelta → soltamos la carta si hay alguna
			emit_signal("boton_izquierdo_raton_liberado")

func raycast_en_cursor():
	var battle_manager = $"../BattleManager"
	
	# Si ya estamos eligiendo objetivo de combate,
	# NO buscamos una carta para arrastrar.
	# Buscamos directamente el slot que hay debajo del ratón.
	if battle_manager.duel_selection_active:
		var target_slot = card_manager_reference.raycast_check_for_card_slot()
		
		if target_slot:
			print("Slot objetivo detectado desde InputManager:", target_slot.name)
			battle_manager.try_select_duel_target(target_slot)
		else:
			print("No se detectó slot objetivo")
		
		return
	
	var carta_encontrada = card_manager_reference.raycast_check_for_card()
	
	if carta_encontrada:
		card_manager_reference.start_drag(carta_encontrada)
