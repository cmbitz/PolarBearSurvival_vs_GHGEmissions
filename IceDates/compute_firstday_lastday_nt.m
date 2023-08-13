% Compute first and last day of ice free season
% option to require the threshold to be maintained at least 3 days out of 5
% makes figures for sanity checks

clear
requirepersistence=1; % require the threshold 
MAXYEAR=2020; % note must be at least 1989 

version='v2_0';
eval(['load populationregions300mSBFtimeseries1979to',num2str(MAXYEAR),'_nt_',version,'.mat']);
load SubpopulationNames.mat

Nyrs=length(yrs);

skip=0;
if ~(skip)
% indexes are extent criterion, area threshold, region#, year
firstday=zeros(9,9,20,Nyrs); % first ice-free day
lastday=zeros(9,9,20,Nyrs);  % last ice-free day

firstdayamnt=firstday; % get the extent on these days for plotting
lastdayamnt=lastday;

% first compute the critical extent threshold
for extfact=1:9 
    eval(['totalext(extfact,:,:)=totalext',num2str(10*extfact),'area;']);
    tmp=day2mo(squeeze(totalext(extfact,:,:))')';
    marchext=mean(tmp(:,3:12:120),2); % avg march extent decade one
  for areafact=1:10 
     extentref(extfact,areafact,:)=areafact/10*marchext;
  end
end

%yrs=1979:MAXYEAR; Nyrs=length(yrs);
%j=length(totalext)+(1:365);
%for extfact=1:9
%    eval(['totalext(extfact,:,j)=totalext',num2str(10*extfact),'area(:,j);']);
%end

for n=2:20

 for extfact = 1:9;  

  tmp=squeeze(reshape(totalext(extfact,n,:),365,Nyrs)');
  tmp=[tmp; tmp(Nyrs,:)]; % duplicate last year on purpose

 for areafact=1:9
% search for the first and last days of the IF season
  for yr=1:Nyrs 
    j=find(tmp(yr,90:260)<(extentref(extfact,areafact,n)));
    if length(j)>2 
      % first time when there are 3 sequential days below 
      while (requirepersistence & mean(j(1:3))>(j(1)+1) & length(j)>3), j=j(2:end); end
      firstday(extfact,areafact,n,yr)=89+j(1);
    else,
      % there is no time when drop below extentref
      firstday(extfact,areafact,n,yr)=260;
    end
    firstdayamnt(extfact,areafact,n,yr)=tmp(yr,firstday(extfact,areafact,n,yr));

    if   yr==Nyrs           %sum(isnan(tmp(yr,360:365)))>1 % more than one missing day in the last five days of year, so don't wrap
       %if extfact==3 & areafact==3,     [yr, n], end
        wrapit=tmp(yr,250:365); % no wrapping on last year
    else
         wrapit=[tmp(yr,250:365) tmp(yr+1,1:100)]; % search into the first
  				% 100 days of the next year too
    end
    j=find(wrapit>(extentref(extfact,areafact,n)));
    if length(j)>2, 
      % first time when there are 3 sequential days above
      while (requirepersistence & mean(j(1:3))>(j(1)+1) & length(j)>3), j=j(2:end); end
      lastday(extfact,areafact,n,yr)=j(1);
      lastdayamnt(extfact,areafact,n,yr)=wrapit(lastday(extfact,areafact,n,yr));
      lastday(extfact,areafact,n,yr)=lastday(extfact,areafact,n,yr)+249;
     else, 
      % there is no time when rise above extentref
      lastday(extfact,areafact,n,yr)=NaN;
      lastdayamnt(extfact,areafact,n,yr)=NaN;
    end

 end % loop over years
 end % loop over areafact
 end % loop over extfact
end % loop over n (regions)

if requirepersistence
  eval(['save firstday_lastday_nt_3day_1979to',num2str(MAXYEAR),' totalext extentref first* last*  requirepersistence']);
else
 eval(['save firstday_lastday_nt_1day_1979to',num2str(MAXYEAR),' totalext extentref first* last*  requirepersistence']);
end

OBSIFD=squeeze(lastday(3,3,:,:)-firstday(3,3,:,:));
OBSIFD(OBSIFD<0)=0;
OBSyrs=yrs;
save obsIFD.mat OBS*

fid=fopen('IFDbyregion.csv','wt')

fprintf(fid,'Year ')
for n=1:20
  fprintf(fid,' %s, ',econame{n})
end
fprintf(fid,'\n')

for tme = 1:length(OBSyrs)
 fprintf(fid,'%4d, ',OBSyrs(tme))
 for n=1:20
   fprintf(fid,' %4.1f, ',OBSIFD(n,tme))
 end
 fprintf(fid,'\n')
end

fclose(fid)




end
% make figures for sanity check

extfact = 3;  % make an example of these
areafact = 3;
scaleit=1e-3;
n=19;
tmp=squeeze(reshape(totalext(extfact,n,:),365,Nyrs)')*scaleit;

figure(1); clf
  plot(tmp','color',[1 1 1]*0.7); hold on
  plot(1:365,mean(tmp(1:10,:)),'b');
  plot(1:365,mean(tmp(11:20,:)),'g');
  plot(1:365,mean(tmp(21:30,:)),'y'); 
  plot(1:365,nanmean(tmp(31:40,:)),'r');
  plot(1:365,(tmp(33,:)),'c');
  plot(1:365,(tmp(Nyrs,:)),'k'); hold off
  hold; plot([0 365],[1 1]*squeeze(extentref(extfact,10,n))*scaleit,'k-','linewidth',3); hold;
  hold; plot([0 365],[1 1]*squeeze(extentref(extfact,areafact,n))*scaleit,'k-'); hold

  ylo=min(tmp(:)); yhi=ylo+(max(tmp(:))-ylo)*1.05;
  ylim([ylo yhi])
  title(shortname{n});
  orient portrait

hold; plot(squeeze(firstday(extfact,areafact,n,:)),...
          scaleit*squeeze(firstdayamnt(extfact,areafact,n,:)),'ms');hold
hold; plot(squeeze(lastday(extfact,areafact,n,:)),...
          scaleit*squeeze(lastdayamnt(extfact,areafact,n,:)),'cs');hold
hold; plot(squeeze(lastday(extfact,areafact,n,:))-365,...
          scaleit*squeeze(lastdayamnt(extfact,areafact,n,:)),'cs');hold
xlim([0 365]); set(gca,'fontsize',24)
xlabel('Day of Year'); ylabel('Extent - 10^5 km^2')

clrs=jet(Nyrs-29);
figure(3); clf
  plot(tmp','color',[1 1 1]*0.7); hold on
  for j=1:(Nyrs-29)
    plot(1:365,tmp(28+j,:),'color',clrs(j,:));
    text(250,1.8-j*.1,num2str(2006+j),'color',clrs(j,:));
  end
  j=Nyrs-28;
  plot(1:365,(tmp(Nyrs,:)),'k','linewidth',2);
  text(250,1.8-j*.1,num2str(2006+j));
  plot([0 365],[1 1]*squeeze(extentref(extfact,10,n))*scaleit,'k-',...
   'linewidth',3); 
  plot([0 365],[1 1]*squeeze(extentref(extfact,areafact,n))*scaleit,'k--'); 
  hold off
  title(shortname{n})
  orient portrait
xlim([90 365]); set(gca,'fontsize',24)
xlabel('Day of Year'); ylabel('Extent - 10^5 km^2')
eval(['print ',shortname{n},'_seasonalcycle_',num2str(MAXYEAR),' -depsc'])

n=19;

normaliz=squeeze(extentref(extfact,10,n))*scaleit;
figure(4); clf
  plot(tmp'/normaliz,'color',[1 1 1]*0.7); hold on
  for j=1:(Nyrs-29)
    plot(1:365,tmp(28+j,:)/normaliz,'color',clrs(j,:));
    text(250,(1.8-j*.1)/normaliz,num2str(2006+j),'color',clrs(j,:));
  end
  j=Nyrs-28;
  plot(1:365,(tmp(Nyrs,:))/normaliz,'k','linewidth',2);
  text(250,(1.8-j*.1)/normaliz,num2str(2006+j));
  plot([0 365],[1 1],'k-',...
   'linewidth',3); 
  plot([0 365],[1 1]*squeeze(extentref(extfact,areafact,n))*scaleit/normaliz,'k--'); 
  hold off
  title(shortname(n)); 
  orient portrait
xlim([90 365]); set(gca,'fontsize',24)
xlabel('Day of Year'); ylabel('Fractional Coverage')
ylim([0 1.15])
eval(['print WH_seasonalcycle_',num2str(MAXYEAR),'_fraction -depsc'])

