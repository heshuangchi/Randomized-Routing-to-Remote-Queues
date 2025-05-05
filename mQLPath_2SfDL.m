function mTotalQLPath = mQLPath_2SfDL(lambda, mu, delay, p_JSQ, TimeHorizon,...
    SampleSize, dt)

fprintf('Probability of JSQ is %.3f\n', p_JSQ);

numCustomers = round(TimeHorizon*lambda*1.1);
cumQLPath1 = zeros(TimeHorizon/dt, 1);
cumQLPath2 = cumQLPath1;

tic; rng(0);

parfor jj = 1:SampleSize
    InterArrTimes = exprnd(1.0/lambda, numCustomers, 1);
    ArrTimes = cumsum(InterArrTimes);
    ServiceTimes = exprnd(1.0/mu, numCustomers, 1);
    RandomRoutes = rand(numCustomers, 1);
    [QLPath1, QLPath2] = RJSQ_path_2SfDL_mex(delay, p_JSQ,...
        TimeHorizon, dt, ArrTimes, ServiceTimes, RandomRoutes);
    cumQLPath1 = cumQLPath1 + QLPath1;
    cumQLPath2 = cumQLPath2 + QLPath2;
end
mTotalQLPath = (cumQLPath1 + cumQLPath2)/SampleSize;
toc
end