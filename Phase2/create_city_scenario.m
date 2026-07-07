function [scenario, map3D] = create_city_scenario(buildingParams, mapResolution, mapBounds)
% CREATE_CITY_SCENARIO Sets up a 3D simulation environment and occupancy map.
% This version does NOT create a UAV platform — the caller creates their own.
%
% Inputs:
%   buildingParams - Struct array with .Position, .Size, .Height fields
%   mapResolution  - Resolution of occupancyMap3D (cells/meter)
%   mapBounds      - 3x2 matrix [xMin xMax; yMin yMax; zMin zMax]
%
% Outputs:
%   scenario - uavScenario object
%   map3D    - occupancyMap3D object for collision checking

    % 1. Initialize the UAV Scenario
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
    
    % 3. Add buildings
    numBuildings = length(buildingParams);
    
    for i = 1:numBuildings
        pos = buildingParams(i).Position;
        sz = buildingParams(i).Size;
        h = buildingParams(i).Height;
        
        xMin = pos(1) - sz(1)/2;  xMax = pos(1) + sz(1)/2;
        yMin = pos(2) - sz(2)/2;  yMax = pos(2) + sz(2)/2;
        
        vertices = [xMin yMin; xMax yMin; xMax yMax; xMin yMax];
        addMesh(scenario, 'polygon', {vertices, [0 h]}, [0.5 0.5 0.5]);
        
        step = 1 / mapResolution;
        [xG, yG, zG] = meshgrid(xMin:step:xMax, yMin:step:yMax, 0:step:h);
        setOccupancy(map3D, [xG(:) yG(:) zG(:)], 1);
    end
    
    % 4. Add ground plane
    gv = [mapBounds(1,1) mapBounds(2,1); mapBounds(1,2) mapBounds(2,1); ...
          mapBounds(1,2) mapBounds(2,2); mapBounds(1,1) mapBounds(2,2)];
    addMesh(scenario, 'polygon', {gv, [-0.25 0]}, [0.3 0.6 0.3]);

end
