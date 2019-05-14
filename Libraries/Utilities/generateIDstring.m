function IDstring=generateIDstring(U0,p1,p2,mu0,rhoFOveff,S4)
%Generate ID character string
IDU=num2str(fix(U0*100)/100);
IDp1=num2str(fix(p1*100)/100);
IDmu0=num2str(fix(mu0*100)/100);
IDp2=num2str(fix(p2*100)/100);
IDrho=num2str(fix(rhoFOveff*100)/100);
IDS4=num2str(fix(S4*100)/100);
ID=['U=',IDU,' p1=',IDp1,' mu0=',IDmu0,' p2=',IDp2,' rho=',IDrho];
IDstring=[ID,' S4=',IDS4];
return
