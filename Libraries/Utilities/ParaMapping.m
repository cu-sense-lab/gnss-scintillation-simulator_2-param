function [U_mapped,rhoFVeff_mapped] = ParaMapping(userInput)
%Usage: [U_mapped,rhoFVeff_mapped] = ParaMapping(userInput)
%This program converts the user input S4 and intensity decorrelation time
%into the compact two-component power law phase screen model parameters U
%and rhoF/veff using numerically evaluated mapping prescribed by the model and validated with real data. 
%INPUT:
%   userInput: S4 and tau0
%OUTPUT:
%   U_mapped
%   rhoFVeff_mapped
% written by Dongyang.Xu@colorado.edu

 S4_range = [0.5883, 0.6760, 0.7480, 0.8071, 0.8558, 0.8961, 0.9296, 0.9576, 0.9811, 1.0010];
 U_range = 0.75:0.25:3.0;
 a_log_range = [0.7841, 0.7361, 0.6985, 0.6693, 0.6440, 0.6231, 0.6027, 0.5874, 0.5724, 0.5574];
 U_mapped = interp1(S4_range,U_range,userInput.S4,'spline');
 a_mapped = interp1(U_range,a_log_range,U_mapped,'spline');
 rhoFVeff_mapped = userInput.tau0/a_mapped;
end