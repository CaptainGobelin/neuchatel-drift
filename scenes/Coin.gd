extends Node2D

# Utile dans le ready
onready var player = get_tree().get_root().get_node("Main/Player")

func _ready():
	# Connecte le ramassage de la piece a la scene joueur
	get_node("ImgCoin/AreaCoin").connect("body_enter", player, "gather_coin")

# Quand le joueur ramasse la piece elle disparait
func _on_AreaCoin_body_enter( body ):
	if body.is_in_group("Player"):
		get_node("ImgCoin").queue_free()
	
