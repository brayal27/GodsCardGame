extends Node2D

# Señales personalizadas que emitirá la carta
signal hovered          # Se emite cuando el ratón entra en la carta
signal hovered_off      # Se emite cuando el ratón sale de la carta

var starting_position


# Se ejecuta cuando el nodo entra en la escena por primera vez
func _ready() -> void:
	# Todas las cartas deben ser hijas de CardManager
	# Aquí conectamos las señales de esta carta con el manager
	get_parent().connect_card_signals(self)


# Se ejecuta cada frame (no se está usando ahora mismo)
func _process(delta: float) -> void:
	pass


# Esta función se llama automáticamente cuando el ratón entra en el Area2D de la carta
func _on_area_2d_mouse_entered() -> void:
	# Emitimos la señal "hovered" pasando esta carta como referencia
	emit_signal("hovered", self)


# Esta función se llama cuando el ratón sale del Area2D de la carta
func _on_area_2d_mouse_exited() -> void:
	# Emitimos la señal "hovered_off" pasando esta carta
	emit_signal("hovered_off", self)
