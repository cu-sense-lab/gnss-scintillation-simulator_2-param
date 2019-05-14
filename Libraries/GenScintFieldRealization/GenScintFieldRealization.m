function       [psi,phase0,fracMom]=...
                      GenScintFieldRealization(U,p1,p2,mu0,rhoOveff,Dt,nfft,SEED)
%USAGE: [psi,phase0,fracMom]=generateSurrogateHk(U,p1,p2,mu0,rhoOveff,Dt,nfft,SEED)
%
%Generate time-domain surrogate realization of complex field
%INPUT:
%Phase screen parameters=U, p1, p2, mu0, rhoOveff
%Intensity time sampling      =Dt sec.
%DFT sampling                    =nfft
%Random number seed      =SEED
%
%OUTPUT
%psi          =complex field (hk)
%phase0  =equivalent phase screen realization
%fracMom=(1X5) fractional moments 1 through 5  
%Note: S4 = sqrt(fracMom(2)-1)
%fDop      =Doppler frequency range
%mu        =normalizae frequency
%

%Doppler sampling
fDop=(-nfft/2:nfft/2-1)/(nfft*Dt); 

%Convert Doppler to mu
mu=2*pi*fDop*rhoOveff;

 if mu0>=1
        Cpp=U;
    else
        Cpp=U/mu0^(p2-p1);
    end
%Generate phase screen realization
rng(SEED);
[phase0, SDF0]= GenPSRealization(Cpp,p1,p2,mu0,mu,nfft);

%Remove linear trend to force segment too segment continuity
nsamps=length(phase0);
%Jmax=12;
%phase0=WaveletFilter(phase0,Jmax);
y=linex(1:nsamps,1,nsamps,phase0(1),phase0(nsamps));
phase0=phase0-y;

%Forward propagation
psi=exp(1i*phase0);
pfac=fftshift(exp(-1i*(mu).^2/2));   %Parabolic approximation 
psi_hat=fft(psi);
psi_hat=psi_hat.*pfac;
psi=ifft(psi_hat);

fracMom=generate_fracMom(abs(psi).^2);
return