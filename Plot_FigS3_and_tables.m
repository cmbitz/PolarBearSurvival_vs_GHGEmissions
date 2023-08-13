generateit=1; % plot individual panels
generateit=2; % plot 11-panel Fig S3
generateit=3; % WRITE OUT some tables

clear

generateit=2;

typename={'AFC','AFC Lactating', 'AF', 'AFY', 'AM'};
dname={'AFC','Lact_AFC', 'AF', 'AFY', 'AM'};

load matfiles/DemographicsvsCumCO2_Fit_Unc.mat 
load InputMatfiles/SubpopulationNames.mat

if generateit==1

m=2;
for n=[4 18]
clear gca
fig=figure(2); clf;
orient(fig,'portrait');
plot(x,squeeze(yhat(n,m,:)),'r-'); 
hold; plot(x,squeeze(MeanInterval(n,m,:,:)),'r:'); hold
hold; plot([-20 1800],[0 0],'k-','linewidth',0.5); hold

set(gca,'TickDir','out');
set(gca,'fontsize',20);
xlim([-20 1800]);

xlabel('Cumulative Emissions since 1979 (Gt)');
ylabel('Recruitment Failure (%)');
%title([econame{n},' - ',longtypename{m}])

all=axis; 
text(all(1)+0.05*(all(2)-all(1)),all(4)-0.07*(all(4)-all(3)),'c','FontWeight','bold','fontsize',22)

% one of these was used in FigS2c
filename=['figures/',char(shortname(n)),'_',char(dname(m)),'_DemogvsCumCO2_v5'];
print(filename,'-dpng','-r300')
print(filename,'-depsc')

end

elseif generateit==2

fig=figure(3); clf; 
orient(fig,'landscape');

m=2;
i=1;
N = [5 6 7 8    11 13:17 20] % For Supplemental
for n=N
gca=subplot(3,4,i);

plot(x,squeeze(yhat(n,m,:)),'r-'); 
hold; plot(x,squeeze(MeanInterval(n,m,:,:)),'r:'); hold
set(gca,'TickDir','out');
set(gca,'fontsize',11);
xlim([-20 1800]);
hold; plot([-20 1800],[0 0],'k-','linewidth',0.5); hold

if i==10, hnd=xlabel('Cumulative Emissions since 1979 (Gt)','fontsize',12); end
if i==5, ylabel('Recruitment Failure (%)','fontsize',12); end
hnd=title(abbrev_econame{n});
set(hnd,'fontweight','normal','fontsize',12);

i=i+1;

end

for i=11:-1:9
  gca=subplot(3,4,i);
  P=get(gca,'Position');
  P(1)=P(1)+0.1;
  set(gca,'Position',P);
end

print('figures/Fig3_Supplemental','-dpng','-r300')
print('figures/Fig3_Supplemental','-depsc')

else

% area weights
load InputMatfiles/totalarea.mat
% use 1981-2010 to compute a mean and then get the march mean of total area. This includes the masking out of deep water in Souther Beaufort
clim=totalarea(:,366:(365*31));
clim=squeeze(mean(reshape(clim,20,365,30),3));
%clf;plot(clim')
march=mean(clim(:,60:90),2);
area=march*1e2;

load matfiles/Fit_DemographicsvsCumCO2.mat

fid=fopen('Recruitment_Failure_vs_CumCO2.csv','wt');
fprintf(fid,'%s \n','Type, Region, center, (low high) in percent change per Gt eCO2');
d=2
for n=[3:4 5:8 11 13:20]
  b = phi1(n,d,:); b = b(:);
  quants=quantile(b*100,[0.025,0.5,0.975]);
  low=quants(1); cent=quants(2); high=quants(3);
  fprintf(fid,'%s, %s, %6.4f, (%6.4f %6.4f), ',char(dname(d)),char(econame(n)),round(cent,3,'significant'),round(low,3,'significant'),round(high,3,'significant'));
  fprintf(fid,'%6.2f, (%6.2f %6.2f), ',1/cent,1/high,1/low);
  fprintf(fid,'%6.0f (%6.0f %6.0f) \n', round(area(n)*cent,3,'significant'), ...
    round(area(n)*low,3,'significant'),round(area(n)*high,3,'significant'))
end
fclose(fid);


display('Global Stats')
N = [3 4 5 6 7 8 11 13:20];
tmp=100*area(N)'*squeeze(phi1(N,d,:));
display([median(tmp) quantile(tmp,0.025) quantile(tmp,0.975)])

display('AK Stats')
N=3:4;
tmp=100*area(N)'*squeeze(phi1(N,d,:));
display([median(tmp) quantile(tmp,0.025) quantile(tmp,0.975)])


display('Global Stats')
N = [3 4 5 6 7 8 11 13:20];
tmp=100*area(N)'*squeeze(phi1(N,d,:))/sum(area(N));
display([median(tmp) quantile(tmp,0.025) quantile(tmp,0.975)])

display('AK Stats')
N=3:4;
tmp=100*area(N)'*squeeze(phi1(N,d,:))/sum(area(N));
display([median(tmp) quantile(tmp,0.025) quantile(tmp,0.975)])


end
