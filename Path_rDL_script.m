clear;

TimeHorizon = 3.1e4; % time horizon
SampleSize = 2000; % total number of replications
dt = 10;

rho = 0.99; % traffic intensity
mu = 1.0; % service rate
lambda = 2*mu*rho; % two stations
delay = 100.0;
Prob_JSQ = 1.0;

fprintf('Program starts at %s\n', datetime);
CompTimeStart = tic;
mTotalQLPath = mQLPath_rDL(lambda, mu, delay, Prob_JSQ, TimeHorizon, SampleSize, dt);
fprintf('Program takes %.2f seconds\n', toc(CompTimeStart));

% save(sprintf('SampleSize%d_TimeHorizon%.1e_rho%.2f_delay%d_ProbJSQ%.2f_Path_SyncSamples.mat', SampleSize, TimeHorizon, rho, delay, Prob_JSQ));

%% Figure for Mean
fig1 = figure;
box on;
line(dt:dt:TimeHorizon, mTotalQLPath, 'LineWidth', 1, 'Color', [0, 0, 1], 'LineStyle', '-');
ylim([0, 300]);
xlim([0, 3e4]);
set(gca, 'FontSize', 11, 'XTick', 0:1e4:3e4, 'YTick', 0:100:300);
ylabel('Number of customers', 'FontSize', 14);
xlabel('Time', 'FontSize', 14);
% saveas(fig1, 'diffBF.pdf');