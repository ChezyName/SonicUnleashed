extends RigidBody3D

const SpinSpeed = 16;
const GroundSpeed = 24;
const AirSpeed = 14;
const SlowDownPercentage = 0.75;
const AirControlPercentage = 0.6;

var facingForward = true;
var ForceGravity = 0;

var SonicMesh:Node3D;
var MeshHolder:Node3D;
var GroundCheck:RayCast3D;
var Animator:AnimationPlayer;
var Spedometer:RichTextLabel;

@export var SpeedMS:int = 0;

# Called when the node enters the scene tree for the first time.
func _ready():
	SonicMesh = get_node("MeshHolder/SonicMesh");
	GroundCheck = get_node("GroundCheck")
	Animator = get_node("MeshHolder/SonicMesh/AnimationPlayer")
	Spedometer = get_node("HUD/Speed")
	MeshHolder = get_node("MeshHolder")
	pass # Replace with function body.

# process velocity and play animation based on that
func PlayAnimation(velocity,OnGround) -> void:
	Animator.speed_scale = abs(velocity.z) / 10;
	# Broke Sound Barrier
	if(abs(velocity.z) > 120): Animator.play("sc_boost");
	elif(abs(velocity.z) > 0): Animator.play("sc_run");
	else: Animator.play("");
	
	if(!OnGround): 
		Animator.play("sc_jump_ball");
		MeshHolder.rotation_degrees.x += 9999;
	else:
		MeshHolder.rotation_degrees.x = 0;
	
	#print(velocity)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var MoveInput:Vector2 = Input.get_vector("Left","Right","Backward","Forward");
	var isOnGround := GroundCheck.is_colliding();
	
	var c_Vel = self.linear_velocity;
	
	var XInput = MoveInput.x;
	if(abs(MoveInput.x) > 0):
		if(abs(c_Vel.z) > 0.5): XInput = MoveInput.x;
		elif((c_Vel.z > 0.5 and MoveInput.x <= -0.5) or (c_Vel.z < -0.5 and MoveInput.x >= 0.5)):
			XInput = -((c_Vel.z * SlowDownPercentage) * 2);
		elif(c_Vel.z <= 0.5 and MoveInput.x <= -0.5):
			XInput = -1;
			facingForward = false;
		else: facingForward = true;
	#elif (MoveInput.x == 0 and abs(c_Vel.z) > 0):
		#XInput = -(c_Vel.z * (SlowDownPercentage*SlowDownPercentage));
	
	c_Vel.z += (XInput * GroundSpeed * delta);
	
	if isOnGround:
		if(Input.is_action_just_pressed("Jump")): c_Vel.y = 6;
	else:
		if(Input.is_action_pressed("Jump")): c_Vel.y -= 5.8 * delta;
		else: c_Vel.y -= 9.8 * delta;
	
	#Set Velecity
	self.linear_velocity = c_Vel;
	Spedometer.text = str(int(abs(c_Vel.z))) + "m/s";
	PlayAnimation(c_Vel,isOnGround)
	
	#Flip Character Based On facingForward
	if(facingForward): SonicMesh.rotation_degrees.y = 0;
	else: SonicMesh.rotation_degrees.y = 180;
	
	pass
