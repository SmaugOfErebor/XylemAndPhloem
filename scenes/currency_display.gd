extends PanelContainer

onready var spendableCurrency: RichTextLabel = $GridContainer/spendable_currency
onready var unspendableCurrency: RichTextLabel = $GridContainer/unspendable_currency

onready var tileMap: TileMap = Globals.get_tiles()

func _process(delta):
	if delta == 0: pass
	
	spendableCurrency.text = "Spendable Currency: " + str(tileMap.playerGameTree.getSpendableAsInt()) + " (" + str(round_to_dec(tileMap.playerGameTree.spendablePerSec, 2)) + " per sec)"
	unspendableCurrency.text = "Unspendable Currency: " + str(tileMap.playerGameTree.getUnspendableAsInt()) + " (" + str(round_to_dec(tileMap.playerGameTree.unspendablePerSec, 2)) + " per sec)"

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
