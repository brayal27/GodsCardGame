extends Node2D



func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Escenas/main.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_how_to_button_pressed() -> void:
	$HowToPlayPanel.visible = true


func _on_back_button_pressed() -> void:
	$HowToPlayPanel.visible = false
