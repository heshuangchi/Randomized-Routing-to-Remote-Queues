function [sampleMTT, sampleMWT, additionalJSQ] = GeoSepQueues_3S(lambda,...
    mu, TimeHorizon, ArrTimes, ServiceRequirements,...
    LocationX, LocationY, deltaTime)

WarmupPeriod = TimeHorizon*0.3;
maxTime = TimeHorizon*10;
Destin = zeros(length(ArrTimes), 1);
delay = zeros(3, length(ArrTimes));

delay(1, :) = sqrt((LocationX - 50).^2 + (LocationY - 50).^2);
delay(2, :) = sqrt((LocationX - 50).^2 + (LocationY - 150).^2);
delay(3, :) = sqrt((LocationX - 150).^2 + (LocationY - 50).^2);

% Initialization
t = 0;
t_Arr = ArrTimes(1);
num_Arr = 0;
num_EnRoute = 0;
t_JoinStation = maxTime;
num_JoinStation = 0;
t_SvcCompletion1 = maxTime;
t_SvcCompletion2 = maxTime;
t_SvcCompletion3 = maxTime;
num_JoinService = 0;
QL = zeros(3, 1);
BS = zeros(3,1);
sumQL = 0;
sumTT = 0;

while t < WarmupPeriod
    if (t_Arr<=t_SvcCompletion1) && (t_Arr<=t_SvcCompletion2)...
            && (t_Arr<=t_SvcCompletion3) && (t_Arr<=t_JoinStation)
        t = t_Arr;
        num_Arr = num_Arr + 1;
        nearestStation = 1*(delay(1,num_Arr) <= delay(2,num_Arr) &&...
            delay(1,num_Arr) <= delay(3,num_Arr)) + 2*(delay(2,num_Arr) < delay(1,num_Arr) &&...
            delay(2,num_Arr) <= delay(3,num_Arr)) + 3*(delay(3,num_Arr) < delay(1,num_Arr) &&...
            delay(3,num_Arr) < delay(2,num_Arr));
        shortestQueue = 1*((QL(1)+BS(1))/mu(1) <= (QL(2)+BS(2))/mu(2) && (QL(1)+BS(1))/mu(1) <= (QL(3)+BS(3))/mu(3))...
            + 2*((QL(2)+BS(2))/mu(2) < (QL(1)+BS(1))/mu(1) && (QL(2)+BS(2))/mu(2) <= (QL(3)+BS(3))/mu(3))...
            + 3*((QL(3)+BS(3))/mu(3) < (QL(1)+BS(1))/mu(1) && (QL(3)+BS(3))/mu(3) < (QL(2)+BS(2))/mu(2));
        if ((QL(nearestStation)+BS(nearestStation))/mu(nearestStation) >...
                (QL(shortestQueue)+BS(shortestQueue))/mu(shortestQueue))...
                && (delay(shortestQueue, num_Arr) - delay(nearestStation, num_Arr) < deltaTime)
            Destin(num_Arr) = shortestQueue;
            delayCurrent = delay(shortestQueue, num_Arr);
        else
            Destin(num_Arr) = nearestStation;
            delayCurrent = delay(nearestStation, num_Arr);
        end
        t_CustomerJoinStation = t_Arr + delayCurrent;
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
        t_Arr = ArrTimes(num_Arr+1);

    elseif (t_JoinStation<=t_Arr) && (t_JoinStation<=t_SvcCompletion1)...
            && (t_JoinStation<=t_SvcCompletion2) && (t_JoinStation<=t_SvcCompletion3)
        num_JoinStation = num_JoinStation + 1;
        if Destin(num_JoinStation) == 1
            if BS(1) == 0 % if server 1 is idle
                BS(1) = 1;
                num_JoinService = num_JoinService + 1;
                t_SvcCompletion1 = t_JoinStation +...
                    ServiceRequirements(num_JoinService)/mu(1); % departure time
            else
                QL(1) = QL(1) + 1;
            end
        elseif Destin(num_JoinStation) == 2
            if BS(2) == 0 % if server 2 is idle
                BS(2) = 1;
                num_JoinService = num_JoinService + 1;
                t_SvcCompletion2 = t_JoinStation +...
                    ServiceRequirements(num_JoinService)/mu(2);
            else
                QL(2) = QL(2) + 1;
            end
        else
            if BS(3) == 0 % if server 3 is idle
                BS(3) = 1;
                num_JoinService = num_JoinService + 1;
                t_SvcCompletion3 = t_JoinStation +...
                    ServiceRequirements(num_JoinService)/mu(3);
            else
                QL(3) = QL(3) + 1;
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
            && (t_SvcCompletion1<=t_SvcCompletion3) && (t_SvcCompletion1<=t_JoinStation)
        if QL(1) > 0
            num_JoinService = num_JoinService + 1;
            t_SvcCompletion1 = t_SvcCompletion1 +...
                ServiceRequirements(num_JoinService)/mu(1);
            QL(1) = QL(1) - 1;
        else
            t_SvcCompletion1 = maxTime;
            BS(1) = 0;
        end

    elseif (t_SvcCompletion2<=t_Arr) && (t_SvcCompletion2<=t_SvcCompletion1)...
            && (t_SvcCompletion2<=t_SvcCompletion3) && (t_SvcCompletion2<=t_JoinStation)
        if QL(2) > 0
            num_JoinService = num_JoinService + 1;
            t_SvcCompletion2 = t_SvcCompletion2 +...
                ServiceRequirements(num_JoinService)/mu(2);
            QL(2) = QL(2) - 1;
        else
            t_SvcCompletion2 = maxTime;
            BS(2) = 0;
        end

    elseif (t_SvcCompletion3<=t_Arr) && (t_SvcCompletion3<=t_SvcCompletion1)...
            && (t_SvcCompletion3<=t_SvcCompletion2) && (t_SvcCompletion3<=t_JoinStation)
        if QL(3) > 0
            num_JoinService = num_JoinService + 1;
            t_SvcCompletion3 = t_SvcCompletion3 +...
                ServiceRequirements(num_JoinService)/mu(3);
            QL(3) = QL(3) - 1;
        else
            t_SvcCompletion3 = maxTime;
            BS(3) = 0;
        end
    end
end

t_Start = t;

num_TTCount = 0;
num_JSQCout = 0;

while t < TimeHorizon
    t_PrevEvent = t;
    QL_PrevEvent = QL;
    if (t_Arr<=t_SvcCompletion1) && (t_Arr<=t_SvcCompletion2)...
            && (t_Arr<=t_SvcCompletion3) && (t_Arr<=t_JoinStation)
        t = t_Arr;
        num_Arr = num_Arr + 1;
        nearestStation = 1*(delay(1,num_Arr) <= delay(2,num_Arr) &&...
            delay(1,num_Arr) <= delay(3,num_Arr)) + 2*(delay(2,num_Arr) < delay(1,num_Arr) &&...
            delay(2,num_Arr) <= delay(3,num_Arr)) + 3*(delay(3,num_Arr) < delay(1,num_Arr) &&...
            delay(3,num_Arr) < delay(2,num_Arr));
        shortestQueue = 1*((QL(1)+BS(1))/mu(1) <= (QL(2)+BS(2))/mu(2) && (QL(1)+BS(1))/mu(1) <= (QL(3)+BS(3))/mu(3))...
            + 2*((QL(2)+BS(2))/mu(2) < (QL(1)+BS(1))/mu(1) && (QL(2)+BS(2))/mu(2) <= (QL(3)+BS(3))/mu(3))...
            + 3*((QL(3)+BS(3))/mu(3) < (QL(1)+BS(1))/mu(1) && (QL(3)+BS(3))/mu(3) < (QL(2)+BS(2))/mu(2));
        if ((QL(nearestStation)+BS(nearestStation))/mu(nearestStation) >...
                (QL(shortestQueue)+BS(shortestQueue))/mu(shortestQueue))...
                && (delay(shortestQueue, num_Arr) - delay(nearestStation, num_Arr) < deltaTime)
            Destin(num_Arr) = shortestQueue;
            delayCurrent = delay(shortestQueue, num_Arr);
            num_JSQCout = num_JSQCout + 1;
        else
            Destin(num_Arr) = nearestStation;
            delayCurrent = delay(nearestStation, num_Arr);
        end
        t_CustomerJoinStation = t_Arr + delayCurrent;
        sumTT = sumTT + delayCurrent;
        num_TTCount = num_TTCount + 1;
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
        t_Arr = ArrTimes(num_Arr+1);

    elseif (t_JoinStation<=t_Arr) && (t_JoinStation<=t_SvcCompletion1)...
            && (t_JoinStation<=t_SvcCompletion2) && (t_JoinStation<=t_SvcCompletion3)
        num_JoinStation = num_JoinStation + 1;
        t = t_JoinStation;
        if Destin(num_JoinStation) == 1
            if BS(1) == 0 % if server 1 is idle
                BS(1) = 1;
                num_JoinService = num_JoinService + 1;
                t_SvcCompletion1 = t_JoinStation +...
                    ServiceRequirements(num_JoinService)/mu(1); % departure time
            else
                QL(1) = QL(1) + 1;
            end
        elseif Destin(num_JoinStation) == 2
            if BS(2) == 0 % if server 2 is idle
                BS(2) = 1;
                num_JoinService = num_JoinService + 1;
                t_SvcCompletion2 = t_JoinStation +...
                    ServiceRequirements(num_JoinService)/mu(2);
            else
                QL(2) = QL(2) + 1;
            end
        else
            if BS(3) == 0 % if server 3 is idle
                BS(3) = 1;
                num_JoinService = num_JoinService + 1;
                t_SvcCompletion3 = t_JoinStation +...
                    ServiceRequirements(num_JoinService)/mu(3);
            else
                QL(3) = QL(3) + 1;
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
            && (t_SvcCompletion1<=t_SvcCompletion3) && (t_SvcCompletion1<=t_JoinStation)
        t = t_SvcCompletion1;
        if QL(1) > 0
            num_JoinService = num_JoinService + 1;
            t_SvcCompletion1 = t_SvcCompletion1 +...
                ServiceRequirements(num_JoinService)/mu(1);
            QL(1) = QL(1) - 1;
        else
            t_SvcCompletion1 = maxTime;
            BS(1) = 0;
        end

    elseif (t_SvcCompletion2<=t_Arr) && (t_SvcCompletion2<=t_SvcCompletion1)...
            && (t_SvcCompletion2<=t_SvcCompletion3) && (t_SvcCompletion2<=t_JoinStation)
        t = t_SvcCompletion2;
        if QL(2) > 0
            num_JoinService = num_JoinService + 1;
            t_SvcCompletion2 = t_SvcCompletion2 +...
                ServiceRequirements(num_JoinService)/mu(2);
            QL(2) = QL(2) - 1;
        else
            t_SvcCompletion2 = maxTime;
            BS(2) = 0;
        end

    elseif (t_SvcCompletion3<=t_Arr) && (t_SvcCompletion3<=t_SvcCompletion1)...
            && (t_SvcCompletion3<=t_SvcCompletion2) && (t_SvcCompletion3<=t_JoinStation)
        t = t_SvcCompletion3;
        if QL(3) > 0
            num_JoinService = num_JoinService + 1;
            t_SvcCompletion3 = t_SvcCompletion3 +...
                ServiceRequirements(num_JoinService)/mu(3);
            QL(3) = QL(3) - 1;
        else
            t_SvcCompletion3 = maxTime;
            BS(3) = 0;
        end
    end
    sumQL = sumQL+(t-t_PrevEvent)*(QL_PrevEvent(1)+QL_PrevEvent(2)+QL_PrevEvent(3));
end
sampleMTT = sumTT/num_TTCount;
sampleMWT = sumQL/(t_PrevEvent-t_Start)/lambda;
additionalJSQ = num_JSQCout/num_TTCount;
end