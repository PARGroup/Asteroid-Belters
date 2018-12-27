extends Control

const PORT = 18271

onready var addressLineEdit = $AddressLineEdit

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connection_success")
	get_tree().connect("connection_failed", self, "_connection_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	

func _player_connected(id):
	
	var fight = load("res://scenes/Fight.tscn").instance()
	
	fight.connect("game_finished", self, "_end_game", [], CONNECT_DEFERRED)
	
	fight.set_connected_player_id(id)
	
	get_tree().get_root().add_child(fight)
	hide()
	
	print("Player connected with id:", id)

func _player_disconnected(id):
	
	if get_tree().is_network_server():
		_end_game("Client Disconnected.")
	else:
		_end_game("Server Disconnected.")
	
	
	pass

func _end_game(with_error = ""):
	
	if has_node("/root/Fight"):
		get_node("/root/Fight").free()
		show()
	
	get_tree().set_network_peer(null)
	
	$JoinButton.set_disabled(false)
	$HostButton.set_disabled(false)
	

func _connection_success():
	pass

func _connection_fail():
	get_tree().set_network_peer(null)
	
	$JoinButton.set_disabled(false)
	$HostButton.set_disabled(false)

func _server_disconnected():
	_end_game("Server Disconnected.")

func _on_JoinButton_pressed():
	
	var ip = addressLineEdit.get_text()
	
	if not ip.is_valid_ip_address():
		print("Invalid ip.")
		return
	
	var host = NetworkedMultiplayerENet.new()
	var err = host.create_client(ip, PORT)
	
	if err != OK:
		print("error while client connecting: ", err)
	
	get_tree().set_network_peer(host)
	

func _on_HostButton_pressed():
	
	var host = NetworkedMultiplayerENet.new()
	
	var err = host.create_server(PORT, 1)
	
	if err != OK:
		print("Address in use, unable to host.")
		return
	
	get_tree().set_network_peer(host)
	$JoinButton.set_disabled(true)
	$HostButton.set_disabled(true)
	
	print("Waiting for a player to connect...")
	
