function [allWaypoints, planningTimeMs, totalPathLen] = plan_multi_mission(map3D, drones, missions, mapBounds, safetyDistance)
% PLAN_MULTI_MISSION Plans outward delivery and return-to-base paths for each drone.
%
% Inputs:
%   map3D          - occupancyMap3D of the environment
%   drones         - Struct array with drone configuration (.base, .priority, .color)
%   missions       - Struct array representing the delivery queue (.goal, .priority)
%   mapBounds      - Environment bounds
%   safetyDistance  - Inflation radius for building avoidance
%
% Outputs:
%   allWaypoints   - Cell array containing the full concatenated waypoint paths for each drone
%   planningTimeMs - Total time spent planning paths in milliseconds
%   totalPathLen   - Total path length of all planned segments in meters

    numDrones = length(drones);
    allWaypoints = cell(numDrones, 1);
    
    planningTimeMs = 0;
    totalPathLen = 0;
    
    for i = 1:numDrones
        fprintf('\n--- Logistics Dispatcher: Planning Drone %d of %d ---\n', i, numDrones);
        basePos = drones(i).base;
        wps_full = [];
        
        % Dynamic allocation: Drone i gets mission i and mission i + numDrones (e.g. 1 and 11)
        m_idxs = [i, i + numDrones];
        for m_count = 1:length(m_idxs)
            m_idx = m_idxs(m_count);
            goalPos = missions(m_idx).goal;
            
            % 1. Outward Delivery Segment: Base -> Target Goal
            fprintf('  [Mission %d] Planning: Base -> Target Goal [%.1f, %.1f, %.1f]\n', ...
                    m_idx, goalPos(1), goalPos(2), goalPos(3));
            
            t_plan = tic;
            [wps_out, info_out] = plan_uav_path(map3D, basePos, goalPos, mapBounds, safetyDistance);
            t_el = toc(t_plan);
            planningTimeMs = planningTimeMs + (t_el * 1000);
            
            if ~info_out.IsPathFound
                error('Logistics Dispatcher: RRT* failed to find path for Drone %d to Goal %d!', i, m_idx);
            end
            
            % Calculate length
            if size(wps_out, 1) > 1
                totalPathLen = totalPathLen + sum(sqrt(sum(diff(wps_out, 1, 1).^2, 2)));
            end
            
            % 2. Return-to-Base Segment: Target Goal -> Base
            fprintf('  [Mission %d] Planning: Target Goal -> Return to Base [%.1f, %.1f, %.1f]\n', ...
                    m_idx, basePos(1), basePos(2), basePos(3));
            
            t_plan = tic;
            [wps_ret, info_ret] = plan_uav_path(map3D, goalPos, basePos, mapBounds, safetyDistance);
            t_el = toc(t_plan);
            planningTimeMs = planningTimeMs + (t_el * 1000);
            
            if ~info_ret.IsPathFound
                error('Logistics Dispatcher: RRT* failed to find return path for Drone %d from Goal %d!', i, m_idx);
            end
            
            % Calculate length
            if size(wps_ret, 1) > 1
                totalPathLen = totalPathLen + sum(sqrt(sum(diff(wps_ret, 1, 1).^2, 2)));
            end
            
            % Concatenate waypoints continuously
            if isempty(wps_full)
                wps_full = [wps_out; wps_ret(2:end, :)];
            else
                wps_full = [wps_full; wps_out(2:end, :); wps_ret(2:end, :)];
            end
        end
        allWaypoints{i} = wps_full;
        fprintf('  Drone %d logistics routing completed: %d total waypoints\n', i, size(wps_full, 1));
    end
end
