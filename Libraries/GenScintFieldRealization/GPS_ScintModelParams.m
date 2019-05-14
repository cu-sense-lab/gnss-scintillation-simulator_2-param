function    [p1,p2,mu0]=GPS_ScintModelParams(U)
%
%Preliminary model parameters as of February 18, 2017
if U<1
    p1=3; p2=3; mu0=1;
else
    p1=2.6; p2=3.7; mu0=0.6;
end
return