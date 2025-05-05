function [mQL1, mQL2, mQL3, mQL4] = RJSQ_mQL_4SfDL(delay, chi, TimeHorizon,...
    ArrTimes, ServiceTimes, RandomRoutes)
% Two single-server stations, fixed delays

WarmupPeriod = TimeHorizon*0.3;
maxTime = TimeHorizon*10;
Destin = zeros(length(ArrTimes), 1);

% Initialization
t_PrevEvent = 0;
t_Arr = ArrTimes(1);
num_Arr = 0;
t_JoinStation = t_Arr + delay;
num_JoinStation = 0;
t_SvcCompletion1 = maxTime;
t_SvcCompletion2 = maxTime;
t_SvcCompletion3 = maxTime;
t_SvcCompletion4 = maxTime;
num_JoinService = 0;
QL1 = 0; QL2 = 0; QL3 = 0; QL4 = 0;
BS1 = 0; BS2 = 0; BS3 = 0; BS4 = 0;
sumQL1 = 0; sumQL2 = 0; sumQL3 = 0; sumQL4 = 0;

while t_Arr < WarmupPeriod
    if (t_Arr<=t_SvcCompletion1) && (t_Arr<=t_SvcCompletion2)...
            && (t_Arr<=t_SvcCompletion3) && (t_Arr<=t_SvcCompletion4)...
            && (t_Arr<=t_JoinStation)
        num_Arr = num_Arr + 1;
        P1 = 0.25 + (QL1+BS1<=QL2+BS2 && QL1+BS1<=QL3+BS3 && QL1+BS1<=QL4+BS4)*chi -...
            ~(QL1+BS1<=QL2+BS2 && QL1+BS1<=QL3+BS3 && QL1+BS1<=QL4+BS4)*chi/3;
        P2 = P1 + 0.25 + (QL2+BS2<QL1+BS1 && QL2+BS2<=QL3+BS3 && QL2+BS2<=QL4+BS4)*chi -...
            ~(QL2+BS2<QL1+BS1 && QL2+BS2<=QL3+BS3 && QL2+BS2<=QL4+BS4)*chi/3;
        P3 = P2 + 0.25 + (QL3+BS3<QL1+BS1 && QL3+BS3<QL2+BS2 && QL3+BS3<=QL4+BS4)*chi -...
            ~(QL3+BS3<QL1+BS1 && QL3+BS3<QL2+BS2 && QL3+BS3<=QL4+BS4)*chi/3;
        route = RandomRoutes(num_Arr);
        Destin(num_Arr) = 1*(route<=P1) +...
            2*(P1<route && route<=P2) +...
            3*(P2<route && route<=P3) + 4*(P3<route);
        t_Arr = ArrTimes(num_Arr+1);

    elseif (t_JoinStation<=t_Arr) && (t_JoinStation<=t_SvcCompletion1)...
            && (t_JoinStation<=t_SvcCompletion2)...
            && (t_JoinStation<=t_SvcCompletion3)...
            && (t_JoinStation<=t_SvcCompletion4)
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
        elseif Destin(num_JoinStation) == 3
            if BS3 == 0 % if there is an idle server
                BS3 = 1;
                num_JoinService = num_JoinService + 1;
                t_SvcCompletion3 = t_JoinStation +...
                    ServiceTimes(num_JoinService);
            else
                QL3 = QL3 + 1;
            end
        elseif Destin(num_JoinStation) == 4
            if BS4 == 0 % if there is an idle server
                BS4 = 1;
                num_JoinService = num_JoinService + 1;
                t_SvcCompletion4 = t_JoinStation +...
                    ServiceTimes(num_JoinService);
            else
                QL4 = QL4 + 1;
            end
        end
        t_JoinStation = ArrTimes(num_JoinStation+1) + delay;

    elseif (t_SvcCompletion1<=t_Arr) &&...
            (t_SvcCompletion1<=t_SvcCompletion2)...
            && (t_SvcCompletion1<=t_SvcCompletion3)...
            && (t_SvcCompletion1<=t_SvcCompletion4)...
            && (t_SvcCompletion1<=t_JoinStation)
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
            && (t_SvcCompletion2<=t_SvcCompletion3)...
            && (t_SvcCompletion2<=t_SvcCompletion4)...
            && (t_SvcCompletion2<=t_JoinStation)
        if QL2 > 0
            num_JoinService = num_JoinService + 1;
            t_SvcCompletion2 = t_SvcCompletion2 +...
                ServiceTimes(num_JoinService);
            QL2 = QL2 - 1;
        else
            t_SvcCompletion2 = maxTime;
            BS2 = 0;
        end

    elseif (t_SvcCompletion3<=t_Arr)...
            && (t_SvcCompletion3<=t_SvcCompletion1)...
            && (t_SvcCompletion3<=t_SvcCompletion2)...
            && (t_SvcCompletion3<=t_SvcCompletion4)...
            && (t_SvcCompletion3<=t_JoinStation)
        if QL3 > 0
            num_JoinService = num_JoinService + 1;
            t_SvcCompletion3 = t_SvcCompletion3 +...
                ServiceTimes(num_JoinService);
            QL3 = QL3 - 1;
        else
            t_SvcCompletion3 = maxTime;
            BS3 = 0;
        end

    elseif (t_SvcCompletion4<=t_Arr)...
            && (t_SvcCompletion4<=t_SvcCompletion1)...
            && (t_SvcCompletion4<=t_SvcCompletion2)...
            && (t_SvcCompletion4<=t_SvcCompletion3)...
            && (t_SvcCompletion4<=t_JoinStation)
        if QL4 > 0
            num_JoinService = num_JoinService + 1;
            t_SvcCompletion4 = t_SvcCompletion4 +...
                ServiceTimes(num_JoinService);
            QL4 = QL4 - 1;
        else
            t_SvcCompletion4 = maxTime;
            BS4 = 0;
        end
    end
end

t = t_Arr;
t_Start = t;

while t < TimeHorizon
    t_PrevEvent = t;
    QL1_PrevEvent = QL1; 
    QL2_PrevEvent = QL2; 
    QL3_PrevEvent = QL3; 
    QL4_PrevEvent = QL4;
    BS1_PrevEvent = BS1; 
    BS2_PrevEvent = BS2; 
    BS3_PrevEvent = BS3;
    BS4_PrevEvent = BS4;

    if (t_Arr<=t_SvcCompletion1) && (t_Arr<=t_SvcCompletion2)...
            && (t_Arr<=t_SvcCompletion3) && (t_Arr<=t_SvcCompletion4)...
            && (t_Arr<=t_JoinStation)
        t = t_Arr;
        num_Arr = num_Arr + 1;
        P1 = 0.25 + (QL1+BS1<=QL2+BS2 && QL1+BS1<=QL3+BS3 && QL1+BS1<=QL4+BS4)*chi -...
            ~(QL1+BS1<=QL2+BS2 && QL1+BS1<=QL3+BS3 && QL1+BS1<=QL4+BS4)*chi/3;
        P2 = P1 + 0.25 + (QL2+BS2<QL1+BS1 && QL2+BS2<=QL3+BS3 && QL2+BS2<=QL4+BS4)*chi -...
            ~(QL2+BS2<QL1+BS1 && QL2+BS2<=QL3+BS3 && QL2+BS2<=QL4+BS4)*chi/3;
        P3 = P2 + 0.25 + (QL3+BS3<QL1+BS1 && QL3+BS3<QL2+BS2 && QL3+BS3<=QL4+BS4)*chi -...
            ~(QL3+BS3<QL1+BS1 && QL3+BS3<QL2+BS2 && QL3+BS3<=QL4+BS4)*chi/3;
        route = RandomRoutes(num_Arr);
        Destin(num_Arr) = 1*(route<=P1) +...
            2*(P1<route && route<=P2) +...
            3*(P2<route && route<=P3) + 4*(P3<route);
        t_Arr = ArrTimes(num_Arr+1);

    elseif (t_JoinStation<=t_Arr)...
            && (t_JoinStation<=t_SvcCompletion1)...
            && (t_JoinStation<=t_SvcCompletion2)...
            && (t_JoinStation<=t_SvcCompletion3)...
            && (t_JoinStation<=t_SvcCompletion4)
        t = t_JoinStation;
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
        elseif Destin(num_JoinStation) == 3
            if BS3 == 0 % if there is an idle server
                BS3 = 1;
                num_JoinService = num_JoinService + 1;
                t_SvcCompletion3 = t_JoinStation +...
                    ServiceTimes(num_JoinService);
            else
                QL3 = QL3 + 1;
            end
        elseif Destin(num_JoinStation) == 4
            if BS4 == 0 % if there is an idle server
                BS4 = 1;
                num_JoinService = num_JoinService + 1;
                t_SvcCompletion4 = t_JoinStation +...
                    ServiceTimes(num_JoinService);
            else
                QL4 = QL4 + 1;
            end
        end
        t_JoinStation = ArrTimes(num_JoinStation+1) + delay;

    elseif (t_SvcCompletion1<=t_Arr)...
            && (t_SvcCompletion1<=t_SvcCompletion2)...
            && (t_SvcCompletion1<=t_SvcCompletion3)...
            && (t_SvcCompletion1<=t_SvcCompletion4)...
            && (t_SvcCompletion1<=t_JoinStation)
        t = t_SvcCompletion1;
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
            && (t_SvcCompletion2<=t_SvcCompletion3)...
            && (t_SvcCompletion2<=t_SvcCompletion4)...
            && (t_SvcCompletion2<=t_JoinStation)
        t = t_SvcCompletion2;
        if QL2 > 0
            num_JoinService = num_JoinService + 1;
            t_SvcCompletion2 = t_SvcCompletion2 +...
                ServiceTimes(num_JoinService);
            QL2 = QL2 - 1;
        else
            t_SvcCompletion2 = maxTime;
            BS2 = 0;
        end

    elseif (t_SvcCompletion3<=t_Arr)...
            && (t_SvcCompletion3<=t_SvcCompletion1)...
            && (t_SvcCompletion3<=t_SvcCompletion2)...
            && (t_SvcCompletion3<=t_SvcCompletion4)...
            && (t_SvcCompletion3<=t_JoinStation)
        t = t_SvcCompletion3;
        if QL3 > 0
            num_JoinService = num_JoinService + 1;
            t_SvcCompletion3 = t_SvcCompletion3 +...
                ServiceTimes(num_JoinService);
            QL3 = QL3 - 1;
        else
            t_SvcCompletion3 = maxTime;
            BS3 = 0;
        end

    elseif (t_SvcCompletion4<=t_Arr)...
            && (t_SvcCompletion4<=t_SvcCompletion1)...
            && (t_SvcCompletion4<=t_SvcCompletion2)...
            && (t_SvcCompletion4<=t_SvcCompletion3)...
            && (t_SvcCompletion4<=t_JoinStation)
        t = t_SvcCompletion4;
        if QL4 > 0
            num_JoinService = num_JoinService + 1;
            t_SvcCompletion4 = t_SvcCompletion4 +...
                ServiceTimes(num_JoinService);
            QL4 = QL4 - 1;
        else
            t_SvcCompletion4 = maxTime;
            BS4 = 0;
        end
    end
    sumQL1 = sumQL1+(t-t_PrevEvent)*(BS1_PrevEvent+QL1_PrevEvent);
    sumQL2 = sumQL2+(t-t_PrevEvent)*(BS2_PrevEvent+QL2_PrevEvent);
    sumQL3 = sumQL3+(t-t_PrevEvent)*(BS3_PrevEvent+QL3_PrevEvent);
    sumQL4 = sumQL4+(t-t_PrevEvent)*(BS4_PrevEvent+QL4_PrevEvent);
end
mQL1 = sumQL1/(t_PrevEvent-t_Start);
mQL2 = sumQL2/(t_PrevEvent-t_Start);
mQL3 = sumQL3/(t_PrevEvent-t_Start);
mQL4 = sumQL4/(t_PrevEvent-t_Start);
end