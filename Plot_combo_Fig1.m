% Script to make Figure 1 for main text
% all data are processed elsewhere

clear;
individuals=0; % set to one to save each panel separately

load matfiles/IFDvsCumCO2_Fit_SamplingUnc.mat MeanInterval
NarrowInterval =  MeanInterval; 
load matfiles/IFDvsCumCO2_Fit_CombinedUnc.mat   MeanInterval CumCO2 OBSIFD Nyrs yhat
load InputMatfiles/SubpopulationNames.mat

fig=figure(4); clf; 
orient(fig,'landscape');

x=CumCO2;
i=1;
N=[3:4 18:19]; % choose just the 4 key regions for this plot
for n=N
figure(4)
gca=subplot(2,4,i)

if (n>16 | n==14)  
 offset=-24;  % FD = IFD+offset
else
 offset=0;
end

phnd=patch('XData',[x; x(Nyrs:-1:1)],...
  'Ydata',[squeeze(NarrowInterval(n,:,1)) squeeze(NarrowInterval(n,Nyrs:-1:1,2))]+offset);
set(phnd,'FaceColor',[1,1,1]*0.7); set(phnd,'EdgeColor',[1,1,1]*0.7)

hold; plot(x,OBSIFD(n,:)+offset,'.','markersize',12); hold
hold; plot(x,yhat(n,:)+offset,'r-'); hold
hold; plot(x,squeeze(MeanInterval(n,:,:))+offset,'r:'); hold

set(gca,'TickDir','out');
set(gca,'fontsize',11);
xlim([-20 1800]);
ylim([-0.05*150 150]);

if i==1, hnd2=ylabel('Fasting Duration (days)','fontsize',11); end
hnd=title(abbrev_econame{n});
set(hnd,'FontWeight','normal','fontsize',11)

all=axis; letters={'a','b','c','d'};
text(all(1)+0.05*(all(2)-all(1)),all(4)-0.07*(all(4)-all(3)),letters{i},'FontWeight','bold')
set(gca,'TickDir','out', 'box','on')


if individuals==1,
   fig2=figure(1); clf;

phnd=patch('XData',[x; x(Nyrs:-1:1)],...
  'Ydata',[squeeze(NarrowInterval(n,:,1)) squeeze(NarrowInterval(n,Nyrs:-1:1,2))]+offset);
set(phnd,'FaceColor',[1,1,1]*0.7); set(phnd,'EdgeColor',[1,1,1]*0.7)

hold; plot(x,OBSIFD(n,:)+offset,'.','markersize',12); hold
hold; plot(x,yhat(n,:)+offset,'r-'); hold
hold; plot(x,squeeze(MeanInterval(n,:,:))+offset,'r:'); hold

   ax2 = fig2.CurrentAxes;
   set(ax2,'fontsize',11);
   xlim([-20 1800]);
   ylim([-0.05*150 150]);
   set(ax2,'TickDir','out');
   set(ax2,'box','on');

   print(['figures/Fig1_combo_',letters{i}],'-depsc')
end

i=i+1;

end

load matfiles/DemographicsvsCumCO2_Fit_Unc.mat yhat MeanInterval x

typename={'AFC','AFC Lactating', 'AF', 'AFY', 'AM'};
m=2; % for lactating adult females, hence recruitment impacts
i=1;
N=[3:4 18:19];
for n=N
figure(4)
gca=subplot(2,4,i+4);

plot(x,squeeze(yhat(n,m,:)),'r-'); 
hold; plot(x,squeeze(MeanInterval(n,m,:,:)),'r:'); hold
set(gca,'TickDir','out');
set(gca,'fontsize',11);
xlim([-20 1800]);
hold; plot([-20 1800],[0 0],'k-','linewidth',0.5); hold


if i==3, hnd1=xlabel('Cumulative Emissions since 1979 (Gt)','fontsize',12); end
if i==1, hnd2=ylabel('Recruitment Failure (%)','fontsize',11); end

all=axis; letters={'e','f','g','h'};
text(all(1)+0.05*(all(2)-all(1)),all(4)-0.07*(all(4)-all(3)),letters{i},'FontWeight','bold')

if individuals==1,
   fig2=figure(1); clf;

   plot(x,squeeze(yhat(n,m,:)),'r-'); 
   hold; plot(x,squeeze(MeanInterval(n,m,:,:)),'r:'); hold
   xlim([-20 1800]);
   hold; plot([-20 1800],[0 0],'k-','linewidth',0.5); hold
   ax2 = fig2.CurrentAxes;
   set(ax2,'fontsize',11)
   set(ax2,'TickDir','out')

   print(['figures/Fig1_combo_',letters{i}],'-depsc')
end

i=i+1;

end
set(hnd1,'position',[-200,-60,-1])


figure(4)
print('figures/Fig1_combo','-depsc')
print('figures/Fig1_combo','-dpng','-r300')

