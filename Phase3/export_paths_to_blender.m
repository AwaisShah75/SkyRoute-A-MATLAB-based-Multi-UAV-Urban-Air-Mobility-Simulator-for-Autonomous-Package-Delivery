% export_paths_to_blender.m
% Run this script AFTER main_phase3 has completed.
% It exports the 3D coordinates [X, Y, Z] of all three drones to CSV files
% that can be easily imported into Blender for high-quality rendering.

if ~exist('allWaypoints', 'var')
    error('No planned paths found in workspace. Run main_phase3 first.');
end

fprintf('Exporting drone trajectories for Blender...\n');

numDrones = length(allWaypoints);

for i = 1:numDrones
    wps = allWaypoints{i};
    if isempty(wps)
        fprintf('  Drone %d path is empty. Skipping.\n', i);
        continue;
    end
    
    % Define filename
    filename = sprintf('drone%d_path.csv', i);
    
    % Write coordinates [X, Y, Z] to CSV (no header, just raw values)
    writematrix(wps, filename);
    fprintf('  ✓ Saved Drone %d path to: %s (%d coordinates)\n', ...
            i, filename, size(wps, 1));
end

fprintf('All paths exported successfully! Ready for Blender import.\n');
