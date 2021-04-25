extends AudioStreamPlayer

onready var screenWidth: float = get_viewport().size.x
onready var halfScreenWidth: float = screenWidth / 2
onready var snailbert: AnimatedSprite = Globals.get_snailbert()

func _ready():
	play()

func _process(delta):
	if Audio.musicEnabled:
		volume_db = abs(snailbert.position.x - halfScreenWidth) / halfScreenWidth * -15
	else:
		volume_db = -80
