extends Node2D

# Ancho que se usará como referencia para separar las cartas en la mano
var CARD_WIDTH = 300 

# Posición en Y donde se colocará la mano (parte inferior de la pantalla)
const HAND_Y_POSITION = -100

# Velocidad por defecto de las animaciones (tween)
const speed = 0.1

# Array que almacena las cartas que tiene el jugador en la mano
var enemy_hand = []

# Variable para guardar el centro horizontal de la pantalla
var center_screen_x


# Se ejecuta cuando el nodo entra en la escena
func _ready() -> void:
	# Calcula el centro de la pantalla en el eje X
	center_screen_x = get_viewport().size.x / 2


# Añade una carta a la mano del jugador
func add_card_to_hand(card, move_speed):
	# Si la carta NO está ya en la mano
	if card not in enemy_hand:
		# Se añade al inicio del array (posición 0)
		enemy_hand.insert(0, card)
		
		# Se actualizan las posiciones de todas las cartas
		update_hand_positions(move_speed)
	else:
		# Si ya está, se devuelve a su posición original con animación
		animate_card_to_position(card, card.starting_position, move_speed)


# Recoloca todas las cartas de la mano
func update_hand_positions(move_speed):
	for i in range(enemy_hand.size()):
		# Calcula la nueva posición de cada carta
		var new_position = Vector2(calculate_card_position(i), HAND_Y_POSITION)
		
		var card = enemy_hand[i]
		
		# Guarda la posición como "posición base" de la carta
		card.starting_position = new_position
		# Anima la carta hacia su nueva posición
		animate_card_to_position(card, new_position, move_speed)



# Calcula la posición X de una carta según su índice
func calculate_card_position(index):

	# Distancia máxima y mínima entre cartas
	var max_spacing = 300
	var min_spacing = 120

	# Número de cartas
	var card_count = enemy_hand.size()

	# Ajustar spacing dinámicamente
	var spacing = lerp(
		max_spacing,
		min_spacing,
		clamp((card_count - 1) / 9.0, 0, 1)
	)

	# Anchura total ocupada
	var total_width = (card_count - 1) * spacing

	# Posición X centrada
	var x_offset = center_screen_x - index * spacing + total_width / 2

	return x_offset


# Anima una carta hacia una posición concreta
func animate_card_to_position(card, new_position, move_speed):
	# Crea un tween (animación suave)
	var tween = get_tree().create_tween()
	
	# Anima la propiedad "position" de la carta
	tween.tween_property(card, "position", new_position, move_speed)


# Elimina una carta de la mano
func remove_card_from_hand(card):
	# Si la carta está en la mano
	if card in enemy_hand:
		# Se elimina del array
		enemy_hand.erase(card)
		
		# Se reorganizan las cartas restantes
		update_hand_positions(speed)
