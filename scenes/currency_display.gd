extends Panel

onready var spendableCurrency: RichTextLabel = $spendable_grid/text
onready var unspendableCurrency: RichTextLabel = $unspendable_grid/text
onready var conversion: RichTextLabel = $conversion_control/text
onready var conversionAnim: AnimatedSprite = $conversion_control/anim

func _ready():
	conversionAnim.play("idle")
	Globals.connect("player_currency_converted", self, "_on_player_currency_converted")

func _process(delta):
	if delta == 0:
		return
	
	var tileMap = Globals.get_tiles()
	unspendableCurrency.text = str(tileMap.playerGameTree.getUnspendableAsInt())
	conversion.text = str(round_to_dec(tileMap.playerGameTree.unspendablePerSec, 2)) + "/sec"
	spendableCurrency.text = str(tileMap.playerGameTree.getSpendableAsInt()) + " (" + str(round_to_dec(tileMap.playerGameTree.spendablePerSec, 2)) + "/sec)"

func _on_player_currency_converted():
	flashConversion()

func flashConversion():
	conversionAnim.play("flow")

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func _on_anim_animation_finished():
	conversionAnim.play("idle")
