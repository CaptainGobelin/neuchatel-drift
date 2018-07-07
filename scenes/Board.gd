extends Node2D

export(String) var msg = "Je suis un panneau."

var show_message = false

func _ready():
	get_node("FondPanneau/TextePanneau").set_text(msg)
	set_fixed_process(true)

# Si le joueur entre dans la zone on peut afficher le message
func _on_Area2D_body_enter( body ):
	if body.is_in_group("Player"):
		show_message = true
		get_node("AnimationPlayer").play("show_label")

func _on_Area2D_body_exit( body ):
	if body.is_in_group("Player"):
		show_message = false
		get_node("AnimationPlayer").play("hide_label")

# Si on peut afficher le message et que le joueur appuie sur read
# on affiche le message
func _fixed_process(delta):
	get_node("FondPanneau").set_hidden(not (Input.is_action_pressed("read") and show_message == true))
