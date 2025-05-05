function totalQL = mTotalQL_3SfDL(lambda, mu, delay, Chi,...
    TimeHorizon, SampleSize)

numCustomers = round(TimeHorizon*lambda*1.1);

cumQL1 = zeros(length(Chi), 1);
cumQL2 = zeros(length(Chi), 1);
cumQL3 = zeros(length(Chi), 1);

rng(0);
for jj = 1:SampleSize
    jj
    % Generate Arrival Times
    InterArrTimes = exprnd(1.0/lambda, numCustomers, 1);
    ArrTimes = cumsum(InterArrTimes);
    ServiceTimes = exprnd(1.0/mu, numCustomers, 1);
    RandomRoutes = rand(numCustomers, 1);
    parfor ii = 1:length(Chi)
        [mQL1, mQL2, mQL3] = RJSQ_mQL_3SfDL_mex(delay, Chi(ii), TimeHorizon, ArrTimes, ServiceTimes, RandomRoutes);
        cumQL1(ii) = cumQL1(ii) + mQL1;
        cumQL2(ii) = cumQL2(ii) + mQL2;
        cumQL3(ii) = cumQL3(ii) + mQL3;
    end
end
totalQL = (cumQL1 + cumQL2 + cumQL3)/SampleSize;
end
