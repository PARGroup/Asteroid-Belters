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
	
	if stateTime > 0:
		move_with_accel(delta)
	
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
			
			inputCountdown = INPUT_RETENTION_TIME
			
		elif Input.is_action_just_pressed("move_right"):
			moveRightRequested = true
			moveLeftRequested = false
			
			inputCountdown = INPUT_RETENTION_TIME
			
		elif Input.is_action_just_pressed("move_left"):
			moveLeftRequested = true
			moveRightRequested = false
			
			inputCountdown = INPUT_RETENTION_TIME
		
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
					
					set_movement_state(self.DASHING, scale)

					moveLeftRequested = false
			
			StateType.DASHING:
				
<<<<<<< HEAD
				var collisionCount = get_slide_count()
				
				if collisionCount > 0:
					
					for i in range(collisionCount):
						
						var collision = get_slide_collision(i)
						var otherPlayer = collision.collider
						
						if otherPlayer.is_class("KinematicBody"):
							
							stateTime = 0
							
							match otherPlayer.currentState.stateType:
								StateType.IDLING:
									attack(otherPlayer, movementScale)
						
					
					
			
		if inputCountdown > 0:
			
			inputCountdown -= delta
		
		if inputCountdown <= 0:
			inputCountdown = 0
			
			moveRightRequested = false
			moveLeftRequested = false
		
		if stateTime <= 0:
			stateTime = 0
			
			if currentState != self.IDLING:
				currentState = self.IDLING
				send_updated_state()

func move_with_accel(delta):
	
	if currentState.stateType == StateType.KNOCKED_BACK:
		pass
	
	stateTime -= delta
	velocity += acceleration * delta
	move_and_slide(velocity, Vector3(0, 1, 0), 0.05, 1)
	
	send_updated_movement()

func set_movement_state(state, movementScale):
	
	currentState = state
	self.movementScale = movementScale
	stateTime = state.time
	
	velocity = state.velocity * movementScale
	acceleration = state.acceleration * movementScale
	
	send_updated_state()
	send_updated_movement()

func attack(target, knockbackScale):
	# using target to call rpc makes a huge difference.
	target.rpc("attacked", get_tree().get_network_unique_id(), knockbackScale)

master func attacked(attackerId, knockbackScale):
	set_movement_state(self.KNOCKBACK, knockbackScale)

sync func set_movement(position, acceleration, velocity, movementScale):
	self.transform.origin = position
	self.acceleration = acceleration
	self.velocity = velocity
	self.movementScale = movementScale

sync func set_state(state, time):
	currentState = State.from_dict(state)
	stateTime = time

func send_updated_state():
	rpc("set_state", currentState.to_dict(), stateTime)

func send_updated_movement():
	rpc("set_movement", self.transform.origin, acceleration, velocity, movementScale)

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
	
	func to_dict():
		return {
			"velocity": velocity,
			"time": time,
			"acceleration": acceleration,
			"stateType": stateType
		}
	
	static func from_dict(dict):
		return new(dict.velocity, dict.time, dict.acceleration, dict.stateType)

enum StateType {
	IDLING,
	#BLOCKING,
	DASHING,
	KNOCKED_BACK,
	#STUNNED,
}
