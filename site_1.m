0% Load and preprocess the data
data1 = readtable('Site_1.csv'); % Replace 'Site_1.csv' with your actual file name
data0 = removevars(data1, 'Unnamed_18'); % Remove unnecessary column
data = data0(all(~ismissing(data0{:,:}), 2), :); % Remove rows with missing values

% Define the operating ranges for different types of solar panels
ranges.monocrystalline = struct('Temperature', [-20, 40], 'ClearskyDHI', [0, 300], 'ClearskyDNI', [0, 1000], ...
                                'ClearskyGHI', [0, 1200], 'DewPoint', [-30, 30], 'DHI', [0, 300], ...
                                'DNI', [0, 1000], 'GHI', [0, 1200], 'RelativeHumidity', [20, 60], ...
                                'SolarZenithAngle', [0, 90], 'SurfaceAlbedo', [0.1, 0.9], 'Pressure', [800, 1050], ...
                                'WindSpeed', [1, 5]);

ranges.polycrystalline = struct('Temperature', [-20, 85], 'ClearskyDHI', [0, 300], 'ClearskyDNI', [0, 1000], ...
                                'ClearskyGHI', [0, 1200], 'DewPoint', [-30, 30], 'DHI', [0, 300], ...
                                'DNI', [0, 1000], 'GHI', [0, 1200], 'RelativeHumidity', [20, 60], ...
                                'SolarZenithAngle', [0, 90], 'SurfaceAlbedo', [0.1, 0.9], 'Pressure', [800, 1050], ...
                                'WindSpeed', [1, 5]);

ranges.thinfilm = struct('Temperature', [-20, 85], 'ClearskyDHI', [0, 300], 'ClearskyDNI', [0, 1000], ...
                         'ClearskyGHI', [0, 1200], 'DewPoint', [-30, 30], 'DHI', [0, 300], ...
                         'DNI', [0, 1000], 'GHI', [0, 1200], 'RelativeHumidity', [20, 70], ...
                         'SolarZenithAngle', [0, 90], 'SurfaceAlbedo', [0.1, 0.9], 'Pressure', [800, 1050], ...
                         'WindSpeed', [1, 5]);

% Function to filter data based on operating ranges
function filtered_data = filter_data(data, range)
    filtered_data = data(data.Temperature >= range.Temperature(1) & data.Temperature <= range.Temperature(2) & ...
                         data.ClearskyDHI >= range.ClearskyDHI(1) & data.ClearskyDHI <= range.ClearskyDHI(2) & ...
                         data.ClearskyDNI >= range.ClearskyDNI(1) & data.ClearskyDNI <= range.ClearskyDNI(2) & ...
                         data.ClearskyGHI >= range.ClearskyGHI(1) & data.ClearskyGHI <= range.ClearskyGHI(2) & ...
                         data.DewPoint >= range.DewPoint(1) & data.DewPoint <= range.DewPoint(2) & ...
                         data.DHI >= range.DHI(1) & data.DHI <= range.DHI(2) & ...
                         data.DNI >= range.DNI(1) & data.DNI <= range.DNI(2) & ...
                         data.GHI >= range.GHI(1) & data.GHI <= range.GHI(2) & ...
                         data.RelativeHumidity >= range.RelativeHumidity(1) & data.RelativeHumidity <= range.RelativeHumidity(2) & ...
                         data.SolarZenithAngle >= range.SolarZenithAngle(1) & data.SolarZenithAngle <= range.SolarZenithAngle(2) & ...
                         data.SurfaceAlbedo >= range.SurfaceAlbedo(1) & data.SurfaceAlbedo <= range.SurfaceAlbedo(2) & ...
                         data.Pressure >= range.Pressure(1) & data.Pressure <= range.Pressure(2) & ...
                         data.WindSpeed >= range.WindSpeed(1) & data.WindSpeed <= range.WindSpeed(2), :);
end

% Filter data for each type of solar panel
filtered_data_monocrystalline = filter_data(data, ranges.monocrystalline);
filtered_data_polycrystalline = filter_data(data, ranges.polycrystalline);
filtered_data_thinfilm = filter_data(data, ranges.thinfilm);

% Separate the filtered data into 12 tables for each month
monthly_data_monocrystalline = cell(12, 1);
monthly_data_polycrystalline = cell(12, 1);
monthly_data_thinfilm = cell(12, 1);
monthly_data_unfiltered = cell(12, 1);

for i = 1:12
    monthly_data_monocrystalline{i} = filtered_data_monocrystalline(filtered_data_monocrystalline.Month == i, :);
    monthly_data_polycrystalline{i} = filtered_data_polycrystalline(filtered_data_polycrystalline.Month == i, :);
    monthly_data_thinfilm{i} = filtered_data_thinfilm(filtered_data_thinfilm.Month == i, :);
    monthly_data_unfiltered{i} = data(data.Month == i, :);
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


% Site 1 area is 16,000,000 m^2, area of 1 monocrystalline and polycrystalline is 1.6 meter squared whilst thin film are is 2 meter squared
area_monopoly = 1.6;
area_thin = 2;
% formula to calculate energy production is: Power=Area×Efficiency×(1+Temperature Coefficient×(Temperature−25))×GHI×(cos(Solar Zenith Angle)+Albedo)

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
mean_temp_mono = mean_values_monocrystalline(:, strcmp(filtered_data_monocrystalline.Properties.VariableNames, 'Temperature'));
mean_temp_poly = mean_values_polycrystalline(:, strcmp(filtered_data_polycrystalline.Properties.VariableNames, 'Temperature'));
mean_temp_thin = mean_values_thinfilm(:, strcmp(filtered_data_thinfilm.Properties.VariableNames, 'Temperature'));

mean_ghi_mono = mean_values_monocrystalline(:, strcmp(filtered_data_monocrystalline.Properties.VariableNames, 'GHI'));
mean_ghi_poly = mean_values_polycrystalline(:, strcmp(filtered_data_polycrystalline.Properties.VariableNames, 'GHI'));
mean_ghi_thin = mean_values_thinfilm(:, strcmp(filtered_data_thinfilm.Properties.VariableNames, 'GHI'));

mean_sza_mono = mean_values_monocrystalline(:, strcmp(filtered_data_monocrystalline.Properties.VariableNames, 'SolarZenithAngle'));
mean_sza_poly = mean_values_polycrystalline(:, strcmp(filtered_data_polycrystalline.Properties.VariableNames, 'SolarZenithAngle'));
mean_sza_thin = mean_values_thinfilm(:, strcmp(filtered_data_thinfilm.Properties.VariableNames, 'SolarZenithAngle'));

mean_albedo_mono = mean_values_monocrystalline(:, strcmp(filtered_data_monocrystalline.Properties.VariableNames, 'SurfaceAlbedo'));
mean_albedo_poly = mean_values_polycrystalline(:, strcmp(filtered_data_polycrystalline.Properties.VariableNames, 'SurfaceAlbedo'));
mean_albedo_thin = mean_values_thinfilm(:, strcmp(filtered_data_thinfilm.Properties.VariableNames, 'SurfaceAlbedo'));

% Calculate energy production per second for each type of solar panel
power_mono = area_monopoly * efficiency.monocrystalline * ...
    (1 + temp_coeff.monocrystalline * (mean_temp_mono - 25)) .* mean_ghi_mono .* ...
    (cosd(mean_sza_mono) + mean_albedo_mono);

power_poly = area_monopoly * efficiency.polycrystalline * ...
    (1 + temp_coeff.polycrystalline * (mean_temp_poly - 25)) .* mean_ghi_poly .* ...
    (cosd(mean_sza_poly) + mean_albedo_poly);

power_thin = area_thin * efficiency.thinfilm * ...
    (1 + temp_coeff.thinfilm * (mean_temp_thin - 25)) .* mean_ghi_thin .* ...
    (cosd(mean_sza_thin) + mean_albedo_thin);

% Calculate total energy production for each month per 1 solar panel
total_energyperpanel_mono = active_seconds_monocrystalline .* power_mono;
total_energyperpanel_poly = active_seconds_polycrystalline .* power_poly;
total_energyperpanel_thin = active_seconds_thinfilm .* power_thin;

%calculating amount of solar panels in site1
 monopoly_amount_site1 = 16000000/area_monopoly;
 thin_amount_site1 = 16000000/area_thin;
 %calculating total energy from site 1 assuming all of it is covered in
 %solar panels
total_monthenergy_mono = monopoly_amount_site1 * total_energyperpanel_mono;
total_monthenergy_poly = monopoly_amount_site1 * total_energyperpanel_mono;
total_monthenergy_thin = thin_amount_site1 * total_energyperpanel_thin;

%Define cost per watt and initial cost per solar panel
cost_per_watt.mono = 0.4;
cost_per_watt.poly = 0.3;
cost_per_watt.thin = 0.5;

initial_cost_per_panel.mono = 225;
initial_cost_per_panel.poly = 175;
initial_cost_per_panel.thin = 140;

% Calculate the initial cost for each type of solar panel
initial_cost_mono = monopoly_amount_site1 * initial_cost_per_panel.mono;
initial_cost_poly = monopoly_amount_site1 * initial_cost_per_panel.poly;
initial_cost_thin = thin_amount_site1 * initial_cost_per_panel.thin;

% Calculate the cost of energy production for each month
cost_energy_mono = total_monthenergy_mono * cost_per_watt.mono;
cost_energy_poly = total_monthenergy_poly * cost_per_watt.poly;
cost_energy_thin = total_monthenergy_thin * cost_per_watt.thin;

% Add the initial cost to the first month's energy cost
total_cost_mono = cost_energy_mono;
total_cost_poly = cost_energy_poly;
total_cost_thin = cost_energy_thin;

total_cost_mono(1) = total_cost_mono(1) + initial_cost_mono;
total_cost_poly(1) = total_cost_poly(1) + initial_cost_poly;
total_cost_thin(1) = total_cost_thin(1) + initial_cost_thin;
% Plot total energy production over 12 months for each solar panel
months = 1:12;

figure;
plot(months, total_monthenergy_mono, '-o', 'DisplayName', 'Monocrystalline');
hold on;
plot(months, total_monthenergy_poly, '-x', 'DisplayName', 'Polycrystalline');
plot(months, total_monthenergy_thin, '-s', 'DisplayName', 'Thin Film');
hold off;
xlabel('Month');
ylabel('Total Energy Production (Wh)');
title('Total Energy Production Over 12 Months');
legend;
grid on;

% Calculate total energy production for the entire year
total_yearly_energy_mono = sum(total_monthenergy_mono);
total_yearly_energy_poly = sum(total_monthenergy_poly);
total_yearly_energy_thin = sum(total_monthenergy_thin);

% Calculate total cost for the first year
total_yearly_cost_mono = sum(total_cost_mono);
total_yearly_cost_poly = sum(total_cost_poly);
total_yearly_cost_thin = sum(total_cost_thin);

% Compare total yearly energy production using bar graph
figure;
bar([total_yearly_energy_mono, total_yearly_energy_poly, total_yearly_energy_thin]);
set(gca, 'XTickLabel', {'Monocrystalline', 'Polycrystalline', 'Thin Film'});
xlabel('Solar Panel Type');
ylabel('Total Yearly Energy Production (Wh)');
title('Total Yearly Energy Production Comparison');
grid on;

% Compare total yearly cost using bar graph
figure;
bar([total_yearly_cost_mono, total_yearly_cost_poly, total_yearly_cost_thin]);
set(gca, 'XTickLabel', {'Monocrystalline', 'polycrystalline', 'Thin Film'});
xlabel('Solar Panel Type');
ylabel('Total Yearly Cost ($)');
title('Total Yearly Cost Comparison');
grid on;

% Display yearly totals for reference
disp('Total Yearly Energy Production (Wh):');
disp(['Monocrystalline: ', num2str(total_yearly_energy_mono)]);
disp(['Polycrystalline: ', num2str(total_yearly_energy_poly)]);
disp(['Thin Film: ', num2str(total_yearly_energy_thin)]);

disp('Total Yearly Cost ($):');
disp(['Monocrystalline: ', num2str(total_yearly_cost_mono)]);
disp(['Polycrystalline: ', num2str(total_yearly_cost_poly)]);
disp(['Thin Film: ', num2str(total_yearly_cost_thin)]);
