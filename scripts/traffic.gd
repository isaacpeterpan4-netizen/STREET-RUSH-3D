extends CharacterBody3D

var travel_axis := Vector3.RIGHT
var travel_direction := 1.0
var driving_speed := 9.0
var road_limit := 112.0
var paint_color := Color(0.1, 0.3, 0.8)

func _ready():
    collision_layer = 2
    collision_mask = 1
    _create_car()

func _create_car():
    var collision = CollisionShape3D.new()
    var shape = BoxShape3D.new()
    shape.size = Vector3(1.8, 1.0, 3.5)
    collision.shape = shape
    collision.position.y = 0.65
    add_child(collision)

    _add_part(Vector3(1.9, 0.65, 3.7), Vector3(0, 0.65, 0), paint_color)
    _add_part(Vector3(1.5, 0.65, 1.7), Vector3(0, 1.25, -0.15), Color(0.12, 0.18, 0.23))

    for x in [-0.98, 0.98]:
        for z in [-1.15, 1.15]:
            var wheel = MeshInstance3D.new()
            var mesh = CylinderMesh.new()
            mesh.top_radius = 0.34
            mesh.bottom_radius = 0.34
            mesh.height = 0.22
            wheel.mesh = mesh
            wheel.position = Vector3(x, 0.35, z)
            wheel.rotation.z = deg_to_rad(90)
            var mat = StandardMaterial3D.new()
            mat.albedo_color = Color(0.025, 0.025, 0.025)
            wheel.material_override = mat
            add_child(wheel)

func _add_part(size: Vector3, offset: Vector3, color: Color):
    var visual = MeshInstance3D.new()
    var mesh = BoxMesh.new()
    mesh.size = size
    visual.mesh = mesh
    visual.position = offset
    var mat = StandardMaterial3D.new()
    mat.albedo_color = color
    visual.material_override = mat
    add_child(visual)

func _physics_process(_delta):
    velocity = travel_axis * travel_direction * driving_speed
    move_and_slide()

    if travel_axis.x != 0:
        if global_position.x > road_limit:
            global_position.x = -road_limit
        elif global_position.x < -road_limit:
            global_position.x = road_limit
    else:
        if global_position.z > road_limit:
            global_position.z = -road_limit
        elif global_position.z < -road_limit:
            global_position.z = road_limit
