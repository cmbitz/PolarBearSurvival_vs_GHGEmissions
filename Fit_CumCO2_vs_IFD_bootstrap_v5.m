% Compute the regression (with least square minimization) with bootstrapping to
% estimate the uncertainty in the regression slopes
% Consider two ways
% First with sampling error only - this is referred to as v1
% Second option also includes observational error on IFD and CumCO2 - this is referred to as v5
% assuming a log-normal distribution for systematic error of cumulative eCO2
% and assuming 10% random error on IFD (which has a trivial influence on results)

clear

ErrorVersion='v1';  % need to run twice, once for v1 and once for v5

%Friedlingstein land use (LU) data are from
%https://www.icos-cp.eu/science-and-impact/global-carbon-budget/2022
%Global_Carbon_Budget_2022v1.0.csv
%Spreadsheet (page 2 column B) says it has uncert of 0.7Gt per year or 2569 tons eCO2 per year
% I extracted just that column by hand and made a csv file,
% below convert it from GC/yr to Gt CO2/yr by multiplying by 3.664 

% rest of eCO2 data are PRIMAP data from https://zenodo.org/record/7727475
% https://zenodo.org/record/7727475/files/Guetschow-et-al-2023a-PRIMAP-hist_v2.4.2_final_no_extrap_no_rounding_09-Mar-2023.csv?download=1
% row 4985 which is EARTH KYOTOGHG M.0.EL
% I cut and paste this row in excel, transposed it, and saved to csv

filename='../2023/Friedlingstein.csv'; % file not provided, see above to download and generate 
F=readtable(filename);
filename='../2023/PRIMAP_from_Zenodo_v2.4.2.csv'; % file not provided, see above to download and generate
P=readtable(filename);
Fyrs=F{:,1};
FLU=F{:,2}*3.664;
Pyrs=P{:,1};
Pkyoto=P{:,3}; Pkyoto=Pkyoto/1e6; % convert to Gt from gigagram

% user must be sure this timeseries ends at least 2020 or later
% but starts no earlier than 1979
yrs=1979:2020;

iP1=find(Pyrs==yrs(1));
iP2=find(Pyrs==yrs(end));
iP=iP1:iP2;

iF1=find(Fyrs==yrs(1));
iF2=find(Fyrs==yrs(end));
iF=iF1:iF2;

eCO2=Pkyoto(iP)+FLU(iF);

figure(1)
subplot(211)
plot(Pyrs,Pkyoto,Fyrs,FLU)
ylabel('eCO2 - Gt per year')
legend('Kyoto GHG','LU')
subplot(212)
plot(Pyrs(iP),Pkyoto(iP),Fyrs(iF),FLU(iF),yrs,eCO2)
legend('Kyoto GHG','LU','sum')
xlabel('year')
ylabel('eCO2 - Gt per year')

% compute the cumulative eCO2 in Gt
CumCO2=cumsum(eCO2);

load InputMatfiles/SubpopulationNames.mat
N=1:length(econame);

filename='IceDates/IFDbyregion.csv'  % file is provided and scripts to reproduce
I=readtable(filename);
OBSyrs=I{:,1};
OBSIFD=I{:,2:21}; OBSIFD=OBSIFD';

% For check: compute regression using matlab's function fitlm
% and compare with by hand function witout bootstrapping.
% note, fitlm gives warnings for a few regions, but these are regions with so few 
% years with nonzero IFD that we did not present their fits
% they are computed here nonetheless for completeness, though should be disregarded

modelspec='IFD ~ 1 + CumCO2';

if ErrorVersion=='v1'
  B = 10000; % number of bootstraps for quantifying sampling error
else
  B = 50000; % number of bootstraps for quantifying sampling + observational error
  pd = makedist('Lognormal','mu',0.0099,'sigma',0.088);
  % systematic obs error cumC2
  syserr = random(pd,B*length(N),1)-1; syserr= reshape(syserr,length(N),B);
  % aslo add some random obs error to IFD, at 10% from Meier and Stewart (2019)
  IFDrand = true; 
end

% make some space in memory
bs = zeros(length(N),B);  % slopes
bi = bs;                  % intercepts

for n=N
  econame{n}
  IFD=OBSIFD(n,:)';
  [a,b]=regco2(CumCO2,IFD);
  trendobs(n)=b;
  tbl=table(CumCO2,IFD);
  eval(['mdl_',num2str(n),'=fitlm(tbl,modelspec);']);
  nsize=length(CumCO2);
  for b=1:B
    w = randsample(nsize,nsize,true);
    if ErrorVersion=='v1'
      [int,beta]=regco2(CumCO2(w),IFD(w)); % no obs unc in CO2 or IFD
    else
      if IFDrand
        [int,beta]=regco2((1.-syserr(n,b))*CumCO2(w),IFD(w).*(1+0.1*randn(nsize,1)));
      else
        [int,beta]=regco2((1.-syserr(n,b))*CumCO2(w),IFD(w));
      end
    end
    bs(n,b)=beta;
    bi(n,b)=int;
  end
end

% comment out so as not overwrite data provided, remove it to save output if you wish
 eval(['save matfiles/Fit_CumCO2_vs_IFD_',ErrorVersion,'.mat OBSIFD OBSyrs CumCO2 bi bs']);


% The rest was just a sanity check

display('The following are regression slopes, including CI, for S. Beaufort')
n=3;

display('bootstrap slope')
display(quantile(bs(n,:),[0.025, 0.5, 0.975]))

if ErrorVersion=='v1'
display('slope')
display(quantile(bs(n,:),[0.025, 0.5, 0.975]))
else
display('slope*(1-syserr)')
display(quantile(bs(n,:).*(1-syserr(n,:)),[0.025, 0.5, 0.975]))
end

display('Matlab script best estimate scenario')
eval(['range=coefCI(mdl_',num2str(n),',.05);']);
range=range(2,:);
display([range(1) trendobs(n) range(2)])



