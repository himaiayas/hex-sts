class_name TradingSigil
extends BaseArtifact


func _init() -> void:
	super("Trading Sigil", "Merchant and Blacksmith prices are 25% lower.", Enum.ArtifactRarity.RARE,
		preload("res://assets/artifacts/trading_sigil.png"))

const PRICE_FACTOR := 0.75  # RunState.shop_price
