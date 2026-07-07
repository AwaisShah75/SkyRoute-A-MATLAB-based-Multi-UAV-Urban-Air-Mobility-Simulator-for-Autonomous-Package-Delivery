function animate_multi_uav(scenario, uavPlatforms, allWaypoints, drones, speed)
% ANIMATE_MULTI_UAV Animates multiple drones flying simultaneously.
%
% Inputs:
%   scenario      - uavScenario object
%   uavPlatforms  - Array of uavPlatform objects
%   allWaypoints  - Cell array of N-by-3 waypoint matrices
%   drones        - Struct array with .start, .goal, .color
%   speed         - Flight speed in m/s (default: 3)

    if nargin < 5 || isempty(speed), speed = 3; end
    numDrones = length(uavPlatforms);

    % 1. Compute timing for each drone
    timeOfArrival = cell(numDrones, 1);
    maxFlightTime = 0;

    for i = 1:numDrones
        wps = allWaypoints{i};
        if isempty(wps), timeOfArrival{i} = []; continue; end
        segDists = sqrt(sum(diff(wps,1,1).^2, 2));
        toa = [0; cumsum(segDists)] / speed;
        for j = 2:length(toa)
            if toa(j) <= toa(j-1), toa(j) = toa(j-1) + 0.01; end
        end
        timeOfArrival{i} = toa;
        maxFlightTime = max(maxFlightTime, toa(end));
    end

    % 2. Initialize the scenario
    setup(scenario);

    % 3. Visualization
    ax = show3D(scenario);
    hold(ax, 'on'); grid(ax, 'on'); axis(ax, 'equal');
    view(ax, 45, 30);
    title(ax, 'Multi-UAV Path Planning — Phase 2: Multiple Drones');
    xlabel(ax, 'X (m)'); ylabel(ax, 'Y (m)'); zlabel(ax, 'Z (m)');

    % 4. Plot each drone's path
    legendHandles = [];
    for i = 1:numDrones
        wps = allWaypoints{i};
        if isempty(wps), continue; end
        c = drones(i).color;
        h = plot3(ax, wps(:,1), wps(:,2), wps(:,3), '-o', 'Color', c, ...
              'LineWidth', 2, 'MarkerSize', 3, 'DisplayName', sprintf('Drone %d Path', i));
        legendHandles = [legendHandles, h]; %#ok<AGROW>
        plot3(ax, wps(1,1), wps(1,2), wps(1,3), 's', 'Color', c, ...
              'MarkerSize', 12, 'MarkerFaceColor', c, 'HandleVisibility', 'off');
        plot3(ax, wps(end,1), wps(end,2), wps(end,3), 'p', 'Color', c, ...
              'MarkerSize', 14, 'MarkerFaceColor', c, 'HandleVisibility', 'off');
    end
    legend(ax, legendHandles, 'Location', 'northwest');

    % 5. Place drones at start
    % Format: [pos(3), vel(3), accel(3), quaternion(4), omega(3)]
    for i = 1:numDrones
        wps = allWaypoints{i};
        if isempty(wps), continue; end
        move(uavPlatforms(i), [wps(1,:), 0 0 0, 0 0 0, 1 0 0 0, 0 0 0]);
    end

    % 6. Simulation loop
    dt = 1 / scenario.UpdateRate;
    t = 0;
    fprintf('Starting multi-drone animation (%.1f s at %.1f m/s)...\n', maxFlightTime, speed);

    while advance(scenario)
        t = t + dt;
        if t > maxFlightTime + 2.0
            break;
        end
        for i = 1:numDrones
            wps = allWaypoints{i}; toa = timeOfArrival{i};
            if isempty(wps), continue; end
            tc = min(t, toa(end));
            pos = interp1(toa, wps, tc, 'linear');

            if tc < toa(end)
                nxt = interp1(toa, wps, min(tc+dt, toa(end)), 'linear');
                d = nxt - pos; dn = norm(d);
                if dn > 0, vel = (d/dn)*speed; yaw = atan2(d(2),d(1));
                else, vel = [0 0 0]; yaw = 0; end
            else, vel = [0 0 0]; yaw = 0; end

            qw = cos(yaw/2); qz = sin(yaw/2);
            % Build 16-element motion vector:
            % [pos(3) | vel(3) | accel(3) | quaternion(4) | angularVel(3)]
            move(uavPlatforms(i), [pos, vel, 0 0 0, qw 0 0 qz, 0 0 0]);
        end
        show3D(scenario, 'Parent', ax, 'FastUpdate', true);
        drawnow limitrate;
    end

    fprintf('Multi-drone animation complete.\n');
    hold(ax, 'off');
end
