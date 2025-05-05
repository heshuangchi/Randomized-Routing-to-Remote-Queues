function totalQL = mTotalQL_2SfDL(lambda, mu, delay, Prob_JSQ,...
    TimeHorizon, SampleSize)

numCustomers = round(TimeHorizon*lambda*1.1);

cumQL1 = zeros(length(Prob_JSQ), 1);
cumQL2 = zeros(length(Prob_JSQ), 1);

rng(0);
for jj = 1:SampleSize
    jj
    % Generate Arrival Times
    InterArrTimes = exprnd(1.0/lambda, numCustomers, 1);
    ArrTimes = cumsum(InterArrTimes);
    ServiceTimes = exprnd(1.0/mu, numCustomers, 1);
    RandomRoutes = rand(numCustomers, 1);
    parfor ii = 1:length(Prob_JSQ)
        [mQL1, mQL2] = RJSQ_mQL_2SfDL_mex(delay, Prob_JSQ(ii), TimeHorizon, ArrTimes, ServiceTimes, RandomRoutes);
        cumQL1(ii) = cumQL1(ii) + mQL1;
        cumQL2(ii) = cumQL2(ii) + mQL2;
    end
end
totalQL = (cumQL1 + cumQL2)/SampleSize;
end
