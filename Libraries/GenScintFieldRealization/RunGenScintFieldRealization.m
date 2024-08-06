function [Scin_psi, Scin_amp, Scin_phi] = RunGenScintFieldRealization(userInput,satGEOM,U_L1_ori,rhoFVeff_L1_ori)
%Usage: [Scin_psi, Scin_amp, Scin_phi] = RunGenScintFieldRealization(userInput,satGEOM,U_L1_ori)
%This program uses IPE parameters to
%generate L1, L2, and L5 complex scintillation
%realizations.
%INPUT: userInput - user input parameters: length, Number of frequencies to
%simulate
% satGEOM - propagation geometric parameter: los range, propagation distance, veff. 
% U_L1_ori - L1 U value mapped from user input S4. 
%Written by Charles Rino
%Charles.Rino@colorado.edu
%Modified by Dongyang Xu
%Dongyang.Xu@colorado.edu Oct 25, 2018
%Libraries:   GenScintFieldRealization Utilities 

%%%%%Fixed Parameters%%%%%%%%%%%%%%%%%%%%%
c = 299792458;                    % Speed of light (vacuum)
Dt = 0.01;                        % Sampling time (10 ms or 100 Hz)
nsamp_seg = userInput.length/Dt;  % Samples per segment
nfft=nicefftnum(nsamp_seg);       % Number of FFT samples

%frequencies
freqGPS(1)=154*10.23e6;  freqID{1}='L1';
freqGPS(2)=120*10.23e6;  freqID{2}='L2';
freqGPS(3)=115*10.23e6;  freqID{3}='L5';

if(sum(userInput.RXVel)~=0)
    sat_rngeG=satGEOM.sat_rnge;
    rngp         =satGEOM.rngp;
    veff          =satGEOM.veff;
    rngp_eff   =rngp.*(sat_rngeG-rngp)./sat_rngeG;
    rhoOveffk =sqrt(rngp_eff)./veff;   %rhoFOveff*sqrt(k)   <= frequency independent part
else
    sat_rngeG=nan;
    rngp         =nan;
    veff          =nan;
    rngp_eff   =nan;
    rhoOveffk =nan;  
end

U = zeros(1,userInput.frequencyNo);  %% Joy
mu0 = zeros(1,userInput.frequencyNo);  %% Joy
U(1) = U_L1_ori;
[p1,p2,mu0(1)]=GPS_ScintModelParams(U(1));
Scin_psi=zeros(userInput.frequencyNo,nfft)*(1+1i);
Scin_amp=zeros(userInput.frequencyNo,nsamp_seg);
Scin_phi=zeros(userInput.frequencyNo,nsamp_seg);
S4=zeros(1,userInput.frequencyNo);
rhoOveffk=mean(rhoOveffk);  %% Joy
t_sec = 0:Dt:userInput.length-Dt;
% Use the same seed for different dynamics %%% Joy
SEED=rng;  %One white noise realization for all frequencies

rhoFOveff = zeros(1,userInput.frequencyNo);  %% Joy

for nfreq=1:userInput.frequencyNo
    if nfreq==1
        if(sum(userInput.RXVel)~=0)
            rhoFOveff(1) = rhoOveffk/sqrt(2*pi*freqGPS(nfreq)/c);
        else
            rhoFOveff(1) = rhoFVeff_L1_ori;
        end
        [Scin_psi(1,:),~,fracMom]=GenScintFieldRealization(U(1),p1,p2,mu0(1),rhoFOveff(1),Dt,nfft,SEED);  %% Joy
        S4(1)=sqrt(fracMom(2)-1);
        [~, tau0(1)] = ParaMappingInv(U(1),rhoFOveff(1));
    else
        [X0]=FreqExtrapolate(U(1),p1,mu0(1),p2,rhoFOveff(1),freqGPS(1),freqGPS(nfreq));  %% Joy
        U(nfreq) = X0(1); mu0(nfreq)=X0(3); rhoFOveff(nfreq)=X0(5);  %% Joy
        [Scin_psi(nfreq,:),~,fracMom] = GenScintFieldRealization(U(nfreq),p1,p2,mu0(nfreq),rhoFOveff(nfreq),Dt,nfft,SEED);
        S4(nfreq)=sqrt(fracMom(2)-1);
        [~, tau0(nfreq)] = ParaMappingInv(U(nfreq),rhoFOveff(nfreq));
    end
end

if userInput.plotSign==1
    for nfreq=1:userInput.frequencyNo
        ID=generateIDstring2(U(nfreq),rhoFOveff(nfreq),S4(nfreq),tau0(nfreq));  % Joy
        if(nfreq ==1)
        hx = figure;
        end
        figure(hx)
        Scin_amp(nfreq, :) = abs(Scin_psi(nfreq, 1:nsamp_seg));
        Scin_phi(nfreq, :) = unwrap(atan2(imag(Scin_psi(nfreq,1:nsamp_seg)),real(Scin_psi(nfreq,1:nsamp_seg))));
        ax(1) = subplot(userInput.frequencyNo,2,nfreq*2-1);
        plot(t_sec/60,dB10(Scin_amp(nfreq, :).^2),'r')
        grid on
        ylabel('I-dB')
        title(ID)
        axis([min(t_sec/60) max(t_sec/60) -45 10])
        text(4,-40,['S4=',num2str(S4(nfreq))])
        ax(2)=subplot(userInput.frequencyNo,2,nfreq*2);
        plot(t_sec/60,Scin_phi(nfreq, :),'r')
        grid on
        ylabel('\phi-rad')
        xlabel('t-min')
        axis([min(t_sec/60) max(t_sec/60)  min(floor(Scin_phi(nfreq, :)))  max(ceil(Scin_phi(nfreq, :)))])
        linkaxes(ax,'x')
        bold_fig
    end
end