function export_cases(matpower_dir, output_dir)
% Evaluate MATPOWER case functions and export their complete structs.
source_dir = fullfile(matpower_dir, 'data');
addpath(fullfile(matpower_dir, 'lib'));
addpath(source_dir);
if ~isfolder(output_dir)
    mkdir(output_dir);
end
files = dir(fullfile(source_dir, 'case*.m'));
for k = 1:numel(files)
    [~, name] = fileparts(files(k).name);
    mpc = loadcase(fullfile(source_dir, files(k).name));
    save(fullfile(output_dir, [name '.mat']), 'mpc', '-v7');
    fprintf('%s: %d buses, %d generators, gencost=%d\n', ...
        name, size(mpc.bus, 1), size(mpc.gen, 1), isfield(mpc, 'gencost'));
end
fprintf('Exported %d cases to %s\n', numel(files), output_dir);
end
