extends Node3D

var rng = RandomNumberGenerator.new()

func _ready():
    rng.randomize()
    _create_environment()
    _create_city()
    _create_player()
    _create_vehicle()
    print("STREET RUSH 3D: CITY INITIALIZED")

func _create_environment():
    var world = WorldEnvironment.new()
    var environment = Environment.new()
    environment.background_mode = Environment.BG_SKY
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color(0.65, 0.72, 0.85)
    environment.ambient_light_energy = 0.7

    var sky = Sky.new()
    var sky_material = ProceduralSkyMaterial.new()
    sky.sky_material = sky_material
    environment.sky = sky
    world.environment = environment
    add_child(world)

    var sun = DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48, -32, 0)
    sun.light_energy = 1.1
    sun.shadow_enabled = true
    add_child(sun)

func _create_city():
    # Main ground
    _add_box(
        Vector3(240, 1, 240),
        Vector3(0, -0.5, 0),
        Color(0.18, 0.24, 0.19),
        true
    )

    # Main roads
    _add_box(
        Vector3(240, 0.08, 12),
        Vector3(0, 0.03, 0),
        Color(0.12, 0.13, 0.15)
    )

    _add_box(
        Vector3(12, 0.08, 240),
        Vector3(0, 0.04, 0),
        Color(0.12, 0.13, 0.15)
    )

    # Road markings
    for i in range(-10, 11):
        _add_box(
            Vector3(5, 0.025, 0.22),
            Vector3(i * 11, 0.09, 0),
            Color(0.95, 0.88, 0.55)
        )
        _add_box(
            Vector3(0.22, 0.025, 5),
            Vector3(0, 0.10, i * 11),
            Color(0.95, 0.88, 0.55)
        )

    # Procedurally generated city buildings
    for x in range(-4, 5):
        for z in range(-4, 5):
            var px = x * 24.0
            var pz = z * 24.0

            # Leave roads and central player area clear
            if abs(px) < 13 or abs(pz) < 13:
                continue

            var width = rng.randf_range(10.0, 17.0)
            var depth = rng.randf_range(10.0, 17.0)
            var height = rng.randf_range(9.0, 34.0)

            var colors = [
                Color(0.62, 0.57, 0.49),
                Color(0.48, 0.55, 0.62),
                Color(0.72, 0.68, 0.59),
                Color(0.37, 0.43, 0.48),
                Color(0.66, 0.48, 0.35)
            ]

            var material = colors[rng.randi_range(0, colors.size() - 1)]

            _add_building(
                Vector3(width, height, depth),
                Vector3(px, height / 2.0, pz),
                material
            )

func _add_box(size: Vector3, position: Vector3, color: Color, collision := false):
    var mesh_instance = MeshInstance3D.new()
    var mesh = BoxMesh.new()
    mesh.size = size
    mesh_instance.mesh = mesh

    var material = StandardMaterial3D.new()
    material.albedo_color = color
    mesh_instance.material_override = material
    mesh_instance.position = position
    add_child(mesh_instance)

    if collision:
        var body = StaticBody3D.new()
        var shape_node = CollisionShape3D.new()
        var shape = BoxShape3D.new()
        shape.size = size
        shape_node.shape = shape
        body.position = position
        body.add_child(shape_node)
        add_child(body)

func _add_building(size: Vector3, position: Vector3, color: Color):
    var body = StaticBody3D.new()
    body.position = position

    var mesh_instance = MeshInstance3D.new()
    var mesh = BoxMesh.new()
    mesh.size = size
    mesh_instance.mesh = mesh

    var material = StandardMaterial3D.new()
    material.albedo_color = color
    material.metallic = 0.12
    material.roughness = 0.75
    mesh_instance.material_override = material
    body.add_child(mesh_instance)

    var collision = CollisionShape3D.new()
    var shape = BoxShape3D.new()
    shape.size = size
    collision.shape = shape
    body.add_child(collision)

    add_child(body)

func _create_player():
    var player = CharacterBody3D.new()
    player.name = "Player"
    player.set_script(load("res://scripts/player.gd"))
    player.position = Vector3(0, 0.1, 0)
    add_child(player)


func _create_vehicle():
    var vehicle = CharacterBody3D.new()
    vehicle.name = "PlayerVehicle"
    vehicle.set_script(load("res://scripts/vehicle.gd"))
    vehicle.position = Vector3(0, 0.05, 8)
    add_child(vehicle)
