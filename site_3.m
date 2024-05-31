% Load and preprocess the data
data1 = readtable('Site 3.csv'); % Replace 'Site 3.csv' with your actual file name

% Remove rows with missing values, excluding the first column
data = data1(all(~ismissing(data1{:, 2:end}), 2), :);

% Define the adjusted operating ranges for different types of solar panels
ranges.monocrystalline = struct('temp', [-20, 40], ...
                                'GHI', [0, 1200], 'humidity', [80, 100], ...
                                'pressure', [800, 1050], 'wind_speed', [1, 5]);

ranges.polycrystalline = struct('temp', [-20, 85], ...
                                'GHI', [0, 1200], 'humidity', [80, 100], ...
                                'pressure', [800, 1050], 'wind_speed', [1, 5]);

ranges.thinfilm = struct('temp', [-20, 85], ...
                         'GHI', [0, 1200], 'humidity', [80, 100], ...
                         'pressure', [800, 1050], 'wind_speed', [1, 5]);

% Function to filter data based on operating ranges
function filtered_data = filter_data(data, range)
    filtered_data = data(data.temp >= range.temp(1) & data.temp <= range.temp(2) & ...
                         data.GHI >= range.GHI(1) & data.GHI <= range.GHI(2) & ...
                         data.humidity >= range.humidity(1) & data.humidity <= range.humidity(2) & ...
                         data.wind_speed >= range.wind_speed(1) & data.wind_speed <= range.wind_speed(2), :);
end

% Filter data for each type of solar panel
filtered_data_monocrystalline = filter_data(data, ranges.monocrystalline);
filtered_data_polycrystalline = filter_data(data, ranges.polycrystalline);
filtered_data_thinfilm = filter_data(data, ranges.thinfilm);

% Debug: Check if filtered data is empty
if isempty(filtered_data_monocrystalline)
    disp('Filtered data for Monocrystalline is empty.');
end
if isempty(filtered_data_polycrystalline)
    disp('Filtered data for Polycrystalline is empty.');
end
if isempty(filtered_data_thinfilm)
    disp('Filtered data for Thinfilm is empty.');
end

% Ensure the 'Month' column is present and correctly formatted
if isnumeric(data.month)
    data.month = data.month;
else
    error('The "Month" column is not numeric.');
end

% Separate the filtered data into 12 tables for each month
monthly_data_monocrystalline = cell(12, 1);
monthly_data_polycrystalline = cell(12, 1);
monthly_data_thinfilm = cell(12, 1);
monthly_data_unfiltered = cell(12, 1);

for i = 1:12
    monthly_data_monocrystalline{i} = filtered_data_monocrystalline(filtered_data_monocrystalline.month == i, :);
    monthly_data_polycrystalline{i} = filtered_data_polycrystalline(filtered_data_polycrystalline.month == i, :);
    monthly_data_thinfilm{i} = filtered_data_thinfilm(filtered_data_thinfilm.month == i, :);
    monthly_data_unfiltered{i} = data(data.month == i, :);
end

% Debug: Check if monthly data is empty
for i = 1:12
    if isempty(monthly_data_monocrystalline{i})
        fprintf('Monthly data for Monocrystalline is empty for month %d.\n', i);
    end
    if isempty(monthly_data_polycrystalline{i})
        fprintf('Monthly data for Polycrystalline is empty for month %d.\n', i);
    end
    if isempty(monthly_data_thinfilm{i})
        fprintf('Monthly data for Thinfilm is empty for month %d.\n', i);
    end
    if isempty(monthly_data_unfiltered{i})
        fprintf('Unfiltered monthly data is empty for month %d.\n', i);
    end
end

% Calculate the percentage of times each solar panel can work in each month
percentage_monocrystalline = zeros(12, 1);
percentage_polycrystalline = zeros(12, 1);
percentage_thinfilm = zeros(12, 1);

for i = 1:12
    total_rows_unfiltered = height(monthly_data_unfiltered{i});
    if total_rows_unfiltered > 0
        percentage_monocrystalline(i) = (height(monthly_data_monocrystalline{i}) / total_rows_unfiltered) * 100;
        percentage_polycrystalline(i) = (height(monthly_data_polycrystalline{i}) / total_rows_unfiltered) * 100;
        percentage_thinfilm(i) = (height(monthly_data_thinfilm{i}) / total_rows_unfiltered) * 100;
    end
end

% Array containing the total number of seconds in each month (assuming non-leap year)
seconds_in_month = [31*24*3600, 28*24*3600, 31*24*3600, 30*24*3600, 31*24*3600, 30*24*3600, ...
                    31*24*3600, 31*24*3600, 30*24*3600, 31*24*3600, 30*24*3600, 31*24*3600];

% Calculate the total active seconds for each solar panel type in each month
active_seconds_monocrystalline = (percentage_monocrystalline / 100) .* seconds_in_month';
active_seconds_polycrystalline = (percentage_polycrystalline / 100) .* seconds_in_month';
active_seconds_thinfilm = (percentage_thinfilm / 100) .* seconds_in_month';

% Site area and solar panel area definitions
area_monopoly = 1.6;
area_thin = 2;

% Efficiency and temperature coefficients
efficiency.monocrystalline = 0.18;
efficiency.polycrystalline = 0.145;
efficiency.thinfilm = 0.11;

temp_coeff.monocrystalline = 0.004;
temp_coeff.polycrystalline = 0.0045;
temp_coeff.thinfilm = 0.0025;

% Calculate mean values for each column in the filtered monthly data
mean_values_monocrystalline = zeros(12, width(filtered_data_monocrystalline)-1);
mean_values_polycrystalline = zeros(12, width(filtered_data_polycrystalline)-1);
mean_values_thinfilm = zeros(12, width(filtered_data_thinfilm)-1);

for i = 1:12
    if ~isempty(monthly_data_monocrystalline{i})
        mean_values_monocrystalline(i, :) = mean(monthly_data_monocrystalline{i}{:, 2:end}, 1);
    end
    if ~isempty(monthly_data_polycrystalline{i})
        mean_values_polycrystalline(i, :) = mean(monthly_data_polycrystalline{i}{:, 2:end}, 1);
    end
    if ~isempty(monthly_data_thinfilm{i})
        mean_values_thinfilm(i, :) = mean(monthly_data_thinfilm{i}{:, 2:end}, 1);
    end
end

% Extract relevant mean values for calculations
col_names = filtered_data_monocrystalline.Properties.VariableNames;
temp_idx = strcmp(col_names, 'temp');
ghi_idx = strcmp(col_names, 'GHI');

mean_temp_mono = mean_values_monocrystalline(:, temp_idx);
mean_temp_poly = mean_values_polycrystalline(:, temp_idx);
mean_temp_thin = mean_values_thinfilm(:, temp_idx);

mean_ghi_mono = mean_values_monocrystalline(:, ghi_idx);
mean_ghi_poly = mean_values_polycrystalline(:, ghi_idx);
mean_ghi_thin = mean_values_thinfilm(:, ghi_idx);

% Debug: Display mean temperatures and GHI values
disp('Mean temperatures for Monocrystalline:');
disp(mean_temp_mono);
disp('Mean GHI for Monocrystalline:');
disp(mean_ghi_mono);

disp('Mean temperatures for Polycrystalline:');
disp(mean_temp_poly);
disp('Mean GHI for Polycrystalline:');
disp(mean_ghi_poly);

disp('Mean temperatures for Thinfilm:');
disp(mean_temp_thin);
disp('Mean GHI for Thinfilm:');
disp(mean_ghi_thin);

% Calculate energy production per second for each type of solar panel
power_mono = area_monopoly * efficiency.monocrystalline * ...
    (1 + temp_coeff.monocrystalline * (mean_temp_mono - 25)) .* mean_ghi_mono;

power_poly = area_monopoly * efficiency.polycrystalline * ...
    (1 + temp_coeff.polycrystalline * (mean_temp_poly - 25)) .* mean_ghi_poly;

power_thin = area_thin * efficiency.thinfilm * ...
    (1 + temp_coeff.thinfilm * (mean_temp_thin - 25)) .* mean_ghi_thin;

% Debug: Display power values
disp('Power for Monocrystalline:');
disp(power_mono);
disp('Power for Polycrystalline:');
disp(power_poly);
disp('Power for Thinfilm:');
disp(power_thin);

% Multiply power by active seconds to get total energy production for each month
total_energy_mono = power_mono .* active_seconds_monocrystalline;
total_energy_poly = power_poly .* active_seconds_polycrystalline;
total_energy_thin = power_thin .* active_seconds_thinfilm;

% Debug: Check if total energy is empty
if isempty(total_energy_mono)
    disp('Total energy for Monocrystalline is empty.');
else
    disp('Total energy for Monocrystalline:');
    disp(total_energy_mono);
end

if isempty(total_energy_poly)
    disp('Total energy for Polycrystalline is empty.');
else
    disp('Total energy for Polycrystalline:');
    disp(total_energy_poly);
end

if isempty(total_energy_thin)
    disp('Total energy for Thinfilm is empty.');
else
    disp('Total energy for Thinfilm:');
    disp(total_energy_thin);
end

% Calculate total yearly energy production
total_yearly_energy_mono = sum(total_energy_mono) / 3600; % in kWh
total_yearly_energy_poly = sum(total_energy_poly) / 3600; % in kWh
total_yearly_energy_thin = sum(total_energy_thin) / 3600; % in kWh

% Define costs per unit energy for each type of solar panel
cost_per_unit_energy_mono = 0.05; % Example cost in dollars per kWh
cost_per_unit_energy_poly = 0.04; % Example cost in dollars per kWh
cost_per_unit_energy_thin = 0.03; % Example cost in dollars per kWh

% Calculate total cost for the year
cost_energy_mono = total_yearly_energy_mono * cost_per_unit_energy_mono;
cost_energy_poly = total_yearly_energy_poly * cost_per_unit_energy_poly;
cost_energy_thin = total_yearly_energy_thin * cost_per_unit_energy_thin;

% Output results
fprintf('Total yearly energy production for Monocrystalline: %.2f kWh\n', total_yearly_energy_mono);
fprintf('Total yearly energy production for Polycrystalline: %.2f kWh\n', total_yearly_energy_poly);
fprintf('Total yearly energy production for Thinfilm: %.2f kWh\n', total_yearly_energy_thin);

fprintf('Total yearly cost for Monocrystalline: $%.2f\n', cost_energy_mono);
fprintf('Total yearly cost for Polycrystalline: $%.2f\n', cost_energy_poly);
fprintf('Total yearly cost for Thinfilm: $%.2f\n', cost_energy_thin);

% Plot monthly energy production for different solar panel types
figure;
plot(1:12, total_energy_mono, '-o', 'DisplayName', 'Monocrystalline');
hold on;
plot(1:12, total_energy_poly, '-x', 'DisplayName', 'Polycrystalline');
plot(1:12, total_energy_thin, '-s', 'DisplayName', 'Thin Film');
hold off;
xlabel('Month');
ylabel('Total Energy Production (Wh)');
title('Total Energy Production Over 12 Months');
legend;
grid on;

% Compare total yearly energy production using bar graph
figure;
bar([total_yearly_energy_mono, total_yearly_energy_poly, total_yearly_energy_thin]);
set(gca, 'XTickLabel', {'Monocrystalline', 'Polycrystalline', 'Thin Film'});
xlabel('Solar Panel Type');
ylabel('Total Yearly Energy Production (kWh)');
title('Total Yearly Energy Production Comparison');
grid on;

% Compare total yearly cost using bar graph
figure;
bar([cost_energy_mono, cost_energy_poly, cost_energy_thin]);
set(gca, 'XTickLabel', {'Monocrystalline', 'Polycrystalline', 'Thin Film'});
xlabel('Solar Panel Type');
ylabel('Total Yearly Cost ($)');
title('Total Yearly Cost Comparison');
grid on;
