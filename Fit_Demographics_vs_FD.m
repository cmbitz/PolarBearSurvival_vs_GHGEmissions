clear;

load ../Molnar/Fig2.mat  % raw data from Molnar et al 2020
                         % available by request from Peter Molnar 
plot(cdf_StarveTime_AFC(1,:),cdf_StarveTime_AFC(2,:),'x') % verify it is Molnar et al 2020 Fig 2
hold;plot(LinReg_AFC(1,:),LinReg_AFC(2,:),'o');hold       

% 
AFC=cdf_StarveTime_AFC(1,:)';
AFC_Lact=cdf_StarveTime_AFC_Lact(1,:)'; 
AM=cdf_StarveTime_AM(1,:)'; 
AF=cdf_StarveTime_AF(1,:)'; 
AFY=cdf_StarveTime_AFY(1,:)'; 

M=5; % number of types
B=10000; % number of bootstraps
bears = zeros(M,B); % slopes 
beari = bears;      % intercepts

for b=1:B
 % AFC and AFC_Lact
 cdfpercent=cdf_StarveTime_AFC(2,:)';
 i=find(cdfpercent>=0.05 & cdfpercent<=0.95);
 y=cdfpercent(i);
 nsize = length(y);

 x=AFC(i);  m = 1;
 w = randsample(nsize,nsize,true);
 [int,beta]=regco2(x(w),y(w));
 bears(m,b)=beta;
 beari(m,b)=int;

 x=AFC_Lact(i);  m = 2;
 w = randsample(nsize,nsize,true);
 [int,beta]=regco2(x(w),y(w));
 bears(m,b)=beta;
 beari(m,b)=int;

%%%%%%%%%%%%

 % AF
 cdfpercent=cdf_StarveTime_AF(2,:)';
 i=find(cdfpercent>=0.05 & cdfpercent<=0.95);
 y=cdfpercent(i);
 nsize = length(y);

 x=AF(i);  m = 3;
 w = randsample(nsize,nsize,true);
 [int,beta]=regco2(x(w),y(w));
 bears(m,b)=beta;
 beari(m,b)=int;

%%%%%%%%%%%%%%%%%%%%

 % AFY
 cdfpercent=cdf_StarveTime_AFY(2,:)';
 i=find(cdfpercent>=0.05 & cdfpercent<=0.95);
 y=cdfpercent(i);
 nsize = length(y);

 x=AFY(i);  m = 4;
 w = randsample(nsize,nsize,true);
 [int,beta]=regco2(x(w),y(w));
 bears(m,b)=beta;
 beari(m,b)=int;

%%%%%%%%%%%%

 % AM
 cdfpercent=cdf_StarveTime_AM(2,:)';
 i=find(cdfpercent>=0.05 & cdfpercent<=0.95);
 y=cdfpercent(i);
 nsize = length(y);

 x=AM(i);  m = 5;
 w = randsample(nsize,nsize,true);
 [int,beta]=regco2(x(w),y(w));
 bears(m,b)=beta;
 beari(m,b)=int;

%%%%%%%%%%%%

end

dname={'AFC','AFC_Lact', 'AF', 'AFY', 'AM'}; % demographic name
% comment out so as not to overwrite
save matfiles/Fit_DemographicsvsFD.mat  bears beari dname 

%%%%%%%%%%
