function IDstring=generateIDstring2(U0,rhoFOveff,S4,tau0)
%Generate ID character string
IDU=num2str(fix(U0*100)/100);
IDrho=num2str(fix(rhoFOveff*100)/100);
IDS4=num2str(fix(S4*100)/100);
IDtau0=num2str(fix(tau0*100)/100);
ID=['U=',IDU,' \rho_F/V_e_f_f=',IDrho];
IDstring=[ID,' S_4=',IDS4, ' \tau_0=',IDtau0];
return
