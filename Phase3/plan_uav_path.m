function [waypoints, solnInfo] = plan_uav_path(map3D, startPos, goalPos, mapBounds, safetyDistance)
% PLAN_UAV_PATH Plans a 3D collision-free path for a UAV from start to goal.
%
% Inputs:
%   map3D          - The occupancyMap3D object of the environment
%   startPos       - [x, y, z] start position
%   goalPos        - [x, y, z] goal position
%   mapBounds      - 3x2 matrix specifying the [min, max] limits of x, y, and z.
%                    Example: [xMin xMax; yMin yMax; zMin zMax]
%   safetyDistance - The inflation radius (in meters) to prevent the UAV from
%                    crashing into buildings.
%
% Outputs:
%   waypoints - N-by-3 matrix of coordinates [x, y, z] representing the path
%   solnInfo  - Struct with planning details (IsPathFound, Iterations, etc.)

    % 1. Create a copy of the occupancy map and inflate it for collision checking.
    % This keeps the original map clean for visual rendering while planning safely.
    collisionMap = copy(map3D);
    if safetyDistance > 0
        inflate(collisionMap, safetyDistance);
    end
    
    % Post-inflation fix: set any unknown cells within our bounding box to free (0)
    % so that the state validator doesn't treat unobserved space as occupied/invalid.
    step = 1 / collisionMap.Resolution;
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
    
    % 2. Define the State Space for the UAV
    % For 3D movement, we use stateSpaceSE3 which represents [x y z qw qx qy qz].
    ss = stateSpaceSE3([mapBounds(1,:); ...
                        mapBounds(2,:); ...
                        mapBounds(3,:); ...
                        -inf inf; -inf inf; -inf inf; -inf inf]);
    
    % 3. Set up the State Validator
    % The validator checks if states and paths between states are collision-free.
    sv = validatorOccupancyMap3D(ss);
    sv.Map = collisionMap;
    sv.ValidationDistance = 0.5; % step size in meters for checking edges
    
    % 4. Initialize the RRT* Planner
    % RRT* is used because it optimizes path length over iterations.
    planner = plannerRRTStar(ss, sv);
    planner.MaxConnectionDistance = 15; % Maximum distance to extend tree node
    planner.MaxIterations = 3000;       % Maximum iterations to search
    planner.GoalBias = 0.10;            % 10% bias towards the goal
    planner.ContinueAfterGoalReached = true; % Keep optimizing path after goal is found
    
    % 5. Formulate Start and Goal Poses for SE3 Space
    % We set the orientation quaternions to identity [1 0 0 0].
    startState = [startPos(:)', 1, 0, 0, 0];
    goalState = [goalPos(:)', 1, 0, 0, 0];
    
    % 6. Execute Path Planning
    fprintf('Planning path from [%.1f, %.1f, %.1f] to [%.1f, %.1f, %.1f]...\n', ...
            startPos(1), startPos(2), startPos(3), goalPos(1), goalPos(2), goalPos(3));
    
    [pathObj, solnInfo] = plan(planner, startState, goalState);
    
    % 7. Extract Waypoints
    if solnInfo.IsPathFound
        fprintf('Path found successfully in %d iterations!\n', solnInfo.NumIterations);
        % Extract the [x, y, z] columns from the planned states
        waypoints = pathObj.States(:, 1:3);
    else
        warning('RRT* failed to find a collision-free path. Try adjusting bounds or start/goal positions.');
        waypoints = [];
    end
    
end
