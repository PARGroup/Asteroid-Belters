extends Spatial

onready var player1 = $Player1
onready var player2 = $Player2

var otherPlayerId = -1

signal game_finished()

func _ready():
	
	var selfPlayerId = get_tree().get_network_unique_id()
	
	# Sets proper master/slave relations.
	if get_tree().is_network_server():
		#$Player1.set_network_master(get_tree().get_network_unique_id())
		player2.set_network_master(otherPlayerId)
		
		player1.id = selfPlayerId
		player2.id = otherPlayerId
	
	else:
		#$Player1.set_network_master(otherPlayerId)
		player2.set_network_master(selfPlayerId)
		
		player1.id = otherPlayerId
		player2.id = selfPlayerId
		
	
	player1.left = true
	player2.left = false
	
	print("Unique id: ", get_tree().get_network_unique_id())

func set_connected_player_id(id):
	otherPlayerId = id
