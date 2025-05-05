function mTotalQLPath = mQLPath_rDL(lambda, mu, delay, p_JSQ, TimeHorizon, SampleSize, dt)

tic;
fprintf('Probability of JSQ is %.3f\n', p_JSQ);

TotalArrNum = round(1.2*TimeHorizon*lambda);

rng(0);

InterArrTime = exprnd(1.0/lambda, TotalArrNum, 1);
ArrTime = cumsum(InterArrTime);
ServiceTime = exprnd(1.0/mu, TotalArrNum, 1);

[cumQLPath1, cumQLPath2] = RJSQ_path_2SrDL(delay, p_JSQ,...
    TimeHorizon, ArrTime, ServiceTime, dt);
parfor jj = 2:SampleSize
    InterArrTime = exprnd(1.0/lambda, TotalArrNum, 1);
    ArrTime = cumsum(InterArrTime);
    ServiceTime = exprnd(1.0/mu, TotalArrNum, 1);

    [QLPath1, QLPath2] = RJSQ_path_2SrDL(delay, p_JSQ,...
        TimeHorizon, ArrTime, ServiceTime, dt);
    cumQLPath1 = cumQLPath1 + QLPath1;
    cumQLPath2 = cumQLPath2 + QLPath2;
end
mTotalQLPath = (cumQLPath1 + cumQLPath2)/SampleSize;
toc
end