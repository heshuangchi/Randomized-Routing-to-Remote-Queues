%% Geographically Separated Queues with Three Stations 
% The map is 200 X 200. Three stations are at (50, 50), (50, 150), 
% and (150, 50), with service capacity 1, 1.5, and 1.5, respectively.

clear;

TimeHorizon = 2e5; % time horizon
SampleSize = 5e3; % total number of replications
deltaTime = 16.0;

rho = 0.99; % traffic intensity
mu = [1.0; 1.5; 1.5]; % service rate
lambda = sum(mu)*rho;

fprintf('Program starts at %s\n', datetime);
CompTimeStart = tic;

% Get mean traveling time and mean waiting time
[mTT, mWT, mAddJSQ] = mTimePerformance_lognormal(lambda, mu, TimeHorizon, SampleSize, deltaTime);

CompTime = toc(CompTimeStart);
fprintf('Program takes %.2f seconds\n', CompTime);

save(sprintf('GeoSepQueues_3S_logn_v3_SampleSize%d_TimeHorizon%.1e_rho%.2f_delta%d.mat',...
    SampleSize, TimeHorizon, rho, deltaTime));

beep