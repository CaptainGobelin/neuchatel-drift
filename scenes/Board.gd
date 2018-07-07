extends Node2D

var show_message = false

func _ready():
	set_fixed_process(true)

# Si le joueur entre dans la zone on peut afficher le message
func _on_Area2D_body_enter( body ):
	if body.is_in_group("Player"):
		show_message = true

# Si on peut afficher le message et que le joueur appuie sur read
# on affiche le message
func _fixed_process(delta):
	if input.is_action_pressed("read") and show_message == true:
		get_child("FondPanneau").set_visible(true)
	show_message = false