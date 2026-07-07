% main_phase2.m
% Phase 2: Multi-Drone Extension
% 3 drones fly through the city simultaneously on collision-free paths.
%
% Dependencies: UAV Toolbox, Navigation Toolbox

clear; clc; close all;

%% 1. Configuration
xBounds = [0, 100]; yBounds = [0, 100]; zBounds = [0, 50];
mapBounds = [xBounds; yBounds; zBounds];
mapResolution = 1;
safetyDistance = 1.5;
pathRadius = 4.0;       % exclusion zone around each drone's path (meters)
uavSpeed = 3.0;

%% 2. Define 3 Drone Missions
drones(1).start = [5, 5, 10];   drones(1).goal = [95, 95, 15];  drones(1).color = [0 0.4 1];
drones(2).start = [5, 95, 12];  drones(2).goal = [95, 5, 10];   drones(2).color = [1 0.2 0.2];
drones(3).start = [5, 50, 20];  drones(3).goal = [95, 50, 8];   drones(3).color = [0.2 0.8 0.2];

%% 3. Define Buildings (3x3 city grid — same as Phase 1)
b = struct('Position', {}, 'Size', {}, 'Height', {});
b(1).Position=[15,15]; b(1).Size=[16,16]; b(1).Height=25;
b(2).Position=[50,15]; b(2).Size=[18,14]; b(2).Height=30;
b(3).Position=[85,15]; b(3).Size=[14,16]; b(3).Height=22;
b(4).Position=[15,50]; b(4).Size=[14,18]; b(4).Height=35;
b(5).Position=[50,50]; b(5).Size=[20,20]; b(5).Height=45;
b(6).Position=[85,50]; b(6).Size=[16,14]; b(6).Height=28;
b(7).Position=[15,85]; b(7).Size=[16,16]; b(7).Height=30;
b(8).Position=[50,85]; b(8).Size=[14,18]; b(8).Height=20;
b(9).Position=[85,85]; b(9).Size=[16,16]; b(9).Height=38;

%% 4. Build Scenario (no UAV created — we make our own below)
fprintf('Building city scenario...\n');
[scenario, map3D] = create_city_scenario(b, mapResolution, mapBounds);

%% 5. Create UAV Platforms (one per drone, each with its own color)
uavPlatforms = [];
for i = 1:length(drones)
    p = uavPlatform(sprintf('UAV%d', i), scenario);
    updateMesh(p, 'quadrotor', {1.2}, drones(i).color, eye(4));
    uavPlatforms = [uavPlatforms, p]; %#ok<AGROW>
end

%% 6. Plan Paths Sequentially
fprintf('Planning multi-drone paths...\n');
[allWaypoints, allInfo] = plan_multi_uav(map3D, drones, mapBounds, safetyDistance, pathRadius);

for i = 1:length(drones)
    if allInfo{i}.IsPathFound
        fprintf('  Drone %d: path found (%d waypoints)\n', i, size(allWaypoints{i},1));
    else
        fprintf('  Drone %d: *** PATH NOT FOUND ***\n', i);
    end
end

%% 7. Animate All Drones
fprintf('Launching multi-drone animation...\n');
animate_multi_uav(scenario, uavPlatforms, allWaypoints, drones, uavSpeed);
