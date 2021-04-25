extends TextureButton

var musicEnabled: bool = true

func _on_music_toggle_button_pressed():
	# First toggle the enabled bool
	musicEnabled = !musicEnabled
	# Apply the new value globally
	Audio.setMusicMute(musicEnabled)
	# Show the proper texture based on the mute state
	if musicEnabled:
		texture_normal = load("res://images/music_button_on.png")
	else:
		texture_normal = load("res://images/music_button_off.png")
