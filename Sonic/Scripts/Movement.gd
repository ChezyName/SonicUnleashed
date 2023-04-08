extends RigidBody3D

const SpinSpeed = 16;
const GroundSpeed = 16;
const AirSpeed = 14;
const SlowDownPercentage = 0.75;
const AirControlPercentage = 0.6;
const SpeedForSuper = 120;

var facingForward = true;
var Rolling = false;
var ForceGravity = 0;

var SonicMesh:Node3D;
var MeshHolder:Node3D;
var GroundCheck:RayCast3D;
var Animator:AnimationPlayer;
var Spedometer:RichTextLabel;
var TotalRings:int;

@export var SpeedMS:int = 0;

func onRing():
	if(abs(self.linear_velocity.z) > 0):
		self.linear_velocity.z += (self.linear_velocity.z * 0.05) + (25 * (self.linear_velocity.z/abs(self.linear_velocity.z)));
	TotalRings += 1

func _ready():
	SonicMesh = get_node("MeshHolder/SonicMesh");
	GroundCheck = get_node("MeshHolder/GroundCheck")
	Animator = get_node("MeshHolder/SonicMesh/AnimationPlayer")
	Spedometer = get_node("HUD/Speed")
	MeshHolder = get_node("MeshHolder")
	pass # Replace with function body.

# process velocity and play animation based on that
func PlayAnimation(velocity,OnGround) -> void:
	if(OnGround and !Rolling):
		Animator.speed_scale = clamp(abs(velocity.z) / 10,0,40);
		MeshHolder.rotation_degrees.x = 0
		if(abs(velocity.z) > SpeedForSuper): Animator.play("sc_boost");
		else: Animator.play("sc_run");
	else:
		Animator.speed_scale = 0;
		Animator.play("sc_jump_ball");
		if(facingForward): MeshHolder.rotation_degrees.x += 250 * clamp(Animator.speed_scale/40,0.1,2);
		else: MeshHolder.rotation_degrees.x -= 250 * clamp(Animator.speed_scale/40,0.1,2);
	
	#print(velocity)

func CameraZoom(speed):
	$Camera3D.fov = 75 * clamp((speed / 80) + 0.2,0.8,1.6)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var MoveInput:Vector2 = Input.get_vector("Left","Right","Backward","Forward");
	var isOnGround := GroundCheck.is_colliding();
	
	var c_Vel = self.linear_velocity;
	
	Rolling = (isOnGround and Input.is_action_pressed("Backward") and int(abs(c_Vel.z)) > 0)
	
	var XInput = MoveInput.x;
	if(!Rolling):
		if(!Input.is_action_pressed("Backward")):
			if(abs(MoveInput.x) > 0):
				if(abs(c_Vel.z) > 0.5): XInput = MoveInput.x;
				elif((c_Vel.z > 0.5 and MoveInput.x <= -0.5) or (c_Vel.z < -0.5 and MoveInput.x >= 0.5)):
					XInput = -((c_Vel.z * SlowDownPercentage) * 2);
				elif(c_Vel.z <= 0.5 and MoveInput.x <= -0.5):
					XInput = -1;
					facingForward = false;
				else: facingForward = true;
			elif (MoveInput.x == 0 and abs(c_Vel.z) > 0):
				if(facingForward): XInput =  -1 * delta;
				else: XInput =  1 * delta;
	
	if(!isOnGround and abs(c_Vel.z) > 0):
		var speedMod = clamp(1 - (c_Vel.z/120),0.1,1)
		var speedReduc = c_Vel.z  * (0.005*(speedMod * 5));
		if(abs(speedReduc) > abs(c_Vel.z)): speedReduc = -c_Vel.z;
		c_Vel.z = speedReduc;
	
	if(Rolling and abs(c_Vel.z) > 2.5): c_Vel.z += abs(c_Vel.z) * 0.005;
	elif(Rolling): c_Vel.z = 0
	elif(isOnGround):
		var speedMod = 1
		if(abs(c_Vel.z) > 0): speedMod = clamp((c_Vel.z/120),0.1,1)
		print(speedMod)
		c_Vel.z += ((XInput * GroundSpeed * delta) / (speedMod * 24)) + (abs(c_Vel.z) * 0.005 * XInput);
		
	c_Vel.z = clamp(c_Vel.z,-400,400);
	
	if isOnGround and Input.is_action_just_pressed("Jump"):
		c_Vel.y = 8 * clamp((abs(c_Vel.z) / 100) + 1,1,1.25);
	elif(!isOnGround and Input.is_action_pressed("Jump")):
		c_Vel.y -= 1.8 * delta;
	elif(!isOnGround):
		c_Vel.y -= 9.8 * delta;
	
	self.linear_velocity = c_Vel;
	
	Spedometer.text = str(int(abs(c_Vel.z))) + "m/s";
	PlayAnimation(c_Vel,isOnGround)
	CameraZoom(abs(self.linear_velocity.z))
	
	""" GROUND ANGLEING
	if(isOnGround): 
		var xform = global_transform
		xform.basis.y = GroundCheck.get_collision_normal()
		xform.basis.x = -xform.basis.z.cross(GroundCheck.get_collision_normal())
		xform.basis = xform.basis.orthonormalized()
		MeshHolder.global_transform = xform;
		$Forward.global_transform = xform;
	"""
	
	#Flip Character Based On facingForward
	if(facingForward): SonicMesh.rotation_degrees.y = 0;
	else: SonicMesh.rotation_degrees.y = 180;
	
	pass
