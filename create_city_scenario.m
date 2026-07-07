function [scenario, map3D, uav] = create_city_scenario(buildingParams, mapResolution, mapBounds)
% CREATE_CITY_SCENARIO Sets up a 3D simulation environment and occupancy map.
%
% Inputs:
%   buildingParams - Struct array with fields:
%                    .Position - [x, y] center of the building footprint
%                    .Size     - [width_x, length_y] footprint dimensions
%                    .Height   - Building height
%   mapResolution  - Resolution of occupancyMap3D (cells/meter)
%   mapBounds      - 3x2 matrix [xMin xMax; yMin yMax; zMin zMax] defining
%                    the environment extents (used for ground plane)
%
% Outputs:
%   scenario - uavScenario object representing the simulation environment
%   map3D    - occupancyMap3D object used for collision checking
%   uav      - uavPlatform object representing the drone in the scenario

    % 1. Initialize the UAV Scenario
    % We set the update rate to 10 Hz for simulation steps.
    scenario = uavScenario('UpdateRate', 10, 'ReferenceLocation', [0 0 0]);
    
    % 2. Initialize the 3D Occupancy Map
    map3D = occupancyMap3D(mapResolution);
    
    % Set the entire bounding box to 0 (free space) so unobserved areas
    % are not treated as unknown (-1) / invalid by the validator.
    step = 1 / mapResolution;
    xRange = mapBounds(1,1) : step : mapBounds(1,2);
    yRange = mapBounds(2,1) : step : mapBounds(2,2);
    zRange = mapBounds(3,1) : step : mapBounds(3,2);
    [xGrid, yGrid, zGrid] = meshgrid(xRange, yRange, zRange);
    setOccupancy(map3D, [xGrid(:) yGrid(:) zGrid(:)], 0);
    
    % 3. Add buildings to both the scenario mesh and the occupancy map
    numBuildings = length(buildingParams);
    
    for i = 1:numBuildings
        pos = buildingParams(i).Position;
        sz = buildingParams(i).Size;
        h = buildingParams(i).Height;
        
        % Calculate building boundaries
        xMin = pos(1) - sz(1)/2;
        xMax = pos(1) + sz(1)/2;
        yMin = pos(2) - sz(2)/2;
        yMax = pos(2) + sz(2)/2;
        
        % A. Add building to uavScenario
        % Footprint vertices in counter-clockwise order
        vertices = [xMin, yMin; ...
                    xMax, yMin; ...
                    xMax, yMax; ...
                    xMin, yMax];
        
        % Add mesh representation (using gray color [0.5 0.5 0.5])
        addMesh(scenario, 'polygon', {vertices, [0 h]}, [0.5 0.5 0.5]);
        
        % B. Populate building volume in the 3D occupancy map
        % Define sampling grid based on map resolution
        step = 1 / mapResolution;
        xRange = xMin : step : xMax;
        yRange = yMin : step : yMax;
        zRange = 0 : step : h;
        
        [xGrid, yGrid, zGrid] = meshgrid(xRange, yRange, zRange);
        xyz = [xGrid(:), yGrid(:), zGrid(:)];
        
        % Set occupancy to 1 (occupied)
        setOccupancy(map3D, xyz, 1);
    end
    
    % 4. Add a ground plane for visual context
    groundVertices = [mapBounds(1,1), mapBounds(2,1); ...
                      mapBounds(1,2), mapBounds(2,1); ...
                      mapBounds(1,2), mapBounds(2,2); ...
                      mapBounds(1,1), mapBounds(2,2)];
    addMesh(scenario, 'polygon', {groundVertices, [-0.25 0]}, [0.3 0.6 0.3]);
    
    % 5. Add the UAV Platform to the scenario
    % We call the platform "UAV"
    uav = uavPlatform('UAV', scenario);
    
    % Update the mesh for the UAV platform to display a quadrotor
    % Scale: 1.0, Color: Blue [0 0 1], Orientation Offset: Identity matrix
    updateMesh(uav, 'quadrotor', {1.0}, [0 0 1], eye(4));
    
end
