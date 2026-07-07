# Multi-UAV Path Planning — Complete Step-by-Step Guide
### From Zero to Working Demo

**Author:** Awais Shah  
**Project:** Multi-UAV Path Planning for Urban Air Mobility — Phase 1  
**Date:** July 2026

---

## Table of Contents

1. [Choose Your MATLAB Option](#step-1--choose-your-matlab-option)
2. [Create a MathWorks Account](#step-2--create-a-mathworks-account)
3. [Option A: MATLAB Online Setup](#step-3a--matlab-online-setup)
4. [Option B: MATLAB Desktop Setup](#step-3b--matlab-desktop-installation)
5. [Install Required Toolboxes](#step-4--install-required-toolboxes)
6. [Verify Toolbox Installation](#step-5--verify-toolbox-installation)
7. [Upload / Place Project Files](#step-6--upload--place-project-files)
8. [Understand the Project Files](#step-7--understand-the-project-files)
9. [Run the Simulation](#step-8--run-the-simulation)
10. [What You Should See](#step-9--what-you-should-see)
11. [Troubleshooting Common Errors](#step-10--troubleshooting-common-errors)
12. [Record Your Demo Video](#step-11--record-your-demo-video)
13. [Next Steps (Phase 2+)](#step-12--next-steps)

---

## Step 1 — Choose Your MATLAB Option

You have two ways to use MATLAB. Pick one:

| Option | Cost | Pros | Cons |
|--------|------|------|------|
| **MATLAB Online** (browser) | Free tier: 20 hrs/month | No install needed, works on any PC | Limited hours, slower for heavy computation |
| **MATLAB Desktop** (installed) | Free 30-day trial, or student license (~$50/year) | Unlimited hours, faster | Large download (~10-20 GB), needs decent PC |

**Recommendation for this project:** Start with MATLAB Online to avoid wasting time on installation. Switch to Desktop if you run out of hours.

---

## Step 2 — Create a MathWorks Account

1. Open your browser and go to: **https://www.mathworks.com/mwaccount/register**
2. Fill in:
   - **Email:** Use your university email if you have one (gives you access to student licenses)
   - **Country, Name, Password** — fill as normal
3. Click **Create** → check your email inbox → click the verification link
4. You now have a MathWorks account

> **Important:** Remember your MathWorks email and password. You'll need them for everything.

---

## Step 3A — MATLAB Online Setup

*Skip this section if you chose Desktop installation (go to Step 3B).*

1. Go to: **https://matlab.mathworks.com/**
2. Sign in with your MathWorks account
3. Click **Open MATLAB Online**
4. Wait for the browser-based MATLAB environment to load (takes 30-60 seconds)
5. You should see:
   - **Command Window** (bottom) — where you type commands
   - **Current Folder** panel (left) — your file browser
   - **Editor** (center/right) — where you open and edit .m files

> **Note:** Your 20 free hours start counting only when MATLAB Online is open. Close the tab when you're not using it.

**Done! Jump to Step 4.**

---

## Step 3B — MATLAB Desktop Installation

*Skip this section if you chose MATLAB Online (go to Step 4).*

### Download MATLAB

1. Go to: **https://www.mathworks.com/downloads/**
2. Sign in with your MathWorks account
3. Select **MATLAB R2024b** (or the latest version shown)
4. Click **Download for Windows** (or Mac/Linux as applicable)
5. The installer file will download (~300 MB initial downloader)

### Install MATLAB

1. Run the downloaded installer (`matlab_R2024b_win64.exe`)
2. Sign in with your MathWorks account when prompted
3. Accept the license agreement
4. **License selection:**
   - If you have a student license → select it
   - If you're using a trial → select "30-Day Trial"
5. **Product selection screen** — This is critical. Check these boxes:
   - ☑ **MATLAB** (always included)
   - ☑ **UAV Toolbox**
   - ☑ **Navigation Toolbox**
   - ☑ **Sensor Fusion and Tracking Toolbox** (needed for Phase 2+)
   - ☑ **Simulink** (useful later, optional for Phase 1)
6. Click **Install** → wait for download and installation (10-20 GB, takes 30-90 minutes depending on internet speed)
7. When finished, click **Close** and launch MATLAB from your Start Menu / Desktop shortcut

**Done! Jump to Step 5.**

---

## Step 4 — Install Required Toolboxes

### If Using MATLAB Online:

MATLAB Online includes many toolboxes by default. To check/add:

1. In MATLAB Online, click the **"Add-Ons"** button in the top toolbar (or go to Home tab → Add-Ons → Get Add-Ons)
2. Search for each of these and click **"Add"** if not already installed:
   - **UAV Toolbox**
   - **Navigation Toolbox**
   - **Sensor Fusion and Tracking Toolbox**
3. If prompted, agree to any license terms and wait for installation

### If Using MATLAB Desktop:

1. In MATLAB, go to **Home** tab → **Add-Ons** → **Get Add-Ons**
2. The Add-On Explorer opens
3. Search for: **UAV Toolbox** → Click **Install**
4. Search for: **Navigation Toolbox** → Click **Install**
5. Search for: **Sensor Fusion and Tracking Toolbox** → Click **Install**
6. MATLAB may ask you to restart — do it

---

## Step 5 — Verify Toolbox Installation

This step confirms everything is installed correctly before you run the project.

### Test 1: Check installed toolboxes

Type this in the MATLAB **Command Window** and press Enter:

```matlab
ver
```

You should see a list that includes at least:

```
MATLAB                                   Version X.X
UAV Toolbox                              Version X.X
Navigation Toolbox                       Version X.X
```

If any of these are missing, go back to Step 4.

### Test 2: Check that key functions exist

Type each of these one at a time and press Enter:

```matlab
help uavScenario
```
→ Should print the help text for uavScenario (not an error)

```matlab
help occupancyMap3D
```
→ Should print help text

```matlab
help plannerRRTStar
```
→ Should print help text

```matlab
help stateSpaceSE3
```
→ Should print help text

### Test 3: Quick smoke test

Type this and press Enter:

```matlab
scene = uavScenario('UpdateRate', 10);
disp('UAV Toolbox is working!')
```

If you see `UAV Toolbox is working!` — you're all set.  
If you see an error like `Undefined function 'uavScenario'` — the UAV Toolbox is not installed. Repeat Step 4.

---

## Step 6 — Upload / Place Project Files

Your project has **4 MATLAB script files**. They must all be in the **same folder**.

### File list:

| File | Purpose |
|------|---------|
| `main_phase1.m` | The main script you run — configures everything and calls the others |
| `create_city_scenario.m` | Builds the 3D city with 9 buildings and a ground plane |
| `plan_uav_path.m` | Plans a collision-free path using the RRT* algorithm |
| `animate_uav.m` | Animates the drone flying the planned path in 3D |

### If Using MATLAB Online:

1. In the **Current Folder** panel (left side), click the **Upload** button (↑ icon)
2. Select all 4 `.m` files from your computer:
   - `main_phase1.m`
   - `create_city_scenario.m`
   - `plan_uav_path.m`
   - `animate_uav.m`
3. Click **Open** → files appear in your MATLAB Online workspace

### If Using MATLAB Desktop:

1. Create a project folder, e.g.: `C:\Users\YourName\Documents\MATLAB\UAV_PathPlanning\`
2. Copy all 4 `.m` files into that folder
3. In MATLAB, navigate to that folder:
   - Use the **Current Folder** panel on the left to browse to it, **OR**
   - Type in the Command Window:
   ```matlab
   cd 'C:\Users\YourName\Documents\MATLAB\UAV_PathPlanning'
   ```
4. Verify the files are visible in the Current Folder panel

---

## Step 7 — Understand the Project Files

Before running anything, here's what each file does and how they connect:

### How the files work together:

```
main_phase1.m  (you run THIS)
    │
    ├──► create_city_scenario.m
    │        Creates 9 buildings in a 3x3 grid
    │        Creates a 3D occupancy map (marks where buildings are)
    │        Creates a green ground plane
    │        Creates the quadrotor drone object
    │        Returns: scenario, map3D, uav
    │
    ├──► plan_uav_path.m
    │        Takes the 3D occupancy map
    │        Inflates it by 1.5m (safety buffer around buildings)
    │        Uses RRT* algorithm to find a collision-free 3D path
    │        Returns: waypoints (the path), solnInfo (success/fail)
    │
    └──► animate_uav.m
             Takes the scenario, drone, and waypoints
             Calculates speed-based timing for each waypoint
             Opens a 3D figure window
             Plots the planned path in green
             Marks Start (green square) and Goal (red star)
             Animates the drone flying along the path
             Drone faces its direction of travel
```

### Key concepts explained:

**What is RRT*?**  
RRT* (Rapidly-exploring Random Tree Star) is a path planning algorithm. It randomly samples points in 3D space, builds a tree of collision-free connections, and finds the shortest path from start to goal while avoiding obstacles (buildings). The `*` means it optimizes the path over iterations — more iterations = shorter/smoother path.

**What is an occupancy map?**  
A 3D grid where each cell is marked as "occupied" (inside a building) or "free" (empty air). The RRT* planner uses this map to check if a path segment would crash into a building.

**What does "inflate" mean?**  
When we inflate the occupancy map by 1.5 meters, every building grows 1.5m in all directions on the map. This means the drone will never fly closer than 1.5m to any building surface — a safety buffer.

**What is the `move()` function?**  
Each frame of the animation, we calculate where the drone should be (by interpolating along the planned path) and tell MATLAB to place the drone there using `move(uav, motionVector)`. The motion vector has 16 numbers: position(3), velocity(3), orientation-quaternion(4), angular-velocity(3), acceleration(3).

---

## Step 8 — Run the Simulation

### Pre-flight checklist:

- [ ] MATLAB is open (Online or Desktop)
- [ ] All 4 `.m` files are in your current folder
- [ ] Current Folder panel shows: `main_phase1.m`, `create_city_scenario.m`, `plan_uav_path.m`, `animate_uav.m`
- [ ] Toolboxes are installed (Step 5 passed)

### Run it:

1. Type the following in the **Command Window** and press **Enter**:

```matlab
main_phase1
```

2. **Wait.** The simulation has three stages:
   - **Stage 1 (instant):** "Initializing city block scenario..." — builds the 3D world
   - **Stage 2 (5-30 seconds):** "Computing RRT* path..." — the planner searches for a collision-free route. This takes time because RRT* runs 3000 iterations.
   - **Stage 3 (30-60 seconds):** "Starting UAV flight animation..." — a 3D window opens and the drone flies

3. **Do not close anything** while it's running. The figure window will appear automatically.

---

## Step 9 — What You Should See

### Command Window Output:

```
Initializing city block scenario...
Computing RRT* path...
Planning path from [5.0, 5.0, 10.0] to [90.0, 90.0, 15.0]...
Path found successfully in XXXX iterations!
Animating flight simulation...
Starting UAV flight animation (XX.X s at 3.0 m/s)...
Animation complete.
```

### 3D Figure Window:

A window opens showing:

1. **Green ground plane** — the floor of the city
2. **9 gray cuboid buildings** — arranged in a 3×3 grid with streets between them
3. **Green line with circle markers** — the RRT* planned path weaving through the city
4. **Green square marker** — the Start position at [5, 5, 10]
5. **Red star marker** — the Goal position at [90, 90, 15]
6. **Blue quadrotor drone** — flying along the green path, facing its direction of travel

The drone should:
- Start near the bottom-left corner
- Navigate through the streets between buildings
- Possibly fly over shorter buildings if it's more efficient
- Arrive at the top-right corner

> **Note:** Because RRT* is a randomized algorithm, the path will look slightly different every time you run it. This is normal and expected.

### Interacting with the 3D view:

- **Rotate:** Click and drag inside the figure window
- **Zoom:** Scroll mouse wheel
- **Pan:** Hold Shift + click and drag
- **Reset view:** Click the "Home" button in the figure toolbar

---

## Step 10 — Troubleshooting Common Errors

### Error: `Undefined function or variable 'uavScenario'`

**Cause:** UAV Toolbox is not installed.  
**Fix:** Go back to Step 4 and install the UAV Toolbox.

---

### Error: `Undefined function or variable 'plannerRRTStar'`

**Cause:** Navigation Toolbox is not installed.  
**Fix:** Go back to Step 4 and install the Navigation Toolbox.

---

### Error: `Undefined function or variable 'stateSpaceSE3'`

**Cause:** Navigation Toolbox is not installed or is an older version.  
**Fix:** Update the Navigation Toolbox via Add-Ons → Check for Updates.

---

### Warning: `RRT* failed to find a collision-free path`

**Cause:** The planner couldn't find a valid route in 3000 iterations. This is rare with the current building layout but can happen.  
**Fix:** Run `main_phase1` again (different random seed = different result). If it keeps failing, increase the iteration limit in `plan_uav_path.m` line 41:

```matlab
planner.MaxIterations = 5000;   % was 3000, increased
```

---

### Error: `Index exceeds the number of array elements`

**Cause:** Usually means the path planner returned an empty path.  
**Fix:** Same as above — re-run or increase iterations.

---

### The 3D figure is blank or shows only the ground

**Cause:** The camera might be positioned underground or far away.  
**Fix:** In the figure window, click the **Rotate 3D** button in the toolbar, then click and drag to reorient the view. Or type in Command Window:

```matlab
view(45, 30);
```

---

### MATLAB Online is very slow / animation stutters

**Cause:** MATLAB Online runs in a browser with limited GPU acceleration.  
**Fix:** 
- Close other browser tabs to free memory
- Reduce map resolution in `main_phase1.m` line 23: change `mapResolution = 1` to `mapResolution = 0.5`
- Or switch to MATLAB Desktop for smoother animation

---

### Error: `Unable to perform assignment because the left and right sides have a different number of elements`

**Cause:** A function returned an unexpected format.  
**Fix:** Make sure all 4 `.m` files are in the same folder and you haven't accidentally modified any of them.

---

## Step 11 — Record Your Demo Video

Once the simulation runs successfully, record a demo video for your portfolio.

### On Windows:

1. Press **Win + G** to open the Xbox Game Bar
2. Click the **Record** button (or press **Win + Alt + R**)
3. Run `main_phase1` in MATLAB
4. When the 3D animation finishes, press **Win + Alt + R** again to stop recording
5. The video is saved to: `C:\Users\YourName\Videos\Captures\`

### On Mac:

1. Press **Cmd + Shift + 5** to open Screen Recording
2. Select the MATLAB window → click **Record**
3. Run `main_phase1`
4. Click the **Stop** button in the menu bar when done

### Tips for a good demo video:

- Before recording, rotate the 3D view to a nice angle
- Run the simulation once first (without recording) so you know the timing
- Add narration or captions explaining what's happening:
  - "This is a 3D city environment with 9 buildings"
  - "The RRT* algorithm plans a collision-free path (shown in green)"
  - "The blue quadrotor drone autonomously follows the planned path"

---

## Step 12 — Phase 2: Multi-Drone Extension (~5-6 hours)

### Goal
Get 2-3 drones flying simultaneously through the same city, each following its own collision-free path, without crashing into each other or into buildings.

### What You Need to Understand First
In Phase 1, you planned a single path. The challenge in Phase 2 is that Drone 2's path must avoid Drone 1 — and Drone 3 must avoid both. The simplest proven approach is **sequential planning with shared occupancy**:

1. Plan Drone 1's path using RRT* (same as Phase 1)
2. Mark Drone 1's entire planned path as "occupied" in the occupancy map
3. Plan Drone 2's path on this updated map — it will automatically route around Drone 1
4. Mark Drone 2's path as occupied, then plan Drone 3

### New Files to Create

| File | Purpose |
|------|---------|
| `main_phase2.m` | Entry script — defines 3 drones with different start/goal pairs, calls multi-drone planner and animator |
| `plan_multi_uav.m` | Loops through each drone, calls `plan_uav_path.m` for each, marks each planned path as occupied before planning the next |
| `animate_multi_uav.m` | Extends `animate_uav.m` to move all 3 drones simultaneously in the simulation loop |

### Step-by-Step Build

**Step 12.1 — Define 3 drone missions in `main_phase2.m`:**

```matlab
% Drone 1: bottom-left to top-right (blue)
drones(1).start = [5, 5, 10];
drones(1).goal  = [95, 95, 15];
drones(1).color = [0 0.4 1];    % blue

% Drone 2: top-left to bottom-right (red)
drones(2).start = [5, 95, 12];
drones(2).goal  = [95, 5, 10];
drones(2).color = [1 0.2 0.2];  % red

% Drone 3: center-left to center-right (green)
drones(3).start = [5, 50, 20];
drones(3).goal  = [95, 50, 8];
drones(3).color = [0.2 0.8 0.2]; % green
```

**Step 12.2 — Build `plan_multi_uav.m` (sequential planning):**

The key idea is a loop:

```matlab
function allWaypoints = plan_multi_uav(map3D, drones, mapBounds, safetyDistance, pathRadius)
    planningMap = copy(map3D);  % working copy
    allWaypoints = cell(length(drones), 1);

    for i = 1:length(drones)
        % Plan this drone's path
        [wps, info] = plan_uav_path(planningMap, drones(i).start, drones(i).goal, ...
                                    mapBounds, safetyDistance);

        if ~info.IsPathFound
            warning('Drone %d failed to find a path!', i);
            continue;
        end
        allWaypoints{i} = wps;

        % Mark this drone's path as occupied so next drone avoids it
        % Inflate each waypoint into a sphere of radius pathRadius
        for j = 1:size(wps, 1)
            [sx, sy, sz] = sphere(5);
            pts = [sx(:)*pathRadius + wps(j,1), ...
                   sy(:)*pathRadius + wps(j,2), ...
                   sz(:)*pathRadius + wps(j,3)];
            setOccupancy(planningMap, pts, 1);
        end
    end
end
```

- `pathRadius` controls how much space each drone's path "blocks" for the next drone — start with 3-5 meters.

**Step 12.3 — Build `animate_multi_uav.m`:**

Extend the animation to create multiple `uavPlatform` objects and move all of them each frame:

```matlab
% Inside the simulation loop:
for i = 1:numDrones
    pos = interp1(timeOfArrival{i}, allWaypoints{i}, tClamped, 'linear');
    motion = [pos, 0 0 0, 1 0 0 0, 0 0 0, 0 0 0];
    move(uavPlatforms(i), motion);
end
```

Each drone gets its own color, planned path line, and start/goal markers.

**Step 12.4 — Run and verify:**

```matlab
main_phase2
```

Visually confirm:
- All 3 drones reach their goals
- No drone flies through another drone
- No drone flies through a building
- Paths are visibly different routes through the city

### Deliverable
A 3D simulation with 2-3 colored drones flying different routes simultaneously through the city grid — no collisions.

---

## Step 13 — Phase 3: Delivery Logic + Dynamic Avoidance (~4-5 hours)

### Goal
Make the simulation feel alive: drones "deliver packages" at their goals, and at least one drone reacts to an **unexpected obstacle** mid-flight by replanning its path in real time.

### Part A: Delivery Logic

**What to build:**

When a drone arrives at its goal position (within a threshold distance), trigger a visual event:

1. **Descent animation** — the drone drops from cruise altitude to near-ground level
2. **Color/marker change** — the goal marker turns green or a text annotation appears ("✓ Delivered")
3. **Pause** — the drone hovers at the delivery point for 2-3 seconds
4. **Log message** — print `Drone 1 delivered at [90, 90, 0] — Time: 42.3s`

**How to implement:**

Inside your animation loop, add a delivery check:

```matlab
distToGoal = norm(pos - drones(i).goal);
if distToGoal < 2.0 && ~delivered(i)
    fprintf('Drone %d: Package delivered at t=%.1fs\n', i, t);
    delivered(i) = true;
    % Change the goal marker to green
    % Add a text annotation at the delivery point
    text(ax, drones(i).goal(1), drones(i).goal(2), drones(i).goal(3)+3, ...
         '✓ Delivered', 'Color', 'g', 'FontSize', 12, 'FontWeight', 'bold');
end
```

### Part B: Dynamic Obstacle + Reactive Avoidance

This is the strongest "wow moment" for your demo video. A drone is flying its planned path, a new obstacle suddenly appears, and the drone swerves to avoid it.

**Step 13.1 — Spawn a dynamic obstacle mid-simulation:**

At a specific time during the simulation (e.g., `t = 10 seconds`), add a new mesh to the scenario:

```matlab
if t >= 10.0 && ~obstacleSpawned
    % Add a surprise obstacle (a floating sphere or cylinder)
    addMesh(scenario, 'cylinder', {[50 50 12], [3 8]}, [1 0 0]);
    obstacleSpawned = true;
    fprintf('⚠ Dynamic obstacle spawned at [50, 50, 12]!\n');
end
```

**Step 13.2 — Detect when a drone is approaching the obstacle:**

Each frame, check if the drone's remaining path passes near the new obstacle:

```matlab
% Check remaining waypoints for collision with new obstacle
obstaclePos = [50, 50, 12];
obstacleRadius = 5; % meters

for j = currentWaypointIdx:size(waypoints, 1)
    if norm(waypoints(j,:) - obstaclePos) < obstacleRadius + safetyDistance
        needsReplan = true;
        break;
    end
end
```

**Step 13.3 — Trigger local replanning:**

When a conflict is detected, replan from the drone's **current position** to its **original goal**, using an updated occupancy map that includes the new obstacle:

```matlab
if needsReplan && ~hasReplanned
    fprintf('Drone %d: Obstacle detected! Replanning...\n', i);
    
    % Update the occupancy map with the new obstacle
    [ox, oy, oz] = meshgrid(47:53, 47:53, 8:20);
    setOccupancy(replanMap, [ox(:) oy(:) oz(:)], 1);
    
    % Replan from current position to original goal
    [newWaypoints, newInfo] = plan_uav_path(replanMap, currentPos, ...
                                            drones(i).goal, mapBounds, safetyDistance);
    
    if newInfo.IsPathFound
        % Switch to the new path
        waypoints = newWaypoints;
        % Recalculate timing
        fprintf('Drone %d: New path found! Rerouting.\n', i);
    end
    hasReplanned = true;
end
```

**Step 13.4 — Visualize the reroute:**

- Plot the **original path** as a dashed line (so the viewer can see what changed)
- Plot the **new replanned path** as a solid line in a different color (e.g., orange)
- This visual contrast is what makes the demo compelling

### Deliverable
At least one clear moment in the demo where a drone visibly swerves away from an unexpected obstacle. This is the strongest clip for your demo video.

### New Files

| File | Purpose |
|------|---------|
| `main_phase3.m` | Entry script with delivery logic and dynamic obstacle injection |
| `detect_obstacle.m` | Helper function to check if a path conflicts with a new obstacle |
| `replan_local.m` | Helper to trigger a quick RRT replan from current position to goal |

---

## Step 14 — Phase 4: Polish, Demo Video, GitHub Packaging (~3-4 hours)

### Goal
Take your working simulation and turn it into a professional portfolio piece: a clean GitHub repo and a demo video you can link from your CV, SOP, and LinkedIn.

### Part A: Visual Polish (~1-2 hours)

**Step 14.1 — Improve the building layout:**

- Make the city grid more realistic — vary building sizes more, maybe add a "park" area (green mesh with no buildings)
- Use different shades of gray for different buildings to add depth
- Add a subtle grid pattern to the ground (you can overlay thin lines)

**Step 14.2 — Better color coding:**

| Element | Suggested Color | Why |
|---------|----------------|-----|
| Drone 1 | Blue `[0 0.4 1]` | Primary drone |
| Drone 2 | Red `[1 0.2 0.2]` | Secondary drone |
| Drone 3 | Green `[0.2 0.8 0.2]` | Tertiary drone |
| Planned paths | Same color as drone, dashed | Links drone to its path |
| Replanned path | Orange `[1 0.6 0]` | Visually distinct reroute |
| Dynamic obstacle | Bright red `[1 0 0]` | Danger = red |
| Buildings | Gray shades | Neutral background |
| Ground | Muted green `[0.3 0.6 0.3]` | Natural feel |

**Step 14.3 — Camera angles:**

Set multiple viewpoints and choose the best for recording:

```matlab
% Top-down view (shows the city grid clearly)
view(ax, 0, 90);

% Dramatic diagonal view (best for video)
view(ax, 35, 25);

% Following view (rotate during simulation)
campos(ax, [droneX-30, droneY-30, droneZ+40]);
camtarget(ax, [droneX, droneY, droneZ]);
```

**Step 14.4 — On-screen info overlay:**

Add a text annotation showing real-time stats:

```matlab
infoText = text(ax, 5, 5, 48, '', 'FontSize', 10, 'Color', 'w', ...
                'BackgroundColor', [0 0 0 0.6]);
% Update each frame:
infoText.String = sprintf('Time: %.1fs | Drones Active: %d | Obstacles Avoided: %d', ...
                          t, numActive, numAvoided);
```

### Part B: Record Demo Video (~1 hour)

**Step 14.5 — Prepare for recording:**

1. Run the simulation once without recording to identify the best camera angle
2. Note the total duration so you know when to stop recording
3. Close all other windows — just MATLAB and the 3D figure

**Step 14.6 — Record:**

**On Windows:**
1. Press **Win + G** → Xbox Game Bar opens
2. Press **Win + Alt + R** to start recording
3. Run `main_phase3` in MATLAB
4. When done, press **Win + Alt + R** to stop
5. Video saved to `C:\Users\YourName\Videos\Captures\`

**Alternative: OBS Studio (better quality, free):**
1. Download from https://obsproject.com/
2. Add "Window Capture" → select the MATLAB figure window
3. Click "Start Recording" → run your simulation → "Stop Recording"

**Step 14.7 — Edit the video (optional but recommended):**

Use a free editor like:
- **Clipchamp** (built into Windows 11)
- **DaVinci Resolve** (free, professional quality)

Add:
- Title card: "Multi-UAV Path Planning for Urban Air Mobility"
- Captions at key moments: "RRT* plans collision-free paths", "Dynamic obstacle detected — replanning in real time"
- Your name and GitHub link at the end

Target length: **1-3 minutes**.

### Part C: GitHub Packaging (~1 hour)

**Step 14.8 — Organize the repo:**

```
Multi-UAV-Path-Planning/
├── README.md
├── LICENSE
├── main_phase1.m
├── main_phase2.m
├── main_phase3.m
├── create_city_scenario.m
├── plan_uav_path.m
├── plan_multi_uav.m
├── animate_uav.m
├── animate_multi_uav.m
├── detect_obstacle.m
├── replan_local.m
├── docs/
│   ├── demo_screenshot.png
│   └── STEP_BY_STEP_GUIDE.md
└── media/
    └── demo_video_link.md
```

**Step 14.9 — Write the README.md:**

A strong README has these sections:

```markdown
# Multi-UAV Path Planning for Urban Air Mobility

![Demo Screenshot](docs/demo_screenshot.png)

## Overview
A simulated multi-drone system that plans collision-free 3D paths through
an urban environment using RRT*, with real-time obstacle avoidance.

## Demo Video
[Watch on YouTube](your-link-here)

## Features
- 3D city environment with 9 buildings
- RRT* path planning with collision avoidance
- Multi-drone sequential planning (3 simultaneous drones)
- Dynamic obstacle injection and reactive replanning
- Delivery logic with visual confirmation

## Requirements
- MATLAB R2024b or later
- UAV Toolbox
- Navigation Toolbox

## How to Run
1. Clone this repo
2. Open MATLAB and navigate to the project folder
3. Run `main_phase1` for single-drone demo
4. Run `main_phase2` for multi-drone demo
5. Run `main_phase3` for dynamic avoidance demo

## Technical Approach
- **Path Planning:** RRT* (Rapidly-exploring Random Tree Star)
- **Collision Checking:** 3D occupancy maps with safety inflation
- **Multi-Agent:** Sequential planning with shared occupied-path list
- **Dynamic Avoidance:** Local RRT replan triggered by proximity detection

## Author
Awais Shah — [LinkedIn](your-link) | [Portfolio](your-link)
```

**Step 14.10 — Push to GitHub:**

```bash
git init
git add .
git commit -m "Multi-UAV Path Planning - complete simulation"
git remote add origin https://github.com/your-username/Multi-UAV-Path-Planning.git
git push -u origin main
```

**Step 14.11 — Optional LinkedIn post:**

Write a short post linking your demo video and GitHub:

> "Built a multi-drone path planning simulation using MATLAB and the RRT* algorithm. Drones navigate a 3D city environment, avoid buildings and each other, and react to dynamic obstacles in real time. Full code on GitHub: [link]"

### Deliverable
A public GitHub repository with clean code, a README with screenshots, and a 1-3 minute demo video — ready to link from your CV, SOP, and portfolio.

---

## Timeline Summary

| Phase | Hours | Status | Key Deliverable |
|-------|-------|--------|-----------------|
| Phase 0 — Setup | 2-3 | ✅ Done (this guide) | MATLAB ready, toolboxes installed |
| Phase 1 — Single Drone | 4-5 | ✅ Done (code provided) | Single drone flies through city grid |
| Phase 2 — Multi-Drone | 5-6 | ⬜ Next | 3 drones flying simultaneously |
| Phase 3 — Dynamic Avoidance | 4-5 | ⬜ Upcoming | Drone swerves from surprise obstacle |
| Phase 4 — Polish + Packaging | 3-4 | ⬜ Final | GitHub repo + demo video |
| **Total** | **~18-23** | | **Portfolio-ready project** |

---

## Quick Reference Card

| Action | Command |
|--------|---------|
| Run the simulation | `main_phase1` |
| Check installed toolboxes | `ver` |
| Clear everything and start fresh | `clear; clc; close all;` |
| Change the drone's start position | Edit `uavStart` in `main_phase1.m` line 32 |
| Change the drone's goal position | Edit `uavGoal` in `main_phase1.m` line 33 |
| Change the drone's speed | Edit `uavSpeed` in `main_phase1.m` line 29 |
| Increase planning accuracy | Increase `MaxIterations` in `plan_uav_path.m` line 41 |
| Add/remove buildings | Edit the `buildingParams` section in `main_phase1.m` lines 39-54 |
| Change safety buffer | Edit `safetyDistance` in `main_phase1.m` line 26 |

---

*End of Guide*
