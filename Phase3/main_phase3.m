% main_phase3.m
% Phase 3: Logistics Scheduling + Priority-Based Dynamic Avoidance
% 10 Drones, 40 Skyscrapers, 20 Delivery Missions Queue.
% Drones automatically coordinate, route, deliver, and return to base.
%
% Dependencies: UAV Toolbox, Navigation Toolbox

clear; clc; close all;

%% 1. Configuration
xBounds = [0, 200]; yBounds = [0, 200]; zBounds = [0, 50];
mapBounds = [xBounds; yBounds; zBounds];
mapResolution = 1;
safetyDistance = 2.0; % Inflated safety buffer for buildings
pathRadius = 4.0;
uavSpeed = 4.0;       % Drones fly slightly faster in this large city

% Dynamic obstacle configuration (Main dynamic warning towers)
obstaclePos    = [100, 100, 15];  % where the obstacle appears
obstacleRadius = 5;               % meters
obstacleZRange = [8, 28];         % cylinder height range
obstacleSpawnTime = 12.0;         % seconds into the simulation

%% 2. Define 10 Drone Base Stations & Priorities
% Priority 3 = High (Medical), 2 = Medium (Standard), 1 = Low (Inspection)
drones = struct('base', {}, 'priority', {}, 'color', {});
drones(1).base = [5, 5, 10];      drones(1).priority = 3; drones(1).color = [0.1, 0.4, 0.9];  % Blue
drones(2).base = [5, 198, 12];    drones(2).priority = 2; drones(2).color = [0.9, 0.5, 0.0];  % Orange
drones(3).base = [5, 100, 20];    drones(3).priority = 1; drones(3).color = [0.1, 0.8, 0.2];  % Green
drones(4).base = [195, 5, 15];    drones(4).priority = 3; drones(4).color = [0.6, 0.1, 0.8];  % Purple
drones(5).base = [195, 198, 8];   drones(5).priority = 2; drones(5).color = [0.9, 0.1, 0.1];  % Red
drones(6).base = [195, 100, 12];  drones(6).priority = 1; drones(6).color = [0.1, 0.8, 0.8];  % Cyan
drones(7).base = [100, 5, 10];    drones(7).priority = 3; drones(7).color = [0.8, 0.1, 0.5];  % Magenta
drones(8).base = [100, 198, 15];  drones(8).priority = 2; drones(8).color = [0.8, 0.8, 0.1];  % Yellow
drones(9).base = [68, 5, 18];     drones(9).priority = 1; drones(9).color = [0.9, 0.4, 0.6];  % Pink
drones(10).base = [132, 198, 12]; drones(10).priority = 2; drones(10).color = [0.1, 0.6, 0.6]; % Teal

%% 3. Define 20 Delivery Missions Queue
missions = struct('goal', {}, 'priority', {});
missions(1).goal = [36, 34, 12];    missions(1).priority = 3;
missions(2).goal = [68, 34, 15];    missions(2).priority = 2;
missions(3).goal = [100, 34, 10];   missions(3).priority = 1;
missions(4).goal = [132, 34, 14];   missions(4).priority = 3;
missions(5).goal = [164, 34, 8];    missions(5).priority = 2;
missions(6).goal = [36, 62, 12];    missions(6).priority = 1;
missions(7).goal = [68, 62, 16];    missions(7).priority = 3;
missions(8).goal = [100, 62, 10];   missions(8).priority = 2;
missions(9).goal = [132, 62, 15];   missions(9).priority = 1;
missions(10).goal = [164, 62, 11];  missions(10).priority = 2;
missions(11).goal = [36, 90, 14];    missions(11).priority = 3;
missions(12).goal = [68, 90, 12];    missions(12).priority = 2;
missions(13).goal = [100, 90, 18];   missions(13).priority = 1;
missions(14).goal = [132, 90, 10];   missions(14).priority = 3;
missions(15).goal = [164, 90, 15];   missions(15).priority = 2;
missions(16).goal = [36, 118, 12];   missions(16).priority = 1;
missions(17).goal = [68, 118, 16];   missions(17).priority = 3;
missions(18).goal = [100, 118, 10];  missions(18).priority = 2;
missions(19).goal = [132, 118, 14];  missions(19).priority = 1;
missions(20).goal = [164, 118, 8];   missions(20).priority = 2;

%% 4. Procedural City Generation (Exactly 40 Skyscrapers)
fprintf('Procedurally generating 40 skyscrapers...\n');
rng(42); % Seed for reproducible layout
b = struct('Position', {}, 'Size', {}, 'Height', {});
b_idx = 1;

x_coords = [20, 52, 84, 116, 148, 180];
y_coords = [20, 48, 76, 104, 132, 160, 188];

for col = 1:length(x_coords)
    for row = 1:length(y_coords)
        % Skip 2 grid intersections to get exactly 40 skyscrapers
        if (col == 1 && row == 1) || (col == 6 && row == 7)
            continue;
        end
        if b_idx <= 40
            % Add slight random offsets for organic layout
            px = x_coords(col) + (rand()-0.5)*4;
            py = y_coords(row) + (rand()-0.5)*4;
            b(b_idx).Position = [px, py];
            b(b_idx).Size = [12 + randi(6), 12 + randi(6)];
            b(b_idx).Height = 15 + randi(30);
            b_idx = b_idx + 1;
        end
    end
end

%% 5. Build Scenario
fprintf('Building city scenario...\n');
[scenario, map3D] = create_city_scenario(b, mapResolution, mapBounds);

%% 6. Create 10 UAV Platforms
uavPlatforms = [];
for i = 1:length(drones)
    p = uavPlatform(sprintf('UAV%d', i), scenario);
    updateMesh(p, 'quadrotor', {1.2}, drones(i).color, eye(4));
    uavPlatforms = [uavPlatforms, p]; %#ok<AGROW>
end

%% 7. Plan Paths using Logistics Dispatcher
fprintf('Launching logistics dispatcher...\n');
[allWaypoints, totalPlanningTimeMs, totalPathLen] = ...
    plan_multi_mission(map3D, drones, missions, mapBounds, safetyDistance);

%% 8. Animate and Solve Avoidance + Log Metrics
fprintf('Launching dynamic multi-mission simulation...\n');

obstacleConfig.pos       = obstaclePos;
obstacleConfig.radius    = obstacleRadius;
obstacleConfig.zRange    = obstacleZRange;
obstacleConfig.spawnTime = obstacleSpawnTime;

cinematicCamera = false; % Keep false in MATLAB Online to prevent freezing

animate_phase3(scenario, uavPlatforms, allWaypoints, drones, missions, uavSpeed, ...
               map3D, mapBounds, safetyDistance, obstacleConfig, cinematicCamera, ...
               totalPlanningTimeMs, totalPathLen, b);
