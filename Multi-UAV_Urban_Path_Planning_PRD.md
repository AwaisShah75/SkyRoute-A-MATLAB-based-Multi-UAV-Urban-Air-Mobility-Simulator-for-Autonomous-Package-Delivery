# Multi-UAV Path Planning for Urban Air Mobility
### Product Requirements Document + Step-by-Step Build Guide
**Owner:** Awais Shah
**Status:** Planning (not started)
**Based on:** MathWorks Challenge Project Hub, Project #247
**Purpose:** Independent portfolio project for MS applications (not submitting to MathWorks Hub)

---

## 1. Overview

Build a simulated multi-drone system that plans collision-free 3D paths through an urban environment, delivers "packages" to designated points, and avoids both static obstacles (buildings) and dynamic obstacles (other drones), using MATLAB/Simulink and UAV Toolbox.

This project exists to demonstrate range beyond your current edge-AI/CV identity (EADS, EdgeITS) into simulation, multi-agent systems, and optimization — while staying inside the same broader theme of **efficient, autonomous perception and decision-making under constraints.**

---

## 2. Goals

- Produce a working, visually convincing demo of multiple drones flying through a city-like environment, avoiding obstacles and each other, to reach delivery targets.
- Learn and demonstrate: 3D path planning (RRT/RRT*), multi-agent collision avoidance, occupancy mapping, basic sensor fusion concepts, MATLAB/Simulink workflow.
- Produce shareable artifacts: GitHub repo with clean code + README, and a demo video (screen recording of the simulation) for YouTube/LinkedIn/portfolio use.
- Keep total build time realistic against your MATLAB Online free-tier budget (20 hrs/month) and MS application timeline.

## 3. Non-Goals (explicitly out of scope for v1)

- No real hardware deployment (pure simulation).
- No wind simulation, no-fly zones, or battery modeling in v1 (stretch goals only, add later if time allows).
- No reinforcement learning — use classical planners (RRT/RRT*) first; ML-based planning is a possible v2 extension, not a v1 requirement.
- No requirement to submit to the MathWorks Hub — this is your own independent build, referencing their brief for structure only.
- Not aiming for Unreal-Engine-level photorealism — "clean simulation" visual quality is the target, not cinematic realism.

## 4. Success Criteria

| Criterion | Target |
|---|---|
| Single drone plans a collision-free path around static buildings | Working, visualized in 3D |
| Path planner extends to 2–3 drones simultaneously | No collisions between drones in test runs |
| Drones reach designated "delivery" waypoints and simulate a drop-off | Visual confirmation (marker/animation) |
| At least one dynamic/decentralized avoidance behavior | Drone reroutes in real time when another drone or obstacle enters its path |
| Demo video produced | 1–3 min screen recording, narrated or captioned |
| Code pushed to GitHub with README | Public repo, install/run instructions included |

---

## 5. Technical Requirements

**Platform:** MATLAB Online (browser-based, free 20 hrs/month tier)
**Toolboxes needed:**
- UAV Toolbox (core — scenario, platform, path planning)
- Navigation Toolbox (occupancy maps, RRT/RRT* planners — bundled with some UAV Toolbox examples)
- Sensor Fusion and Tracking Toolbox (for centralized tracking of multiple drones' positions/velocities)
- Optimization Toolbox (for later trajectory refinement, if pursued)

**Key MATLAB objects/functions you'll be using:**
- `uavScenario` — the environment container (buildings, drones, ground)
- `uavPlatform` — individual drone objects within the scenario
- `occupancyMap3D` — 3D occupancy grid for collision checking
- `plannerRRT` / `plannerRRTStar` — sampling-based path planners
- `exampleHelperUAVStateSpace` (referenced in official RRT fixed-wing UAV example) — for encoding UAV motion constraints into the planner's state space
- `uavDynamics` / built-in multirotor guidance models — for realistic-enough motion simulation

**Known blocker (documented in the MathWorks discussion thread):**
There is no direct method to generate an occupancy grid from a scenario built in the UAV Designer App. The maintainer's official workaround: build the occupancy map using a simulated lidar sensor sweeping the scenario, not by exporting the app's map directly. Budget time for this step — multiple other students hit this same wall.

---

## 6. Phased Build Plan

### Phase 0 — Setup & Fundamentals (~2–3 hrs, doesn't need to eat your 20 free hrs)
- [ ] Create MathWorks account, log into MATLAB Online
- [ ] Confirm access to UAV Toolbox, Navigation Toolbox, Sensor Fusion and Tracking Toolbox
- [ ] Watch/skim (outside MATLAB Online, via YouTube/docs where possible to save hours): MATLAB Onramp, Simulink Onramp, Optimization Onramp
- [ ] Read through 2–3 official UAV Toolbox path planning examples (search "UAV path planning example" in MATLAB docs) to see canonical syntax before writing your own

**Deliverable:** Comfortable with basic `uavScenario` setup and terminology; no original code yet.

---

### Phase 1 — Single Drone, Static Obstacles (~4–5 hrs)
- [ ] Build a `uavScenario` with a simplified "city block" — a handful of cuboid buildings positioned in a grid (don't model a real city yet)
- [ ] Add one `uavPlatform` (drone) with start and goal positions
- [ ] Generate a 3D occupancy map of the buildings (`occupancyMap3D`) — start simple: derive it directly from your known building geometry rather than lidar, since you're building the scene yourself at this stage
- [ ] Implement RRT or RRT* planning (`plannerRRT`/`plannerRRTStar`) to find a collision-free path from start to goal
- [ ] Visualize the path in 3D against the building scenario
- [ ] Animate the drone flying the planned path (basic waypoint following is fine — doesn't need full flight dynamics yet)

**Deliverable:** A single drone visibly navigates around static cuboid buildings to reach a goal point. Screenshot/short clip worth saving.

**Checkpoint:** This alone is a legitimate mini-demo if time runs short — don't skip polishing this before moving on.

---

### Phase 2 — Multi-Drone Extension (~5–6 hrs)
- [ ] Add 2–3 `uavPlatform` drones to the same scenario, each with distinct start/goal pairs
- [ ] Set up centralized tracking: maintain a shared list of all drones' current positions/velocities (ground-truth values from the simulation, not sensor-estimated yet — that's the MathWorks brief's own recommended starting point)
- [ ] Extend your path planner so each drone's plan accounts for the others' planned/current positions (simplest approach: sequential re-planning — plan drone 1, mark its path as "occupied" for drone 2's planner, etc.)
- [ ] Run all drones simultaneously; visually confirm no collisions between drones or with buildings
- [ ] If collisions occur, add a minimum-separation buffer/constraint to the shared occupancy check

**Deliverable:** 2–3 drones flying simultaneously through the scene without colliding with each other or buildings.

---

### Phase 3 — Delivery Logic + Decentralized Avoidance (~4–5 hrs)
- [ ] Add "delivery" semantics: when a drone reaches its goal, trigger a simple visual event (marker change, drone pause + descend animation, log message)
- [ ] Introduce at least one dynamic obstacle (a moving object, or another drone appearing mid-simulation) that isn't known at planning time
- [ ] Implement basic decentralized/reactive avoidance: if an obstacle enters a drone's near-range during flight, trigger local replanning or a simple avoidance maneuver (e.g., potential-field push, or emergency reroute via a quick local RRT call) rather than relying solely on the original global plan
- [ ] Test edge cases: obstacle appears directly on the planned path, obstacle appears near the goal, two drones' reroutes conflict with each other

**Deliverable:** At least one clear moment in the demo where a drone visibly reacts to an unplanned obstacle in real time — this is your strongest "wow" moment for the video.

---

### Phase 4 — Polish, Demo Video, GitHub Packaging (~3–4 hrs)
- [ ] Improve the visual scenario: better building layout resembling a small city grid, clearer color-coding for drones/paths/goals
- [ ] Record a clean screen-capture flythrough (1–3 minutes) — consider adding an overlay showing the planned vs. actual path, or a simple on-screen counter (e.g., "obstacles avoided: 2")
- [ ] Write a clear README: problem statement, approach, tools used, how to run it, GIF/screenshot preview, link to demo video
- [ ] Push clean, commented code to GitHub
- [ ] Optional: short LinkedIn/portfolio post summarizing the project and linking the video

**Deliverable:** Public GitHub repo + demo video, ready to link from your CV/SOP/portfolio site.

---

## 7. Timeline Estimate

| Phase | Hours | Notes |
|---|---|---|
| 0 — Setup | 2–3 | Do outside MATLAB Online where possible |
| 1 — Single drone | 4–5 | Core deliverable even if nothing else finishes |
| 2 — Multi-drone | 5–6 | Most technically demanding phase |
| 3 — Dynamic avoidance | 4–5 | Best "demo moment" — don't rush this |
| 4 — Polish + packaging | 3–4 | Don't skip — this is what recruiters/profs actually see first |
| **Total** | **~18–23 hrs** | Roughly one MATLAB Online free-tier month; consider a 30-day trial around Phase 2–3 if you need a burst of extra hours |

---

## 8. Risks & Mitigations

| Risk | Mitigation |
|---|---|
| Occupancy map generation from UAV Designer App scenario doesn't work directly | Known issue — use simulated lidar sweep, or (simpler for v1) derive the occupancy map directly from your own building geometry instead of the Designer App |
| Multi-drone planning becomes complex/buggy | Start with sequential planning + shared occupied-path list before attempting true simultaneous/decentralized planning |
| Running out of free MATLAB Online hours mid-project | Time a 30-day full trial around your most compute-heavy phase (2–3); do reading/learning outside MATLAB Online |
| Scenario looks too plain/unimpressive for video | Prioritize Phase 4 polish time — color coding, camera angles, and a clean building layout do more for visual impact than photorealism |
| Time conflict with IELTS prep / MS deadlines | Treat Phase 1 as a standalone checkpoint — a good single-drone demo alone is still creditable if Phases 2–4 get cut short |

---

## 9. Resources

- Official project brief: https://github.com/mathworks/MATLAB-Simulink-Challenge-Project-Hub/tree/main/projects/Multi-UAV%20Path%20Planning%20for%20Urban%20Air%20Mobility
- Discussion thread (troubleshooting, occupancy map issue): https://github.com/mathworks/MATLAB-Simulink-Challenge-Project-Hub/discussions/85
- MATLAB Online: https://matlab.mathworks.com/
- Referenced official example: "Motion planning with RRT for a fixed-wing UAV" (search in MATLAB documentation)
- Referenced example: "Generate Random 3-D Occupancy Map for UAV Motion Planning" (MATLAB docs)

---

## 10. Notes

- This PRD is intentionally scoped as an **independent portfolio project**, not a formal submission to the MathWorks Hub — no deadline pressure, no review dependency.
- Feel free to lift structural ideas from the official 3-stage brief, but the deliverables above are simplified/re-sequenced for solo, time-boxed execution.
- Revisit this document and check off items as you go — update the Phase checklists directly.
