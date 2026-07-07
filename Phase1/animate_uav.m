function animate_uav(scenario, uav, waypoints, speed)
% ANIMATE_UAV Visualizes the 3D city scenario, plots the planned path,
% and animates the UAV flying along the trajectory using manual position
% updates via the move() function.
%
% Inputs:
%   scenario  - The uavScenario object
%   uav       - The uavPlatform object representing the drone
%   waypoints - N-by-3 matrix of path coordinates [x, y, z]
%   speed     - Constant flight speed of the UAV in m/s (default: 3)

    if nargin < 4 || isempty(speed)
        speed = 3;
    end

    if isempty(waypoints)
        error('No waypoints provided for animation.');
    end

    % 1. Compute cumulative distance and time of arrival at each waypoint
    segmentDists = sqrt(sum(diff(waypoints, 1, 1).^2, 2));
    cumDists = [0; cumsum(segmentDists)];
    timeOfArrival = cumDists / speed;

    % Ensure timestamps are strictly increasing (handles co-located waypoints)
    for i = 2:length(timeOfArrival)
        if timeOfArrival(i) <= timeOfArrival(i-1)
            timeOfArrival(i) = timeOfArrival(i-1) + 0.01;
        end
    end

    totalFlightTime = timeOfArrival(end);

    % 2. Initialize the scenario (locks configuration)
    setup(scenario);

    % 3. Set up the 3D visualization
    ax = show3D(scenario);
    hold(ax, 'on');
    grid(ax, 'on');
    axis(ax, 'equal');
    view(ax, 45, 30);
    title(ax, 'Multi-UAV Path Planning — Phase 1: Single Drone');
    xlabel(ax, 'X (m)');
    ylabel(ax, 'Y (m)');
    zlabel(ax, 'Z (m)');

    % 4. Plot the planned path, start marker, and goal marker
    hPath = plot3(ax, waypoints(:,1), waypoints(:,2), waypoints(:,3), ...
                  'g-o', 'LineWidth', 2, 'MarkerSize', 4, 'DisplayName', 'Planned Path');
    hStart = plot3(ax, waypoints(1,1), waypoints(1,2), waypoints(1,3), ...
                  'gs', 'MarkerSize', 14, 'MarkerFaceColor', [0 0.8 0], ...
                  'DisplayName', 'Start');
    hGoal = plot3(ax, waypoints(end,1), waypoints(end,2), waypoints(end,3), ...
                  'rp', 'MarkerSize', 16, 'MarkerFaceColor', [0.9 0.1 0.1], ...
                  'DisplayName', 'Goal');
    
    % Explicitly pass only these three handles to the legend to hide building meshes
    legend(ax, [hPath, hStart, hGoal], 'Location', 'northwest');

    % 5. Place the UAV at the starting position before entering the loop
    % Format: [pos(3), vel(3), accel(3), quaternion(4), omega(3)]
    startMotion = [waypoints(1,:), 0 0 0, 0 0 0, 1 0 0 0, 0 0 0];
    move(uav, startMotion);

    % 6. Run the simulation loop — drive the UAV along the interpolated path
    dt = 1 / scenario.UpdateRate;
    t = 0;

    fprintf('Starting UAV flight animation (%.1f s at %.1f m/s)...\n', ...
            totalFlightTime, speed);

    while advance(scenario)
        t = t + dt;
        if t > totalFlightTime + 1.0
            break;
        end
        tClamped = min(t, totalFlightTime);

        % Interpolate the UAV position along the waypoint path
        pos = interp1(timeOfArrival, waypoints, tClamped, 'linear');

        % Compute velocity and yaw so the drone faces its direction of travel
        if tClamped < totalFlightTime
            lookAhead = min(tClamped + dt, totalFlightTime);
            nextPos = interp1(timeOfArrival, waypoints, lookAhead, 'linear');
            dir = nextPos - pos;
            dirNorm = norm(dir);
            if dirNorm > 0
                vel = (dir / dirNorm) * speed;
                yaw = atan2(dir(2), dir(1));
            else
                vel = [0 0 0];
                yaw = 0;
            end
        else
            vel = [0 0 0];
            yaw = 0;
        end

        % Convert yaw to quaternion (rotation about the Z-up axis)
        qw = cos(yaw / 2);
        qz = sin(yaw / 2);

        % Build 16-element motion vector:
        % [pos(3) | vel(3) | accel(3) | quaternion(4) | angularVel(3)]
        motion = [pos(1), pos(2), pos(3), ...
                  vel(1), vel(2), vel(3), ...
                  0, 0, 0, ...
                  qw, 0, 0, qz, ...
                  0, 0, 0];

        move(uav, motion);
        show3D(scenario, 'Parent', ax, 'FastUpdate', true);
        drawnow limitrate;
    end

    fprintf('Animation complete.\n');
    hold(ax, 'off');

end
