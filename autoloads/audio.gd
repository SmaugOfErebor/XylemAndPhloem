extends Node

onready var audioPlayers: Node = get_tree().get_root().get_node("root_node").get_node("audio_players")

onready var leafSoundPlayer: AudioStreamPlayer = audioPlayers.get_node("leaf_sound_player")

func playLeafSound():
	leafSoundPlayer.play()
