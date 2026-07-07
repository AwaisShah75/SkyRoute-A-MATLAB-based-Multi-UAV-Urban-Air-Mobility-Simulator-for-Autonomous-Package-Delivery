# blender_full_scene_builder.py
# Paste this script into Blender's "Scripting" tab and run it.
# It automatically reads simulation_metadata.json to build:
# 1. A 40-skyscraper city layout matching MATLAB exactly.
# 2. 10 detailed drones with spinning propellers, custom colors, and individual follow-paths.
# 3. 20 dynamic delivery landing rings and "Delivered!" text flags popping up at exact frames.
# 4. Dynamic warning obstacles appearing mid-simulation.
# 5. An orbiting cinematic wide-angle camera capturing all activity.

import bpy
import csv
import os
import math
import ssl
import json

# Bypass SSL certificate verification for downloads (fixes Windows download block)
ssl._create_default_https_context = ssl._create_unverified_context

# --- 1. CONFIGURATION & METADATA LOAD ---
FOLDER_PATH = "D:/A MAtlab/Phase3"
SCALE_FACTOR = 0.25  # Compresses 200x200 MATLAB coordinates into 50x50 Blender grid

metadata_file = os.path.join(FOLDER_PATH, "simulation_metadata.json")
meta = None
if os.path.exists(metadata_file):
    try:
        with open(metadata_file, "r") as f:
            meta = json.load(f)
        print("✓ Loaded simulation_metadata.json successfully.")
    except Exception as e:
        print(f"⚠ Error loading metadata: {e}")

# Determine active drones
if meta and "numDrones" in meta:
    DRONES_TO_IMPORT = list(range(1, meta["numDrones"] + 1))
else:
    DRONES_TO_IMPORT = list(range(1, 11))

# Force Workbench render engine to prevent Eevee GPU crashes on laptops
bpy.context.scene.render.engine = 'BLENDER_WORKBENCH'
# Configure Workbench to render in full material colors with high-fidelity studio shading
bpy.context.scene.display.shading.color_type = 'MATERIAL'
bpy.context.scene.display.shading.light = 'STUDIO'
bpy.context.scene.display.shading.show_shadows = False # Turn off shadows to fix pixelated shadow acne
bpy.context.scene.display.shading.show_cavity = True
bpy.context.scene.display.shading.cavity_type = 'BOTH'

# 10 Drone colors matching MATLAB exactly (RGB)
DRONE_COLORS = {
    1: (0.1, 0.4, 0.9),   # Blue
    2: (0.9, 0.5, 0.0),   # Orange
    3: (0.1, 0.8, 0.2),   # Green
    4: (0.6, 0.1, 0.8),   # Purple
    5: (0.9, 0.1, 0.1),   # Red
    6: (0.1, 0.8, 0.8),   # Cyan
    7: (0.8, 0.1, 0.5),   # Magenta
    8: (0.8, 0.8, 0.1),   # Yellow
    9: (0.9, 0.4, 0.6),   # Pink
    10: (0.1, 0.6, 0.6)   # Teal
}

# Set project timelines to match MATLAB simulation
bpy.context.scene.frame_start = 1
bpy.context.scene.frame_end = 250

# --- 2. CLEAR SCENE ---
print("Clearing scene...")
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)

# Delete existing materials to prevent clutter
for material in bpy.data.materials:
    bpy.data.materials.remove(material)

# --- 3. MATERIAL CREATOR HELPERS ---
def create_material(name, r, g, b, roughness=0.5, metallic=0.0, emission=0.0):
    mat = bpy.data.materials.new(name=name)
    mat.diffuse_color = (r, g, b, 1.0)
    mat.roughness = roughness
    mat.metallic = metallic
    
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    principled = nodes.get("Principled BSDF")
    if principled:
        def set_input(input_name, value):
            if input_name in principled.inputs:
                principled.inputs[input_name].default_value = value
        set_input('Base Color', (r, g, b, 1.0))
        set_input('Roughness', roughness)
        set_input('Metallic', metallic)
        if emission > 0.0:
            set_input('Emission Color', (r, g, b, 1.0))
            set_input('Emission Strength', emission)
            set_input('Emission', (r, g, b, 1.0))
    return mat

mat_ground = create_material("Mat_Ground", 0.12, 0.38, 0.15, roughness=0.95)
mat_bld_base = create_material("Mat_BldBase", 0.12, 0.15, 0.20, roughness=0.7) # Slate Navy
mat_bld_mid = create_material("Mat_BldMid", 0.68, 0.42, 0.28, roughness=0.5, metallic=0.3) # Architectural Copper
mat_bld_top = create_material("Mat_BldTop", 0.20, 0.50, 0.62, roughness=0.2, metallic=0.8) # Glossy Teal Glass
mat_beacon = create_material("Mat_Beacon", 1.0, 0.1, 0.2, roughness=0.2, emission=3.0) # Glowing Pink/Red
mat_obst = create_material("Mat_Obstacle", 0.9, 0.05, 0.05, roughness=0.7) # Red Cylinder

# --- 4. CREATE GROUND PLANE ---
print("Creating Ground...")
# 200x200 map maps to 50x50 in Blender center (25, 25, 0)
bpy.ops.mesh.primitive_plane_add(size=200 * SCALE_FACTOR, location=(100 * SCALE_FACTOR, 100 * SCALE_FACTOR, 0))
ground = bpy.context.active_object
ground.name = "Ground_Terrain"
ground.data.materials.append(mat_ground)

# --- 5. CREATE 40 PROCEDURAL SKYSCRAPERS ---
if meta and "buildings" in meta:
    print("Building 40 skyscrapers from metadata...")
    for idx, b in enumerate(meta["buildings"]):
        px, py = b["pos"][0] * SCALE_FACTOR, b["pos"][1] * SCALE_FACTOR
        sx, sy = b["size"][0] * SCALE_FACTOR, b["size"][1] * SCALE_FACTOR
        h = b["height"] * SCALE_FACTOR
        
        # Tier 1: Base (60% height)
        h1 = h * 0.6
        bpy.ops.mesh.primitive_cube_add(size=1, location=(px, py, h1/2))
        t1 = bpy.context.active_object
        t1.name = f"Building_{idx+1}_Tier1"
        t1.scale = (sx, sy, h1)
        t1.data.materials.append(mat_bld_base)
        
        # Tier 2: Middle (25% height, 80% footprint width)
        h2 = h * 0.25
        bpy.ops.mesh.primitive_cube_add(size=1, location=(px, py, h1 + h2/2))
        t2 = bpy.context.active_object
        t2.name = f"Building_{idx+1}_Tier2"
        t2.scale = (sx * 0.8, sy * 0.8, h2)
        t2.data.materials.append(mat_bld_mid)
        
        # Tier 3: Top (15% height, 60% footprint width)
        h3 = h * 0.15
        bpy.ops.mesh.primitive_cube_add(size=1, location=(px, py, h1 + h2 + h3/2))
        t3 = bpy.context.active_object
        t3.name = f"Building_{idx+1}_Tier3"
        t3.scale = (sx * 0.6, sy * 0.6, h3)
        t3.data.materials.append(mat_bld_top)
        
        # Spire Red Beacon
        bpy.ops.mesh.primitive_cylinder_add(radius=0.08 * SCALE_FACTOR, depth=3.0 * SCALE_FACTOR, location=(px, py, h + 1.5 * SCALE_FACTOR))
        spire = bpy.context.active_object
        spire.name = f"Building_{idx+1}_Spire"
        spire.data.materials.append(mat_beacon)
else:
    print("⚠ No building metadata. Building fallback default building...")
    bpy.ops.mesh.primitive_cube_add(size=10, location=(25, 25, 5))

# --- 6. CREATE LANDSCAPING COCONUT PALM TREES ---
print("Spawning coconut palm trees...")
def spawn_coconut_tree(x, y, scale=1.0):
    mat_trunk = create_material("Mat_Trunk", 0.4, 0.28, 0.16, roughness=0.9)
    mat_leaves = create_material("Mat_Leaves", 0.1, 0.5, 0.15, roughness=0.7)
    
    # Create empty parent
    bpy.ops.object.empty_add(type='PLAIN_AXES', location=(x, y, 0))
    tree_parent = bpy.context.active_object
    tree_parent.name = "Coconut_Tree"
    tree_parent.scale = (scale, scale, scale)
    tree_parent.empty_display_size = 0.01
    
    # Stacking curved segments
    segments = 6
    curr_loc = [0.0, 0.0, 0.0]
    height_per_seg = 0.5 * SCALE_FACTOR
    bend_angle = 0.08
    
    for i in range(segments):
        sz = height_per_seg
        r_bottom = (0.16 - (i * 0.02)) * SCALE_FACTOR
        bpy.ops.mesh.primitive_cylinder_add(radius=r_bottom, depth=sz, location=(curr_loc[0], curr_loc[1] + (i * 0.015), curr_loc[2] + sz/2))
        seg = bpy.context.active_object
        seg.parent = tree_parent
        seg.data.materials.append(mat_trunk)
        seg.rotation_euler = (i * bend_angle, 0, 0)
        curr_loc[2] += sz
        curr_loc[1] += (i * 0.015)
        
    top_z = curr_loc[2]
    top_y = curr_loc[1]
    
    # Palm leaves
    num_leaves = 7
    for j in range(num_leaves):
        leaf_ang = j * (2 * math.pi / num_leaves)
        bpy.ops.mesh.primitive_cube_add(size=1.0)
        leaf = bpy.context.active_object
        leaf.name = "Palm_Leaf"
        leaf.scale = (1.1 * SCALE_FACTOR, 0.18 * SCALE_FACTOR, 0.015 * SCALE_FACTOR)
        leaf.data.materials.append(mat_leaves)
        leaf.parent = tree_parent
        leaf.location = (
            math.cos(leaf_ang) * 0.45 * SCALE_FACTOR, 
            top_y + math.sin(leaf_ang) * 0.45 * SCALE_FACTOR, 
            top_z - 0.05
        )
        leaf.rotation_euler = (0.25, 0, leaf_ang)

# Spawn trees in plazas between towers (intersections)
park_centers = [
    (36, 34), (100, 34), (164, 34),
    (36, 118), (100, 118), (164, 118),
    (36, 174), (100, 174), (164, 174)
]
tree_offsets = [(0, 0), (2.0, 2.0), (-1.8, 2.2), (2.5, -1.8)]

for cx, cy in park_centers:
    for t_idx, (ox, oy) in enumerate(tree_offsets):
        tx = (cx + ox) * SCALE_FACTOR
        ty = (cy + oy) * SCALE_FACTOR
        spawn_coconut_tree(tx, ty, scale=(0.8 + (t_idx * 0.08)))

# --- 7. CREATE MOVING HUMAN (WALKING PEDESTRIAN) ---
print("Spawning moving pedestrian...")
def spawn_moving_human(x, y):
    mat_torso = create_material("Mat_HumanTorso", 0.9, 0.2, 0.2, roughness=0.5) # Red
    mat_legs = create_material("Mat_HumanLegs", 0.1, 0.3, 0.8, roughness=0.5)  # Blue
    mat_head = create_material("Mat_HumanHead", 0.95, 0.75, 0.65, roughness=0.6) # Skin
    
    bpy.ops.object.empty_add(type='PLAIN_AXES', location=(0, 0, 0))
    human = bpy.context.active_object
    human.name = "Moving_Human"
    human.empty_display_size = 0.01
    
    # Torso
    bpy.ops.mesh.primitive_cube_add(size=1.0)
    torso = bpy.context.active_object
    torso.scale = (0.16 * SCALE_FACTOR, 0.1 * SCALE_FACTOR, 0.35 * SCALE_FACTOR)
    torso.location = (0, 0, 0.35 * SCALE_FACTOR)
    torso.parent = human
    torso.data.materials.append(mat_torso)
    
    # Head
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.08 * SCALE_FACTOR, location=(0, 0, 0.6 * SCALE_FACTOR))
    head = bpy.context.active_object
    head.parent = human
    head.data.materials.append(mat_head)
    
    # Legs
    bpy.ops.mesh.primitive_cylinder_add(radius=0.03 * SCALE_FACTOR, depth=0.25 * SCALE_FACTOR, location=(-0.05 * SCALE_FACTOR, 0, 0.12 * SCALE_FACTOR))
    leg_l = bpy.context.active_object
    leg_l.parent = human
    leg_l.data.materials.append(mat_legs)
    
    bpy.ops.mesh.primitive_cylinder_add(radius=0.03 * SCALE_FACTOR, depth=0.25 * SCALE_FACTOR, location=(0.05 * SCALE_FACTOR, 0, 0.12 * SCALE_FACTOR))
    leg_r = bpy.context.active_object
    leg_r.parent = human
    leg_r.data.materials.append(mat_legs)
    
    # Walking keyframes
    walk_path = [
        (1, y - 4.5 * SCALE_FACTOR),
        (74, y + 4.5 * SCALE_FACTOR),
        (75, y + 4.5 * SCALE_FACTOR),
        (149, y - 4.5 * SCALE_FACTOR),
        (150, y - 4.5 * SCALE_FACTOR),
        (224, y + 4.5 * SCALE_FACTOR),
        (225, y + 4.5 * SCALE_FACTOR),
        (250, y)
    ]
    for frame, y_pos in walk_path:
        human.location = (x, y_pos, 0)
        human.keyframe_insert(data_path="location", frame=frame)
        rot_z = 3.1416 if frame in [75, 149, 225] else 0.0
        human.rotation_euler = (0, 0, rot_z)
        human.keyframe_insert(data_path="rotation_euler", frame=frame)

spawn_moving_human(36.0 * SCALE_FACTOR, 34.0 * SCALE_FACTOR)

# --- 8. CREATE DYNAMIC OBSTACLE CYLINDERS ---
print("Placing dynamic warning obstacles...")
if meta and "obstacles" in meta:
    for idx, obst in enumerate(meta["obstacles"]):
        opx, opy = obst["pos"][0] * SCALE_FACTOR, obst["pos"][1] * SCALE_FACTOR
        rad = obst["radius"] * SCALE_FACTOR
        z_min, z_max = 8.0 * SCALE_FACTOR, 28.0 * SCALE_FACTOR
        spawn_frame = obst["spawnFrame"]
        
        bpy.ops.mesh.primitive_cylinder_add(radius=rad, depth=z_max-z_min, location=(opx, opy, (z_min+z_max)/2))
        obst_obj = bpy.context.active_object
        obst_obj.name = f"Dynamic_Obstacle_{idx+1}"
        obst_obj.data.materials.append(mat_obst)
        
        # Hide/Show keyframes
        obst_obj.hide_viewport = True
        obst_obj.hide_render = True
        obst_obj.keyframe_insert(data_path="hide_viewport", frame=spawn_frame - 1)
        obst_obj.keyframe_insert(data_path="hide_render", frame=spawn_frame - 1)
        
        obst_obj.hide_viewport = False
        obst_obj.hide_render = False
        obst_obj.keyframe_insert(data_path="hide_viewport", frame=spawn_frame)
        obst_obj.keyframe_insert(data_path="hide_render", frame=spawn_frame)

# --- 9. BUILD DETAILED DRONE ASSEMBLY PIPELINE ---
def build_detailed_quadrotor(drone_id):
    mat_color = DRONE_COLORS.get(drone_id, (0.5, 0.5, 0.5))
    mat_body = create_material(f"Mat_Body_{drone_id}", 0.15, 0.15, 0.15, roughness=0.3)
    mat_accent = create_material(f"Mat_Accent_{drone_id}", mat_color[0], mat_color[1], mat_color[2], roughness=0.2, metallic=0.9)
    mat_metal = create_material(f"Mat_Metal_{drone_id}", 0.8, 0.8, 0.8, roughness=0.1, metallic=1.0)
    mat_led = create_material(f"Mat_LED_{drone_id}", mat_color[0], mat_color[1], mat_color[2], roughness=0.1, emission=8.0)
    
    # 1. Master empty parent
    bpy.ops.object.empty_add(type='PLAIN_AXES', align='WORLD', location=(0,0,0))
    drone_parent = bpy.context.active_object
    drone_parent.name = f"Drone_{drone_id}_Model_Parent"
    drone_parent.empty_display_size = 0.01
    
    # 2. Main central hull (Fuselage)
    bpy.ops.mesh.primitive_cube_add(size=1.0)
    hull = bpy.context.active_object
    hull.name = f"Drone_{drone_id}_Hull"
    hull.scale = (0.42 * SCALE_FACTOR * 4.0, 0.28 * SCALE_FACTOR * 4.0, 0.15 * SCALE_FACTOR * 4.0)
    hull.location = (0, 0, 0.08 * SCALE_FACTOR * 4.0)
    hull.parent = drone_parent
    hull.data.materials.append(mat_body)
    
    # 3. Four motor arms (X configuration)
    arm_coords = [(0.22, 0.22), (-0.22, 0.22), (0.22, -0.22), (-0.22, -0.22)]
    for a_idx, (ax, ay) in enumerate(arm_coords):
        angle = math.atan2(ay, ax)
        bpy.ops.mesh.primitive_cylinder_add(radius=0.03 * SCALE_FACTOR * 4.0, depth=0.32 * SCALE_FACTOR * 4.0, location=(0,0,0))
        arm = bpy.context.active_object
        arm.name = f"Drone_{drone_id}_Arm_{a_idx+1}"
        arm.parent = drone_parent
        arm.location = (ax/2 * SCALE_FACTOR * 4.0, ay/2 * SCALE_FACTOR * 4.0, 0.08 * SCALE_FACTOR * 4.0)
        arm.rotation_euler = (1.5708, 0, angle + 1.5708)
        arm.data.materials.append(mat_metal)
        
        # Motors on arm ends
        bpy.ops.mesh.primitive_cylinder_add(radius=0.05 * SCALE_FACTOR * 4.0, depth=0.08 * SCALE_FACTOR * 4.0, location=(ax * SCALE_FACTOR * 4.0, ay * SCALE_FACTOR * 4.0, 0.12 * SCALE_FACTOR * 4.0))
        motor = bpy.context.active_object
        motor.name = f"Drone_{drone_id}_Motor_{a_idx+1}"
        motor.parent = drone_parent
        motor.data.materials.append(mat_body)
        
        # Neon LED rings under motors
        bpy.ops.mesh.primitive_torus_add(major_radius=0.06 * SCALE_FACTOR * 4.0, minor_radius=0.015 * SCALE_FACTOR * 4.0, location=(ax * SCALE_FACTOR * 4.0, ay * SCALE_FACTOR * 4.0, 0.06 * SCALE_FACTOR * 4.0))
        led = bpy.context.active_object
        led.name = f"Drone_{drone_id}_LED_{a_idx+1}"
        led.parent = drone_parent
        led.data.materials.append(mat_led)
        
    # 4. Landing Skids (Legs)
    skid_sides = [-0.14, 0.14]
    for s_idx, side in enumerate(skid_sides):
        bpy.ops.mesh.primitive_cylinder_add(radius=0.02 * SCALE_FACTOR * 4.0, depth=0.55 * SCALE_FACTOR * 4.0, location=(side * SCALE_FACTOR * 4.0, 0, -0.15 * SCALE_FACTOR * 4.0))
        skid = bpy.context.active_object
        skid.name = f"Drone_{drone_id}_Skid_{s_idx+1}"
        skid.parent = drone_parent
        skid.rotation_euler = (1.5708, 0, 0)
        skid.data.materials.append(mat_metal)
        
        # Vert struts
        for str_y in [-0.18, 0.18]:
            bpy.ops.mesh.primitive_cylinder_add(radius=0.018 * SCALE_FACTOR * 4.0, depth=0.22 * SCALE_FACTOR * 4.0, location=(side * SCALE_FACTOR * 4.0, str_y * SCALE_FACTOR * 4.0, -0.04 * SCALE_FACTOR * 4.0))
            strut = bpy.context.active_object
            strut.name = f"Drone_{drone_id}_Strut_{s_idx+1}_{str_y}"
            strut.parent = drone_parent
            strut.data.materials.append(mat_metal)
            
    # 5. Camera sensor ball hanging below hull
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.09 * SCALE_FACTOR * 4.0, location=(0, 0.08 * SCALE_FACTOR * 4.0, -0.04 * SCALE_FACTOR * 4.0))
    cam_gimbal = bpy.context.active_object
    cam_gimbal.name = f"Drone_{drone_id}_Gimbal"
    cam_gimbal.parent = drone_parent
    cam_gimbal.data.materials.append(mat_accent)
    
    # 6. Import unified hull base mesh if available
    obj_file = os.path.join(FOLDER_PATH, "quadrotor_base.obj")
    if os.path.exists(obj_file):
        bpy.ops.wm.obj_import(filepath=obj_file)
        drone_mesh = bpy.context.active_object
        drone_mesh.name = f"Drone_{drone_id}_Mesh"
        drone_mesh.parent = drone_parent
        drone_mesh.location = (0, 0, 0)
        drone_mesh.scale = (0.22, 0.22, 0.22)
        drone_mesh.rotation_euler = (0, 0, 0)
        drone_mesh.data.materials.clear()
        drone_mesh.data.materials.append(mat_accent)
        
        # Spinning propellers
        prop_offsets = [
            (0.24, 0.24, 0.04),
            (-0.24, 0.24, 0.04),
            (0.24, -0.24, 0.04),
            (-0.24, -0.24, 0.04)
        ]
        mat_prop = create_material(f"Mat_Prop_{drone_id}", 0.9, 0.9, 0.9, roughness=0.1, metallic=1.0)
        for p_idx, offset in enumerate(prop_offsets):
            bpy.ops.object.empty_add(type='PLAIN_AXES', align='WORLD', location=(0,0,0))
            prop_spinner = bpy.context.active_object
            prop_spinner.name = f"Drone_{drone_id}_PropSpinner_{p_idx+1}"
            prop_spinner.empty_display_size = 0.01
            prop_spinner.parent = drone_parent
            prop_spinner.location = offset
            
            # Blades
            bpy.ops.mesh.primitive_cube_add(size=1.0)
            blade = bpy.context.active_object
            blade.name = f"Drone_{drone_id}_PropBlade_{p_idx+1}"
            blade.scale = (0.35, 0.04, 0.008)
            blade.location = (0, 0, 0)
            blade.parent = prop_spinner
            blade.data.materials.append(mat_prop)
            
            # Spin driver
            spin_dir = 1.0 if p_idx in [0, 3] else -1.0
            driver = prop_spinner.driver_add("rotation_euler", 2).driver
            driver.expression = f"frame * {spin_dir * 1.5}"
    else:
        # Fallback sphere
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.25, location=(0, 0, 0))
        fallback = bpy.context.active_object
        fallback.parent = drone_parent
        fallback.data.materials.append(mat_accent)
        
    # Drone ID label
    bpy.ops.object.text_add()
    text_obj = bpy.context.active_object
    text_obj.name = f"Drone_{drone_id}_Text"
    text_obj.data.body = str(drone_id)
    text_obj.data.extrude = 0.1
    text_obj.data.size = 0.3
    text_obj.data.align_x = 'CENTER'
    text_obj.data.align_y = 'CENTER'
    text_obj.parent = drone_parent
    text_obj.location = (0, -0.05, 0.2)
    text_obj.rotation_euler = (1.5708, 0, 0)
    mat_text = create_material(f"Mat_Text_{drone_id}", 1.0, 1.0, 1.0, roughness=0.5)
    text_obj.data.materials.append(mat_text)
    
    return drone_parent

# --- 10. CURVE PATH IMPORT & ANIMATION HOOK ---
def create_path_from_csv(csv_path, drone_id):
    if not os.path.exists(csv_path):
        print(f"File not found: {csv_path}")
        return None
        
    points = []
    with open(csv_path, 'r') as f:
        reader = csv.reader(f)
        for row in reader:
            if row:
                x, y, z = float(row[0]), float(row[1]), float(row[2])
                points.append((x * SCALE_FACTOR, y * SCALE_FACTOR, z * SCALE_FACTOR))
                
    curve_data = bpy.data.curves.new(name=f"Drone{drone_id}_CurveData", type='CURVE')
    curve_data.dimensions = '3D'
    curve_data.fill_mode = 'FULL'
    curve_data.use_path = True
    curve_data.bevel_depth = 0.18 * SCALE_FACTOR
    curve_data.bevel_resolution = 4
    
    spline = curve_data.splines.new(type='POLY')
    spline.points.add(len(points) - 1)
    for index, coord in enumerate(points):
        spline.points[index].co = (coord[0], coord[1], coord[2], 1.0)
        
    curve_obj = bpy.data.objects.new(f"Drone{drone_id}_Path", curve_data)
    bpy.context.collection.objects.link(curve_obj)
    
    mat_color = DRONE_COLORS.get(drone_id, (0.5, 0.5, 0.5))
    mat_path = create_material(f"Mat_NeonPath_{drone_id}", mat_color[0], mat_color[1], mat_color[2], roughness=0.1, emission=4.0)
    curve_obj.data.materials.append(mat_path)
    
    return curve_obj

def setup_drone_animation(drone_parent, curve_obj, drone_id):
    constraint = drone_parent.constraints.new(type='FOLLOW_PATH')
    constraint.name = "Follow Path"
    constraint.target = curve_obj
    constraint.use_fixed_location = True
    constraint.use_curve_follow = True
    
    constraint.offset_factor = 0.0
    drone_parent.keyframe_insert(data_path='constraints["Follow Path"].offset_factor', frame=1)
    
    constraint.offset_factor = 1.0
    drone_parent.keyframe_insert(data_path='constraints["Follow Path"].offset_factor', frame=250) # Maps full timeline

# --- 11. BUILD DRONES & HOOK UP ANIMATIONS ---
for d_id in DRONES_TO_IMPORT:
    csv_file = os.path.join(FOLDER_PATH, f"drone{d_id}_path.csv")
    path_curve = create_path_from_csv(csv_file, d_id)
    if path_curve:
        drone_model = build_detailed_quadrotor(d_id)
        setup_drone_animation(drone_model, path_curve, d_id)

# --- 12. SPARK DYNAMIC DELIVERY BANNERS ---
print("Spawning landing pads and delivery banners...")
if meta and "drones" in meta:
    for drone_info in meta["drones"]:
        d_id = drone_info["id"]
        drone_color = DRONE_COLORS.get(d_id, (0.5, 0.5, 0.5))
        for idx, deliv in enumerate(drone_info["deliveries"]):
            goal_pos = (deliv["pos"][0] * SCALE_FACTOR, deliv["pos"][1] * SCALE_FACTOR, deliv["pos"][2] * SCALE_FACTOR)
            frame_deliv = deliv["frame"]
            
            # Glowing Landing Pad
            bpy.ops.mesh.primitive_torus_add(align='WORLD', location=goal_pos, major_radius=0.45 * SCALE_FACTOR * 4.0, minor_radius=0.08 * SCALE_FACTOR * 4.0)
            pad = bpy.context.active_object
            pad.name = f"Drone_{d_id}_Landing_Pad_{idx+1}"
            mat_pad = create_material(f"Mat_Pad_{d_id}_{idx+1}", drone_color[0], drone_color[1], drone_color[2], roughness=0.1, emission=5.0)
            pad.data.materials.append(mat_pad)
            
            # Delivered Text flag
            bpy.ops.object.text_add(location=(goal_pos[0], goal_pos[1] - 0.1 * SCALE_FACTOR, goal_pos[2] + 0.6 * SCALE_FACTOR))
            text_deliv = bpy.context.active_object
            text_deliv.name = f"Drone_{d_id}_Delivered_Text_{idx+1}"
            text_deliv.data.body = "Delivered!"
            text_deliv.data.extrude = 0.08 * SCALE_FACTOR
            text_deliv.data.size = 0.3 * SCALE_FACTOR
            text_deliv.data.align_x = 'CENTER'
            text_deliv.data.align_y = 'CENTER'
            text_deliv.rotation_euler = (1.5708, 0, 0)
            mat_deliv = create_material(f"Mat_DelivText_{d_id}_{idx+1}", 1.0, 1.0, 1.0, roughness=0.5, emission=2.0)
            text_deliv.data.materials.append(mat_deliv)
            
            # Hide/Show keyframes
            text_deliv.hide_viewport = True
            text_deliv.hide_render = True
            text_deliv.keyframe_insert(data_path="hide_viewport", frame=frame_deliv - 1)
            text_deliv.keyframe_insert(data_path="hide_render", frame=frame_deliv - 1)
            
            text_deliv.hide_viewport = False
            text_deliv.hide_render = False
            text_deliv.keyframe_insert(data_path="hide_viewport", frame=frame_deliv)
            text_deliv.keyframe_insert(data_path="hide_render", frame=frame_deliv)

# --- 13. CHASE CAMERAS ---
print("Creating 10 chase cameras parented to drones...")
for d_id in DRONES_TO_IMPORT:
    cam_data = bpy.data.cameras.new(name=f"CamData_Drone_{d_id}")
    cam_obj = bpy.data.objects.new(name=f"ChaseCam_Drone_{d_id}", object_data=cam_data)
    bpy.context.collection.objects.link(cam_obj)
    
    drone_parent = bpy.data.objects.get(f"Drone_{d_id}_Model_Parent")
    if drone_parent:
        cam_obj.parent = drone_parent
        cam_obj.location = (0, -4.8 * SCALE_FACTOR * 4.0, 1.8 * SCALE_FACTOR * 4.0)
        cam_obj.rotation_euler = (1.3, 0, 0)

# --- 14. CINEMATIC ORBIT OVERVIEW CAMERA ---
print("Creating cinematic orbiting overview camera...")
bpy.ops.object.empty_add(type='PLAIN_AXES', location=(100 * SCALE_FACTOR, 100 * SCALE_FACTOR, 0)) # Center (25, 25, 0)
orbit_center = bpy.context.active_object
orbit_center.name = "Orbit_Center"
orbit_center.empty_display_size = 0.01

cam_data_global = bpy.data.cameras.new(name="CamData_Global")
cam_data_global.lens = 18 # Ultra-wide
cam_global = bpy.data.objects.new(name="Cinematic_Overview_Camera", object_data=cam_data_global)
bpy.context.collection.objects.link(cam_global)

cam_global.location = (100 * SCALE_FACTOR, 20 * SCALE_FACTOR, 38) # Back and high up
cam_global.parent = orbit_center

track_const = cam_global.constraints.new(type='TRACK_TO')
track_const.target = orbit_center
track_const.track_axis = 'TRACK_NEGATIVE_Z'
track_const.up_axis = 'UP_Y'

# Animate Z rotation
orbit_center.rotation_euler = (0, 0, -0.45)
orbit_center.keyframe_insert(data_path="rotation_euler", frame=1)
orbit_center.rotation_euler = (0, 0, 0.45)
orbit_center.keyframe_insert(data_path="rotation_euler", frame=250)

# Print metrics inside Blender Console if available
if meta and "metrics" in meta:
    mtr = meta["metrics"]
    print("\n" + "="*41)
    print("      METRIC SUMMARY FROM SIMULATION      ")
    print("="*41)
    print(f"Drones                     | {mtr['drones']}")
    print(f"Skyscrapers                | {mtr['buildings']}")
    print(f"Missions Completed         | {mtr['missions_completed']}")
    print(f"Average Path Length        | {mtr['avg_path_length']}")
    print(f"Total Planning Time        | {mtr['planning_time_ms']}")
    print(f"Replanning Events          | {mtr['replan_events']}")
    print(f"Near Collisions            | {mtr['near_collisions']}")
    print("="*41 + "\n")

print("\n=== Blender Full Scene Builder Complete! ===")
print("1. Select 'Cinematic_Overview_Camera' in Outliner.")
print("2. Set Active Object as Camera (Ctrl+Numpad 0).")
print("3. Click the Viewport Camera icon.")
print("4. Press Spacebar to watch the 10-drone logistics network!")
