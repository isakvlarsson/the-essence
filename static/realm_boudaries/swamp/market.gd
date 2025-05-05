extends Sprite2D

@onready var merchant = $MerchantSprite;

func _ready():
    merchant.play("default");
