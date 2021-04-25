extends TextureButton

var effectsEnabled = true

func _on_sound_effect_toggle_button_pressed():
	# First toggle the mute bool
	effectsEnabled = !effectsEnabled
	# Apply the new value globally
	Audio.setEffectsMute(effectsEnabled)
	# Show the proper texture based on the mute state
	if effectsEnabled:
		texture_normal = load("res://images/sound_effect_button_on.png")
	else:
		texture_normal = load("res://images/sound_effect_button_off.png")
