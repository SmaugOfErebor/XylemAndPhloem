extends PanelContainer

onready var spendableCurrency: RichTextLabel = $GridContainer/spendable_currency
onready var unspendableCurrency: RichTextLabel = $GridContainer/unspendable_currency

onready var tileMap: TileMap = Globals.get_tiles()

func _process(delta):
	spendableCurrency.text = "Spendable Currency: " + str(tileMap.playerGameTree.spendableCurrency)
	unspendableCurrency.text = "Unspendable Currency: " + str(tileMap.playerGameTree.unspendableCurrency)
	#print(tileMap.playerGameTree.spendableCurrency)
