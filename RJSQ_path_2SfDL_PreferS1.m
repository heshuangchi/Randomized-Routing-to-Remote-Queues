function [SampledQL1, SampledQL2] = RJSQ_path_2SfDL_PreferS1(delay, p_JSQ,...
    TimeHorizon, dt, ArrTimes, ServiceTimes, RandomRoutes)

maxTime = TimeHorizon*10;

% Initialization
t_Arr = ArrTimes(1); 
num_Arr = 0;
t_JoinStation = t_Arr + delay; 
num_JoinStation = 0;
t_SvcCompletion1 = maxTime; 
t_SvcCompletion2 = maxTime;
num_JoinService = 0;
t_Sampling = dt;
num_SampleCount = 0;
QL1 = 0; QL2 = 0;
BS1 = 0; BS2 = 0;
SampledQL1 = zeros(TimeHorizon/dt, 1);
SampledQL2 = zeros(TimeHorizon/dt, 1);

Destin = zeros(length(ArrTimes), 1);

while t_Sampling < TimeHorizon
    if (t_Arr<=t_SvcCompletion1) && (t_Arr<=t_SvcCompletion2)...
            && (t_Arr<=t_JoinStation) && (t_Arr<=t_Sampling)
        num_Arr = num_Arr + 1;
        P1 = (QL1+BS1<=QL2+BS2)*p_JSQ+(QL1+BS1>QL2+BS2)*(1-p_JSQ);
        Destin(num_Arr) = 2 - (RandomRoutes(num_Arr)<P1);
        t_Arr = ArrTimes(num_Arr+1);

    elseif (t_JoinStation<=t_Arr) && (t_JoinStation<=t_SvcCompletion1)...
            && (t_JoinStation<=t_SvcCompletion2)...
            && (t_JoinStation<=t_Sampling)
        num_JoinStation = num_JoinStation + 1;
        if Destin(num_JoinStation) == 1
            if BS1 == 0 % if server 1 is idle
                BS1 = 1;
                num_JoinService = num_JoinService + 1;
                t_SvcCompletion1 = t_JoinStation +...
                    ServiceTimes(num_JoinService); % departure time
            else
                QL1 = QL1 + 1;
            end
        elseif Destin(num_JoinStation) == 2
            if BS2 == 0 % if there is an idle server
                BS2 = 1;
                num_JoinService = num_JoinService + 1;
                t_SvcCompletion2 = t_JoinStation +...
                    ServiceTimes(num_JoinService);
            else
                QL2 = QL2 + 1;
            end
        end
        t_JoinStation = ArrTimes(num_JoinStation+1) + delay;
    elseif (t_SvcCompletion1<=t_Arr)...
            && (t_SvcCompletion1<=t_SvcCompletion2)...
            && (t_SvcCompletion1<=t_JoinStation)...
            && (t_SvcCompletion1<=t_Sampling)
        if QL1 > 0
            num_JoinService = num_JoinService + 1;
            t_SvcCompletion1 = t_SvcCompletion1 +...
                ServiceTimes(num_JoinService);
            QL1 = QL1 - 1;
        else
            t_SvcCompletion1 = maxTime;
            BS1 = 0;
        end
    elseif (t_SvcCompletion2<=t_Arr)...
            && (t_SvcCompletion2<=t_SvcCompletion1)...
            && (t_SvcCompletion2<=t_JoinStation)...
            && (t_SvcCompletion2<=t_Sampling)
        if QL2 > 0
            num_JoinService = num_JoinService + 1;
            t_SvcCompletion2 = t_SvcCompletion2 +...
                ServiceTimes(num_JoinService);
            QL2 = QL2 - 1;
        else
            t_SvcCompletion2 = maxTime;
            BS2 = 0;
        end
    else
        num_SampleCount = num_SampleCount + 1;
        SampledQL1(num_SampleCount) = BS1 + QL1;
        SampledQL2(num_SampleCount) = BS2 + QL2;
        t_Sampling = t_Sampling + dt;
    end
end