extends Spatial

onready var player1 = $Player1
onready var player2 = $Player2

signal game_finished()

func _ready():
	
	# Sets proper master/slave relations.
	if get_tree().is_network_server():
		player2.set_network_master(get_tree().get_network_connected_peers()[0])
		
	else:
		player2.set_network_master(get_tree().get_network_unique_id())
		
	
	player1.left = true
	player2.left = false
	
	print("Unique id: ", get_tree().get_network_unique_id())
