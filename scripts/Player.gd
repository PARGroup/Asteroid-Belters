extends Spatial

export var left = false

const DASH_VEL = 30;
const DASH_SPD = 0.2;
const DASH_ACL = 10;
const KNOCKBACK_VEL = 15;
const KNOCKBACK_SPD = 0.1;
const KNOCKBACK_ACL = 8

const LEAP_BACK_SCALE = 0.5

const INPUT_RETENTION_TIME = 0.5

var IDLING = State.new(Vector3(0, 0, 0), 0, Vector3(0, 0, 0), StateType.IDLING)
var DASHING = State.new(Vector3(DASH_VEL, 0, 0), DASH_SPD, Vector3(DASH_ACL, 0, 0), StateType.DASHING)
var KNOCKBACK = State.new(Vector3(KNOCKBACK_VEL, 0, 0), KNOCKBACK_SPD, Vector3(KNOCKBACK_ACL, 0, 0), StateType.KNOCKED_BACK)

var acceleration = Vector3()
var velocity = Vector3()
var movementScale = 0

var currentState = self.IDLING

var stateTime = 0

var health = 100

var inputCountdown = 0

var moveRightRequested = false
var moveLeftRequested = false

func _physics_process(delta):
	
	if is_network_master():
		
		if Input.is_action_just_pressed("move"):
					
			var screenSize = get_viewport().size
			
			var mousePosition = get_viewport().get_mouse_position()
			
			if mousePosition < screenSize / 2:
				moveLeftRequested = true
				moveRightRequested = false
			else:
				moveRightRequested = true
				moveLeftRequested = false
			
		
		match currentState.stateType:
			StateType.IDLING:
				if moveRightRequested:
					
					var scale = 1
					
					if not left:
						scale *= LEAP_BACK_SCALE
					
					set_movement_state(self.DASHING, scale)
					moveRightRequested = false
					
				elif moveLeftRequested:
					
					var scale = -1
					
					if left:
						scale *= LEAP_BACK_SCALE
					
					set_movement_state(self.DASHING, -1)
					moveLeftRequested = false
			
			StateType.DASHING:
				
				stateTime -= delta
				velocity += acceleration * delta
				move_and_slide(velocity, Vector3(0, 1, 0), 0.05, 2)
				
				send_updated_movement()
				
				if get_slide_count() > 0:
					
					stateTime = 0
					
					var collision = get_slide_collision(0)
					var otherPlayer = collision.collider
					
					if otherPlayer.is_class("KinematicBody"):
						match otherPlayer.currentState.stateType:
							StateType.IDLING:
								otherPlayer.hit(self, movementScale)
			
	if inputCountdown > 0:
		
		inputCountdown -= delta
	
	if inputCountdown <= 0:
		inputCountdown = 0
		
		moveRightRequested = false
		moveLeftRequested = false
	
	if stateTime <= 0:
		stateTime = 0
		currentState = self.IDLING

func set_movement_state(state, movementScale):
	
	currentState = state
	self.movementScale = movementScale
	
	velocity = state.velocity * movementScale
	acceleration = state.velocity * movementScale
	stateTime = state.time
	
	send_updated_movement()

func hit(attacker, knockbackScale):
	
	set_movement_state(self.KNOCKBACK, knockbackScale)

slave func set_movement(position, acceleration, velocity, movementScale):
	self.transform.origin = position
	self.acceleration = acceleration
	self.velocity = velocity
	self.movementScale = movementScale

slave func set_state(state):
	currentState = state

func send_updated_state():
	rpc_unreliable("set_state", currentState)

func send_updated_movement():
	rpc_unreliable("set_movement", self.transform.origin, acceleration, velocity, movementScale)

class State:
	
	var velocity
	var time
	var acceleration
	var stateType
	
	func _init(velocity, time, acceleration, stateType):
		self.velocity = velocity
		self.time = time
		self.acceleration = acceleration
		self.stateType = stateType

enum StateType {
	IDLING,
	BLOCKING,
	DASHING,
	KNOCKED_BACK,
	STUNNED,
}
