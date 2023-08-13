% Impact = slope of IFL vs CumCO2 X slope of population vs Fasting duration

load matfiles/Fit_CumCO2_vs_IFD_v5.mat    % fit parameters for IFD vs CumCO2
load matfiles/Fit_DemographicsvsFD.mat  % fit parameters for Recruitment Failure vs FD
% note below we include the offset to shift the y-intercept of the first fit so it is FD vs CumCO2

B = 50000; % number of bootstraps 
phi1=zeros(20,7,B);
phi0=zeros(20,7,B);

for n=1:20
for m=1:5

w1 = randsample(50000,B,true);
w2 = randsample(10000,B,true);

if (n>16 | n==14)
 offset=-24;
else
 offset=0;
end

phi0(n,m,:)=beari(m,w2)+bears(m,w2).*(bi(n,w1)+offset);
phi1(n,m,:)=bs(n,w1).*bears(m,w2);

end
end

save matfiles/Fit_DemographicsvsCumCO2.mat phi0 phi1 CumCO2 dname 



