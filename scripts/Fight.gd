extends Spatial

onready var player1 = $Player1
onready var player2 = $Player2

signal game_finished()

func _ready():
	
	# Sets proper master/slave relations.
	if get_tree().is_network_server():
		$Player2.set_network_master(get_tree().get_network_connected_peers()[0])
	else:
		$Player2.set_network_master(get_tree().get_network_unique_id())
	
	$Player1.left = true
	$Player2.left = false
	
	print("Unique id: ", get_tree().get_network_unique_id())
