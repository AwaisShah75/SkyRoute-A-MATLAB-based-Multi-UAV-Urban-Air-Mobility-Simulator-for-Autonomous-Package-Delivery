function [allWaypoints, allInfo] = plan_multi_uav(map3D, drones, mapBounds, safetyDistance, pathRadius)
% PLAN_MULTI_UAV Plans collision-free paths for multiple drones sequentially.
% Each drone's planned path is marked as occupied before planning the next,
% ensuring inter-drone collision avoidance.
%
% Inputs:
%   map3D          - occupancyMap3D of the environment
%   drones         - Struct array with .start [x,y,z] and .goal [x,y,z]
%   mapBounds      - 3x2 matrix [xMin xMax; yMin yMax; zMin zMax]
%   safetyDistance  - Inflation radius for building avoidance (meters)
%   pathRadius     - Radius to mark around each waypoint as occupied (meters)
%
% Outputs:
%   allWaypoints   - Cell array, one N-by-3 matrix per drone
%   allInfo        - Cell array of solnInfo structs

    numDrones = length(drones);
    allWaypoints = cell(numDrones, 1);
    allInfo = cell(numDrones, 1);
    
    % Work on a copy so we can progressively mark paths as occupied
    planningMap = copy(map3D);
    
    for i = 1:numDrones
        fprintf('  Planning Drone %d of %d...\n', i, numDrones);
        
        [wps, info] = plan_uav_path(planningMap, drones(i).start, drones(i).goal, ...
                                    mapBounds, safetyDistance);
        
        allWaypoints{i} = wps;
        allInfo{i} = info;
        
        if ~info.IsPathFound
            warning('Drone %d failed to find a path!', i);
            continue;
        end
        
        % Mark this drone's planned path as occupied for subsequent drones.
        % We create a cube of occupied cells around each waypoint, then
        % filter to only keep points within a sphere of radius pathRadius.
        step = 1 / planningMap.Resolution;
        for j = 1:size(wps, 1)
            rng = -pathRadius:step:pathRadius;
            [dx, dy, dz] = meshgrid(rng, rng, rng);
            dists = sqrt(dx(:).^2 + dy(:).^2 + dz(:).^2);
            mask = dists <= pathRadius;
            pts = [dx(mask) + wps(j,1), dy(mask) + wps(j,2), dz(mask) + wps(j,3)];
            if ~isempty(pts)
                setOccupancy(planningMap, pts, 1);
            end
        end
        
        fprintf('  Drone %d: path marked (%d waypoints, %.1fm exclusion radius)\n', ...
                i, size(wps,1), pathRadius);
    end
end
