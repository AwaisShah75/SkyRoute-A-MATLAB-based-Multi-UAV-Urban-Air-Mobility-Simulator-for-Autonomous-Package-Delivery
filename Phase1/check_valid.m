% check_valid.m
% Diagnostic script to find out why the start or goal state is invalid.

% 1. Re-run setup
xBounds = [0, 100]; yBounds = [0, 100]; zBounds = [0, 50];
mapBounds = [xBounds; yBounds; zBounds];
mapResolution = 1;
safetyDistance = 1.5;
uavStart = [5, 5, 10];
uavGoal = [95, 95, 15]; % Updated to the new goal

buildingParams = struct('Position', {}, 'Size', {}, 'Height', {});
buildingParams(1).Position = [15, 15]; buildingParams(1).Size = [16, 16]; buildingParams(1).Height = 25;
buildingParams(2).Position = [50, 15]; buildingParams(2).Size = [18, 14]; buildingParams(2).Height = 30;
buildingParams(3).Position = [85, 15]; buildingParams(3).Size = [14, 16]; buildingParams(3).Height = 22;
buildingParams(4).Position = [15, 50]; buildingParams(4).Size = [14, 18]; buildingParams(4).Height = 35;
buildingParams(5).Position = [50, 50]; buildingParams(5).Size = [20, 20]; buildingParams(5).Height = 45;
buildingParams(6).Position = [85, 50]; buildingParams(6).Size = [16, 14]; buildingParams(6).Height = 28;
buildingParams(7).Position = [15, 85]; buildingParams(7).Size = [16, 16]; buildingParams(7).Height = 30;
buildingParams(8).Position = [50, 85]; buildingParams(8).Size = [14, 18]; buildingParams(8).Height = 20;
buildingParams(9).Position = [85, 85]; buildingParams(9).Size = [16, 16]; buildingParams(9).Height = 38;

[scenario, map3D, uav] = create_city_scenario(buildingParams, mapResolution, mapBounds);

% 2. Inflate map
collisionMap = copy(map3D);
if safetyDistance > 0
    inflate(collisionMap, safetyDistance);
end

% Post-inflation fix: set any unknown cells within our bounding box to free (0)
step = 1 / mapResolution;
xRange = mapBounds(1,1) : step : mapBounds(1,2);
yRange = mapBounds(2,1) : step : mapBounds(2,2);
zRange = mapBounds(3,1) : step : mapBounds(3,2);
[xGrid, yGrid, zGrid] = meshgrid(xRange, yRange, zRange);
allCoords = [xGrid(:), yGrid(:), zGrid(:)];

status = checkOccupancy(collisionMap, allCoords);
unknownIdx = (status == -1);
if any(unknownIdx)
    setOccupancy(collisionMap, allCoords(unknownIdx, :), 0);
end

% 3. Check map occupancy at start and goal
occStartRaw = checkOccupancy(map3D, uavStart);
occGoalRaw = checkOccupancy(map3D, uavGoal);
occStartInf = checkOccupancy(collisionMap, uavStart);
occGoalInf = checkOccupancy(collisionMap, uavGoal);

fprintf('--- MAP OCCUPANCY DIAGNOSTIC ---\n');
fprintf('Start [5,5,10] raw occupancy: %d (0=free, 1=occ, -1=unk)\n', occStartRaw);
fprintf('Goal [95,95,15] raw occupancy: %d (0=free, 1=occ, -1=unk)\n', occGoalRaw);
fprintf('Start [5,5,10] inflated occupancy: %d (0=free, 1=occ, -1=unk)\n', occStartInf);
fprintf('Goal [95,95,15] inflated occupancy: %d (0=free, 1=occ, -1=unk)\n', occGoalInf);

% 4. State Space SE3
ss = stateSpaceSE3([mapBounds(1,:); mapBounds(2,:); mapBounds(3,:); -inf inf; -inf inf; -inf inf; -inf inf]);

startState = [uavStart(:)', 1, 0, 0, 0];
goalState = [uavGoal(:)', 1, 0, 0, 0];

% 5. Validator validation check
sv = validatorOccupancyMap3D(ss);
sv.Map = collisionMap;
sv.ValidationDistance = 0.5;

valid_start = isStateValid(sv, startState);
valid_goal = isStateValid(sv, goalState);

fprintf('\n--- STATE VALIDATOR DIAGNOSTIC ---\n');
fprintf('Is start state valid under validator: %d\n', valid_start);
fprintf('Is goal state valid under validator: %d\n', valid_goal);
