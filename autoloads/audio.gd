extends Node

var rng = RandomNumberGenerator.new()

var effectsEnabled: bool = true
var musicEnabled: bool = true

onready var audioPlayers: Node = get_tree().get_root().get_node("root_node").get_node("audio_players")

onready var leafSoundPlayer: AudioStreamPlayer = audioPlayers.get_node("leaf_sound_player")
onready var rootSoundPlayer: AudioStreamPlayer = audioPlayers.get_node("root_sound_player")
onready var snipSoundPlayer: AudioStreamPlayer = audioPlayers.get_node("snip_sound_player")
onready var selectSoundPlayer: AudioStreamPlayer = audioPlayers.get_node("select_sound")

onready var bgMusicPlayer: AudioStreamPlayer = audioPlayers.get_node("bg_music_player")
onready var snailbertTomsPlayer: AudioStreamPlayer = audioPlayers.get_node("snailbert_toms_player")

func playLeafSound():
	if !snipSoundPlayer.is_playing() && effectsEnabled:
		leafSoundPlayer.pitch_scale = rng.randf_range(0.95, 1.05)
		leafSoundPlayer.play()

func playRootSound():
	if !snipSoundPlayer.is_playing() && effectsEnabled:
		rootSoundPlayer.pitch_scale = rng.randf_range(0.7, 1.0)
		rootSoundPlayer.play()

func playSnipSound():
	snipSoundPlayer.play()

func playSelectSound():
	if !selectSoundPlayer.is_playing() && effectsEnabled:
		selectSoundPlayer.play()

func setMusicMute(musicEnabled: bool):
	self.musicEnabled = musicEnabled
	if musicEnabled:
		bgMusicPlayer.volume_db = 0
		snailbertTomsPlayer.volume_db = 0
	else:
		bgMusicPlayer.volume_db = -80
		snailbertTomsPlayer.volume_db = -80

func setEffectsMute(effectsEnabled: bool):
	self.effectsEnabled = effectsEnabled
