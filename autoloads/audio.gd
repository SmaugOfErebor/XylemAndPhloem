extends Node

var rng = RandomNumberGenerator.new()

onready var audioPlayers: Node = get_tree().get_root().get_node("root_node").get_node("audio_players")

onready var leafSoundPlayer: AudioStreamPlayer = audioPlayers.get_node("leaf_sound_player")
onready var rootSoundPlayer: AudioStreamPlayer = audioPlayers.get_node("root_sound_player")
onready var snipSoundPlayer: AudioStreamPlayer = audioPlayers.get_node("snip_sound_player")
onready var selectSoundPlayer: AudioStreamPlayer = audioPlayers.get_node("select_sound")

func playLeafSound():
	if !snipSoundPlayer.is_playing():
		leafSoundPlayer.pitch_scale = rng.randf_range(0.95, 1.05)
		leafSoundPlayer.play()

func playRootSound():
	if !snipSoundPlayer.is_playing():
		rootSoundPlayer.pitch_scale = rng.randf_range(0.7, 1.0)
		rootSoundPlayer.play()

func playSnipSound():
	snipSoundPlayer.play()

func playSelectSound():
	selectSoundPlayer.play()
