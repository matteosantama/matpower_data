function export_cases(matpower_dir, output_dir)
% Export complete MATPOWER structs and label DC OPF feasibility.
source_dir = fullfile(matpower_dir, 'data');
addpath(matpower_dir);
install_matpower(1, 0, 0);
mpopt = mpoption('opf.dc.solver', 'OT', 'out.all', 0, 'verbose', 0);
labels = struct();
if ~isfolder(output_dir)
    mkdir(output_dir);
end
files = dir(fullfile(source_dir, 'case*.m'));
for k = 1:numel(files)
    [~, name] = fileparts(files(k).name);
    mpc = loadcase(fullfile(source_dir, files(k).name));
    save(fullfile(output_dir, [name '.mat']), 'mpc', '-v7');
    % Costs are irrelevant to feasibility; preserve them in the saved case.
    mpc.gencost = repmat([2 0 0 3 1 0 0], size(mpc.gen, 1), 1);
    results = rundcopf(mpc, mpopt);
    if ~is_feasible(results) && results.raw.info ~= -2
        mpc.gencost = repmat([2 0 0 2 0 0], size(mpc.gen, 1), 1);
        results = rundcopf(mpc, mpopt);
    end
    if is_feasible(results)
        labels.(name) = 'feasible';
    elseif results.raw.info == -2
        labels.(name) = 'infeasible';
    else
        error('Unresolved feasibility for %s (exit flag %d)', name, results.raw.info);
    end
    fprintf('%s: %s\n', name, labels.(name));
end
fid = fopen(fullfile(output_dir, '..', 'feasibility.json'), 'w');
fprintf(fid, '%s\n', jsonencode(labels, 'PrettyPrint', true));
fclose(fid);
fprintf('Exported %d cases to %s\n', numel(files), output_dir);
end

function feasible = is_feasible(results)
feasible = false;
if results.success
    [A, l, u] = results.om.params_lin_constraint();
    [~, xmin, xmax] = results.om.params_var();
    x = results.x;
    feasible = max([l - A*x; A*x - u; xmin - x; x - xmax]) <= 1e-7;
end
end
