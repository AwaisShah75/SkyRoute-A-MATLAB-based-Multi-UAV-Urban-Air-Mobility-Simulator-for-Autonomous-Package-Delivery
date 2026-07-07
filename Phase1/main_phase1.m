% main_phase1.m
% Entry point script for Phase 1: Single Drone, Static Obstacles.
%
% This script sets up a simulated city block, defines start and goal
% positions for a multirotor UAV, plans a collision-free 3D path using
% the RRT* planning algorithm, and animates the resulting simulation.
%
% Dependencies: UAV Toolbox, Navigation Toolbox

clear;
clc;
close all;

%% 1. Configuration & Parameters

% Environment Boundaries [min, max]
xBounds = [0, 100];
yBounds = [0, 100];
zBounds = [0, 50];
mapBounds = [xBounds; yBounds; zBounds];

% Occupancy Map Resolution (cells/meter)
mapResolution = 1; 

% Safety Clearance (in meters) - Drone will maintain this distance from buildings
safetyDistance = 1.5; 

% UAV Flight Speed (in m/s)
uavSpeed = 3.0;

% Define UAV Start and Goal locations [x, y, z]
uavStart = [5, 5, 10];
uavGoal = [95, 95, 15];

%% 2. Define Buildings (City Block Layout — 3x3 Grid)
% Nine buildings arranged in a grid pattern with ~15-20m streets between them.
% Heights vary to force interesting 3D path planning decisions.
% The tallest building (45m) sits in the center of the grid.
buildingParams = struct('Position', {}, 'Size', {}, 'Height', {});

% Row 1 — near side (y ≈ 15)
buildingParams(1).Position = [15, 15]; buildingParams(1).Size = [16, 16]; buildingParams(1).Height = 25;
buildingParams(2).Position = [50, 15]; buildingParams(2).Size = [18, 14]; buildingParams(2).Height = 30;
buildingParams(3).Position = [85, 15]; buildingParams(3).Size = [14, 16]; buildingParams(3).Height = 22;

% Row 2 — middle (y ≈ 50)
buildingParams(4).Position = [15, 50]; buildingParams(4).Size = [14, 18]; buildingParams(4).Height = 35;
buildingParams(5).Position = [50, 50]; buildingParams(5).Size = [20, 20]; buildingParams(5).Height = 45;
buildingParams(6).Position = [85, 50]; buildingParams(6).Size = [16, 14]; buildingParams(6).Height = 28;

% Row 3 — far side (y ≈ 85)
buildingParams(7).Position = [15, 85]; buildingParams(7).Size = [16, 16]; buildingParams(7).Height = 30;
buildingParams(8).Position = [50, 85]; buildingParams(8).Size = [14, 18]; buildingParams(8).Height = 20;
buildingParams(9).Position = [85, 85]; buildingParams(9).Size = [16, 16]; buildingParams(9).Height = 38;

%% 3. Build Scenario and Occupancy Map
fprintf('Initializing city block scenario...\n');
[scenario, map3D, uav] = create_city_scenario(buildingParams, mapResolution, mapBounds);

%% 4. Plan Collision-Free Path
fprintf('Computing RRT* path...\n');
[waypoints, solnInfo] = plan_uav_path(map3D, uavStart, uavGoal, mapBounds, safetyDistance);

%% 5. Run Animation and Simulation
if solnInfo.IsPathFound
    fprintf('Animating flight simulation...\n');
    animate_uav(scenario, uav, waypoints, uavSpeed);
else
    error('Could not run animation because no valid path was found.');
end
