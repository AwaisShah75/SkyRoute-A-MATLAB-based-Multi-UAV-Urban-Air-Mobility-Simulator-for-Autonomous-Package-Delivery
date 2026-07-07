# blender_importer.py
# Copy-paste this script into Blender's "Scripting" tab to automatically
# import the MATLAB coordinates and create animated flight paths.

import bpy
import csv
import os

# --- CONFIGURATION ---
# Change this path to your MATLAB Phase3 folder location on your PC
# Use forward slashes (/) for the path.
FOLDER_PATH = "D:/A MAtlab/Phase3"
DRONES_TO_IMPORT = [1, 2, 3] # Drone IDs to load
SCALE_FACTOR = 0.5            # Scale down the coordinate values if too large

# ---------------------

def create_path_from_csv(csv_path, drone_id):
    if not os.path.exists(csv_path):
        print(f"File not found: {csv_path}")
        return None

    # 1. Read coordinates from CSV
    points = []
    with open(csv_path, 'r') as f:
        reader = csv.reader(f)
        for row in reader:
            if row:
                x, y, z = float(row[0]), float(row[1]), float(row[2])
                # Blender uses Z as up, whereas MATLAB uses Z as up too.
                # Scale coordinates down to fit comfortable Blender grid bounds
                points.append((x * SCALE_FACTOR, y * SCALE_FACTOR, z * SCALE_FACTOR))

    # 2. Create a new Curve object in Blender
    curve_data = bpy.data.curves.new(name=f"Drone{drone_id}_CurveData", type='CURVE')
    curve_data.dimensions = '3D'
    curve_data.fill_mode = 'FULL'
    curve_data.use_path = True # Enable path evaluation for constraints
    
    # Add a spline to the curve
    spline = curve_data.splines.new(type='POLY')
    spline.points.add(len(points) - 1)
    
    # Set coordinates for each spline point (POLY points expect [X, Y, Z, W] where W=1.0)
    for index, coord in enumerate(points):
        spline.points[index].co = (coord[0], coord[1], coord[2], 1.0)
        
    curve_obj = bpy.data.objects.new(f"Drone{drone_id}_Path", curve_data)
    bpy.context.collection.objects.link(curve_obj)
    
    print(f"✓ Created 3D Poly curve path for Drone {drone_id}")
    return curve_obj

def setup_drone_animation(curve_obj, drone_id):
    # 3. Create a placeholder object (Empty) to represent the drone
    # You can later parent your detailed 3D drone mesh to this Empty object.
    bpy.ops.object.empty_add(type='CUBE', align='WORLD', location=(0, 0, 0), scale=(1, 1, 1))
    drone_empty = bpy.context.active_object
    drone_empty.name = f"Drone_{drone_id}_Model_Parent"
    
    # 4. Add a "Follow Path" constraint to the Empty object
    constraint = drone_empty.constraints.new(type='FOLLOW_PATH')
    constraint.name = "Follow Path"
    constraint.target = curve_obj
    constraint.use_fixed_location = True
    constraint.use_curve_follow = True # Makes the drone face forward along the path
    
    # 5. Add keyframe animation on the constraint's offset_factor
    # We call keyframe_insert on the object, pointing to the constraint's data path
    constraint.offset_factor = 0.0
    drone_empty.keyframe_insert(data_path='constraints["Follow Path"].offset_factor', frame=1)
    
    constraint.offset_factor = 1.0
    drone_empty.keyframe_insert(data_path='constraints["Follow Path"].offset_factor', frame=150)
    
    print(f"✓ Configured animation constraint for Drone {drone_id} empty parent (Frame 1 to 150)")

# Main execution loop
for d_id in DRONES_TO_IMPORT:
    csv_file = os.path.join(FOLDER_PATH, f"drone{d_id}_path.csv")
    path_curve = create_path_from_csv(csv_file, d_id)
    if path_curve:
        setup_drone_animation(path_curve, d_id)

print("\n=== Blender Import Complete! ===")
print("Play the timeline (Spacebar) to see the empty cubes follow the RRT* paths.")
print("To add detailed drones, simply import your drone model and parent it (Ctrl+P) to the 'Drone_X_Model_Parent' Empty cubes.")
