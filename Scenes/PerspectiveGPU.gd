extends Node

onready var mmi: MultiMeshInstance = $MultiMeshInstance
onready var mat : Material = mmi.multimesh.mesh.surface_get_material(0)

var points : PoolVector3Array = []

func _ready() -> void:
	
	for x in range(20):
		for y in range(20):
			for z in range(20):
				points.append(Vector3(x,y,z)/2.0)
	
	var inst_count := points.size()
	
	mmi.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	mmi.multimesh.custom_data_format = MultiMesh.CUSTOM_DATA_NONE
	mmi.multimesh.color_format = MultiMesh.COLOR_NONE
	mmi.multimesh.instance_count = inst_count
	mmi.multimesh.visible_instance_count = inst_count
	
	for i in mmi.multimesh.instance_count:
		mmi.multimesh.set_instance_transform(i,Transform(Basis(), points[i]))

var globPos : Vector3
var globRot : Vector3
var surface : Vector3 = Vector3(0,0,1)

var cam_basis : Basis

func _process(delta: float) -> void:
	
	update_cam_basis()
	var inv_basis := cam_basis.inverse()
	
	if !Input.is_action_pressed("p_modifySurface"):
		
		globPos += inv_basis.x * Input.get_axis("p_left","p_right") * delta
		globPos += inv_basis.y * Input.get_axis("p_below","p_above") * delta
		globPos += inv_basis.z * Input.get_axis("p_down","p_up") * delta
		
		mat.set_shader_param("globPos",globPos)
		
	else:
		
		surface += Vector3(
			Input.get_axis("p_left","p_right"),
			Input.get_axis("p_above","p_below"),
			Input.get_axis("p_down","p_up")
		) * delta
		
		mat.set_shader_param("surface",surface)
		

func _unhandled_input(event: InputEvent) -> void:
	
	if event is InputEventKey:
		
		if event.scancode == KEY_ESCAPE && event.pressed:
			if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			else:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if event is InputEventMouseMotion:
		
		globRot.y += event.relative.x * 0.002
		globRot.x += event.relative.y * 0.002
		
		mat.set_shader_param("globRot",globRot)

func update_cam_basis():
	
	var camTX := Basis(
		Vector3(1,0,0),
		Vector3(0,cos(globRot.x),-sin(globRot.x)),
		Vector3(0,sin(globRot.x),cos(globRot.x))
	)
	var camTY := Basis(
		Vector3(cos(globRot.y),0,sin(globRot.y)),
		Vector3(0,1,0),
		Vector3(-sin(globRot.y),0,cos(globRot.y))
	)
	var camTZ := Basis(
		Vector3(cos(globRot.z),sin(globRot.z),0),
		Vector3(-sin(globRot.z),cos(globRot.z),0),
		Vector3(0,0,1)
	)

	cam_basis = camTX*camTY*camTZ;
