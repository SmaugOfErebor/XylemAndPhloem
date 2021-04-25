extends Node

onready var audioPlayers: Node = get_tree().get_root().get_node("root_node").get_node("audio_players")

onready var leafSoundPlayer: AudioStreamPlayer = audioPlayers.get_node("leaf_sound_player")
onready var rootSoundPlayer: AudioStreamPlayer = audioPlayers.get_node("root_sound_player")
onready var snipSoundPlayer: AudioStreamPlayer = audioPlayers.get_node("snip_sound_player")

func playLeafSound():
	if !snipSoundPlayer.is_playing():
		leafSoundPlayer.play()

func playRootSound():
	if !snipSoundPlayer.is_playing():
		rootSoundPlayer.play()

func playSnipSound():
	snipSoundPlayer.play()
