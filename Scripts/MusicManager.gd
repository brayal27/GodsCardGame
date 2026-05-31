extends Node

var background_music: AudioStreamPlayer

var music_tracks = [
	preload("res://Sound/1. Moonspire.ogg"),
	preload("res://Sound/2. Winds of Valor.ogg"),
	preload("res://Sound/3. Darkwood Path.ogg"),
	preload("res://Sound/4. Frostbound.ogg"),
	preload("res://Sound/5. Emberlight .ogg"),
	preload("res://Sound/6. Silverbrook .ogg"),
	preload("res://Sound/7. Mystic Grove .ogg"),
	preload("res://Sound/8. Throne of Storms .ogg"),
	preload("res://Sound/9. Sorrow’s Edge  .ogg"),
	preload("res://Sound/10. Elven Dawn  .ogg")
]

func _ready():
	print("MusicManager cargado")
	randomize()
	
	background_music = AudioStreamPlayer.new()
	background_music.name = "BackgroundMusic"
	add_child(background_music)
	
	background_music.volume_db = -8
	background_music.bus = "Master"
	background_music.finished.connect(_on_music_finished)
	
	print("Canciones cargadas:", music_tracks.size())
	
	play_random_music()


func play_random_music():
	print("Intentando reproducir música")
	
	if music_tracks.size() == 0:
		print("No hay canciones en music_tracks")
		return
	
	var random_track = music_tracks[randi_range(0, music_tracks.size() - 1)]
	
	print("Canción elegida:", random_track)
	
	background_music.stream = random_track
	background_music.play()
	
	print("¿Está reproduciendo?:", background_music.playing)


func _on_music_finished():
	print("Canción terminada, reproduciendo otra")
	play_random_music()


func stop_music():
	if background_music:
		background_music.stop()


func set_volume(value_db: float):
	if background_music:
		background_music.volume_db = value_db
