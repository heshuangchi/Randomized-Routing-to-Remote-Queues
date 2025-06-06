function [SampledQL1, SampledQL2] = RJSQ_path_2SrDL(delay, p_JSQ, TimeHorizon, ArrTime, ServiceTime, dt)

maxTime = TimeHorizon*10;
Destin = zeros(length(ArrTime), 1);

% Initialization
t_Arr = ArrTime(1); 
num_Arr = 0;
num_EnRoute = 0;
t_JoinStation = maxTime; 
num_JoinStation = 0;
t_SvcCompletion1 = maxTime; 
t_SvcCompletion2 = maxTime;
num_JoinService = 0;
t_Sampling = dt;
QL1 = 0; QL2 = 0;
BS1 = 0; BS2 = 0;
SampledQL1 = zeros(TimeHorizon/dt, 1);
SampledQL2 = zeros(TimeHorizon/dt, 1);

num_SampleCount = 0;

while t_Sampling < TimeHorizon
    if (t_Arr<=t_SvcCompletion1) && (t_Arr<=t_SvcCompletion2)...
            && (t_Arr<=t_JoinStation) && (t_Arr<=t_Sampling)
        num_Arr = num_Arr + 1;
        P1 = (QL1+BS1<QL2+BS2)*p_JSQ+(QL1+BS1>QL2+BS2)*(1-p_JSQ)...
            +(QL1+BS1==QL2+BS2)*0.5;
        Destin(num_Arr) = 2 - (rand<P1);
        t_CustomerJoinStation = t_Arr+delay;
        cust = customerEnRoute(t_CustomerJoinStation);
        if num_EnRoute == 0
            t_JoinStation = t_CustomerJoinStation;
            headER = cust;
            tailER = cust;
            custTemp = tailER;
        else
            while (t_CustomerJoinStation < custTemp.time_JoinStation) &&...
                    ~isempty(custTemp.Prev)
                custTemp = custTemp.Prev;
            end
            if t_CustomerJoinStation < custTemp.time_JoinStation
                insertBefore(cust, custTemp);
                t_JoinStation = t_CustomerJoinStation;
                headER = cust;
            else
                insertAfter(cust, custTemp);
            end
            if isempty(cust.Next)
                tailER = cust;
            end
            custTemp = tailER;
        end
        num_EnRoute = num_EnRoute + 1;
        t_Arr = ArrTime(num_Arr+1);

    elseif (t_JoinStation<=t_Arr) && (t_JoinStation<=t_SvcCompletion1)...
            && (t_JoinStation<=t_SvcCompletion2) && (t_JoinStation<=t_Sampling)
        num_JoinStation = num_JoinStation + 1;
        if Destin(num_JoinStation) == 1
            if BS1 == 0 % if server 1 is idle
                BS1 = 1;
                num_JoinService = num_JoinService + 1;
                t_SvcCompletion1 = t_JoinStation + ServiceTime(num_JoinService); % departure time
            else
                QL1 = QL1 + 1;
            end
        elseif Destin(num_JoinStation) == 2
            if BS2 == 0 % if there is an idle server
                BS2 = 1;
                num_JoinService = num_JoinService + 1;
                t_SvcCompletion2 = t_JoinStation + ServiceTime(num_JoinService);
            else
                QL2 = QL2 + 1;
            end
        end
        num_EnRoute = num_EnRoute - 1;
        if num_EnRoute == 0
            t_JoinStation = maxTime;
        else
            headER = headER.Next;
            t_JoinStation = headER.time_JoinStation;
            removeCustomer(headER.Prev);
        end

    elseif (t_SvcCompletion1<=t_Arr) && (t_SvcCompletion1<=t_SvcCompletion2)...
            && (t_SvcCompletion1<=t_JoinStation) && (t_SvcCompletion1<=t_Sampling)
        if QL1 > 0
            num_JoinService = num_JoinService + 1;
            t_SvcCompletion1 = t_SvcCompletion1 + ServiceTime(num_JoinService);
            QL1 = QL1 - 1;
        else
            t_SvcCompletion1 = maxTime;
            BS1 = 0;
        end
    elseif (t_SvcCompletion2<=t_Arr) && (t_SvcCompletion2<=t_SvcCompletion1)...
            && (t_SvcCompletion2<=t_JoinStation) && (t_SvcCompletion2<=t_Sampling)
        if QL2 > 0
            num_JoinService = num_JoinService + 1;
            t_SvcCompletion2 = t_SvcCompletion2 + ServiceTime(num_JoinService);
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