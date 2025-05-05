clear;

TimeHorizon = 2e5; % time horizon
SampleSize = 48; % total number of replications

rho = 0.99; % traffic intensity
mu = 1.0; % service rate
lambda = 2*mu*rho; % two stations
delay = 200.0;
Prob_JSQ = 0.50:0.05:1.0;

fprintf('Program starts at %s\n', datetime);
CompTimeStart = tic;
totalQL = mTotalQL_2SfDL_C(lambda, mu, delay, Prob_JSQ, TimeHorizon, SampleSize);
fprintf('Program takes %.1f seconds\n', toc(CompTimeStart));

% save(sprintf('SampleSize%d_TimeHorizon%.1e_rho%.2f_delay%d_ProbJSQ_SyncSamples.mat', SampleSize, TimeHorizon, rho, delay));

%% Figure for Mean
fig1 = figure;
box on;
line(Prob_JSQ, totalQL, 'LineWidth', 1, 'Color', [0, 0, 1], 'LineStyle', '-');
% ylim([0, 300]);
% xlim([0.5, 1.0]);
% set(gca, 'FontSize', 11, 'XTick', 0.5:0.1:1.0, 'YTick', 0:100:300);
ylabel('Total queue length', 'FontSize', 14);
xlabel('Probability to shorter queue', 'FontSize', 14);
%saveas(fig1, 'diffBF_new.pdf');