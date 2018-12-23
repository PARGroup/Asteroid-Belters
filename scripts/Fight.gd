extends Spatial

signal game_finished()

func _ready():
	
	if get_tree().is_network_server():
		$Player2.set_network_master(get_tree().get_network_connected_peers()[0])
	else:
		$Player2.set_network_master(get_tree().get_network_unique_id())
	
	$Player1.left = true
	$Player2.left = false
	
	print("Unique id: ", get_tree().get_network_unique_id())
