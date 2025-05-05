function [meanTravelingTime, meanWaitingTime, meanAddJSQ] = mTimePerformance(lambda, mu, TimeHorizon, SampleSize, deltaTime)

numCustomers = round(TimeHorizon*lambda*1.1);
cumTravelingTime = 0;
cumWaitingTime = 0;
cumAddJSQ = 0;

rng(0);

parfor jj = 1:SampleSize
    jj
    
    InterArrTimes = exprnd(1.0/lambda, numCustomers, 1);
    ArrTimes = cumsum(InterArrTimes);
    ServiceRequirements = exprnd(1.0, numCustomers, 1);
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