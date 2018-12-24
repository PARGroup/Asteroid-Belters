extends Spatial

const MOVEMENT_SPEED = 50

export var left = false

var motion = Vector3()

slave func set_pos_and_motion(motion, translation):
	self.motion = motion
	self.translation = translation

func _physics_process(delta):
	
	var screenSize = get_viewport().size
	
	if is_network_master():
		
		motion = Vector3()
		
		if Input.is_action_just_pressed("move"):
			var mousePosition = get_viewport().get_mouse_position()
			
			if mousePosition < screenSize / 2:
				move_left()
			else:
				move_right()
			
			rpc_unreliable("set_pos_and_motion", motion, translation)
		
	
func move_left():
	
	motion = Vector3(-MOVEMENT_SPEED, 0, 0)
	
	move_and_slide(motion)
	

func move_right():
	
	motion = Vector3(MOVEMENT_SPEED, 0, 0)
	
	move_and_slide(motion)