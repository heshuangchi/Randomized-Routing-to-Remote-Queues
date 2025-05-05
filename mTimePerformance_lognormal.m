function [meanTravelingTime, meanWaitingTime, meanAddJSQ] = mTimePerformance_lognormal(lambda, mu, TimeHorizon, SampleSize, deltaTime)

numCustomers = round(TimeHorizon*lambda*1.1);
cumTravelingTime = 0;
cumWaitingTime = 0;
cumAddJSQ = 0;

m = 1.0; v = 3.0;
mu_logn = log((m^2)/sqrt(v+m^2));
sigma_logn = sqrt(log(v/(m^2)+1));

rng(0);

parfor jj = 1:SampleSize
    jj
    
    InterArrTimes = exprnd(1.0/lambda, numCustomers, 1);
    ArrTimes = cumsum(InterArrTimes);
    ServiceRequirements = lognrnd(mu_logn, sigma_logn, numCustomers, 1);
    LocationX = rand(numCustomers, 1)*200;
    LocationY = rand(numCustomers, 1)*200;

    [sampleMTT, sampleMWT, sampleAddJSQ] = GeoSepQueues_3S(lambda, mu, TimeHorizon, ArrTimes,...
        ServiceRequirements, LocationX, LocationY, deltaTime);
    cumTravelingTime = cumTravelingTime + sampleMTT;
    cumWaitingTime = cumWaitingTime + sampleMWT;
    cumAddJSQ = cumAddJSQ + sampleAddJSQ;
end
meanTravelingTime = cumTravelingTime/SampleSize;
meanWaitingTime = cumWaitingTime/SampleSize;
meanAddJSQ = cumAddJSQ/SampleSize;
end