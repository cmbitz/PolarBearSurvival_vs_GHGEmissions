% Script to compute confidence interval
% from fit parameters computed elsewhere
% Previously we bootstrapped the regression fit
% and saved B sets of fit parameters (B is 50k or 10k)
% So here we compute fit lines with all B sets
% hence we compute B fits for IFD as a function of cumCO2
% and then take the 2.5% and 97.5% quantiles to
% explicitly compute the CIs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bootstrap fit IFD vs CumCO2 with both observational and sampling uncertainty
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
load matfiles/Fit_CumCO2_vs_IFD_v5.mat  % Bootstrap fit with observational and sampling uncertainty

Nyrs=length(OBSyrs);
B = length(bi);
% make some space
MeanInterval=zeros(20,Nyrs,2);
PredInterval=MeanInterval;
yhat=zeros(20,Nyrs);
residualdist=zeros(20,B,Nyrs);

x = CumCO2;

for n=1:20

a = bi(n,:)';
b = bs(n,:)';
y = zeros(B,Nyrs);
y = a*ones(1,Nyrs) + b.*x';  % predictions based on mean slope distribution

yhat(n,:)=quantile(y,0.5);
MeanInterval(n,:,1)=quantile(y,0.975);
MeanInterval(n,:,2)=quantile(y,0.025);

% the rest of the loop computes the prediction intervals, not used though

residuals=OBSIFD(n,:)-yhat(n,:); residuals=residuals(:);
if n==11,
  ir=find(residuals<60);  % remove super outlier in small region
  residuals=residuals(ir);
  w = randsample(Nyrs-1,B*Nyrs,true);
else
  w = randsample(Nyrs,B*Nyrs,true);
end
resboots = residuals(w);
resboots = reshape(resboots,B,Nyrs);
PredInterval(n,:,1) = quantile(y+resboots,.975);
PredInterval(n,:,2) = quantile(y+resboots,.025);

residualdist(n,:,:)=resboots;

end

save matfiles/IFDvsCumCO2_Fit_CombinedUnc.mat   MeanInterval CumCO2 OBSIFD Nyrs yhat
%save matfiles/IFDvsCumCO2_Fit_CombinedUnc_residualdist.mat residualdist 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bootstrap fit IFD vs CumCO2 with only sampling uncertainty
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear
load matfiles/Fit_CumCO2_vs_IFD_v1.mat % Bootstrap fit with only sampling uncertainty

Nyrs=length(OBSyrs);
B = length(bi);

% make some space
MeanInterval=zeros(20,Nyrs,2);
PredInterval=MeanInterval;
yhat=zeros(20,Nyrs);

x = CumCO2;

for n=1:20

a = bi(n,:)';
b = bs(n,:)';
y = zeros(B,Nyrs);
y = a*ones(1,Nyrs) + b.*x';  % predictions based on mean slope distribution

yhat(n,:)=quantile(y,0.5);
MeanInterval(n,:,1)=quantile(y,0.975);
MeanInterval(n,:,2)=quantile(y,0.025);

end

save matfiles/IFDvsCumCO2_Fit_SamplingUnc.mat   MeanInterval  yhat

% note, yhat is same for v1 and v5 above, as they should be


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bootstrap fit Demog vs FD 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
load ../Molnar/Fig2.mat  % raw data from Molnar et al 2020, by request from Dr. Molnar
load matfiles/Fit_DemographicsvsFD.mat

m=2; % only compute CIs for m=2 since each type has different x
eval(['xy=cdf_StarveTime_',dname{m},';']) % data from the demographics model of Molnar et al
x=xy(1,:);  % this is the Fasting Duration
a = beari(m,:); a = a(:);
b = bears(m,:); b = b(:);
B = length(b);
Npts=length(x);
y = zeros(B,Npts);
y = a*ones(1,Npts) + b.*x;
y=y*100; % convert to percent
yhat=quantile(y,0.5);
MeanInterval(:,1)=quantile(y,0.975);
MeanInterval(:,2)=quantile(y,0.025);

save matfiles/DemographicsvsFD_Fit_Unc.mat yhat MeanInterval x

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bootstrap fit Demog vs CO2 with only sampling uncertainty (no obs exists)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
load matfiles/Fit_DemographicsvsCumCO2.mat

x=CumCO2;
Nyrs=length(CumCO2);
MeanInterval=zeros(20,5,Nyrs,2);
yhat=zeros(20,5,Nyrs);

for m=1:5
for n=1:20
a = phi0(n,m,:); a = a(:);
b = phi1(n,m,:); b = b(:);
B = length(b);

y = zeros(B,Nyrs);
y = a*ones(1,Nyrs) + b.*x';
y=y*100; % convert to percent
yhat(n,m,:)=quantile(y,0.5);
MeanInterval(n,m,:,1)=quantile(y,0.975);
MeanInterval(n,m,:,2)=quantile(y,0.025);

end
end

save matfiles/DemographicsvsCumCO2_Fit_Unc.mat yhat MeanInterval x
