clear;

TimeHorizon = 2e5; % time horizon
SampleSize = 2e4; % total number of replications

rho = 0.99; % traffic intensity
mu = 1.0; % service rate
lambda = 3*mu*rho; % three stations
delay = 100.0;
Chi = 0:0.001:0.5;

fprintf('Program starts at %s\n', datetime);
CompTimeStart = tic;
totalQL = mTotalQL_3SfDL(lambda, mu, delay, Chi, TimeHorizon, SampleSize);
fprintf('Program takes %.1f seconds\n', toc(CompTimeStart));

save(sprintf('QLvsChi3S_SampleSize%.1e_TimeHorizon%.1e_rho%.2f_delay%.1f.mat',...
    SampleSize, TimeHorizon, rho, delay));

%% Figure for Mean
fig1 = figure;
box on;
line(Chi, totalQL, 'LineWidth', 1, 'Color', [0, 0, 1], 'LineStyle', '-');
ylabel('Total queue length', 'FontSize', 14);
xlabel('Balancing factor', 'FontSize', 14);