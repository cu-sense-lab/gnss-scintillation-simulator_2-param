function   [phase0,Pmu]=GenPSRealization(Cpp,p1,p2,mu0,mu,nfft)
%USAGE:  [Pmu,nb]=generatePmu(Cpp,p1,p2,mu0,mu)
%
%Generate P(mu) for parameters Cpp, p1, p2, mu0

nmu=length(mu);
Pmu=zeros(1,nmu);
nb=[];
for n=1:nmu
     Pmu1=abs(mu(n))^(-p1);
     Pmu2=mu0^(p2-p1)*abs(mu(n))^(-p2);
     if Pmu1<=Pmu2
         Pmu(n)=Cpp*Pmu1;
         nb=n;
     else
         Pmu(n)=Cpp*Pmu2;
     end
end

Pmu(nfft/2+1)=0;
mu_p=mu(nfft/2+2:nfft);
dmu=mu_p(2)-mu_p(1);

rootSDF = sqrt(Pmu*dmu/2/pi);
xi=(randn(1,nmu)+1i*randn(1,nmu));                       
phase0=real(fftshift(fft(fftshift(rootSDF.*xi))))*1.22;  
return