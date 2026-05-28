extends Node2D

func _on_options_button_pressed() -> void:
	$Options.visible = true


func _on_play_pressed() -> void:
	$Options.visible = false


func _on_how_to_play_pressed() -> void:
	$HowToPlayPanel.visible = true


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Escenas/MainMenu.tscn")


func _on_exit_game_pressed() -> void:
	get_tree().quit()


func _on_back_button_pressed() -> void:
	$HowToPlayPanel.visible = false
