clear

load ../Molnar/Fig2.mat  % raw data from Molnar et al 2020
                         % available by request from Peter Molnar 
load matfiles/DemographicsvsFD_Fit_Unc.mat % fit and CIs, only for lactating females

% these are the types of bear demographics considered in Molnar et al 2020
typename={'AFC','AFC Lactating', 'AF', 'AFY', 'AM'};
longtypename={'AFC','Lactating Females with Cubs', 'AF', 'AFY', 'AM'};
dname={'AFC','AFC_Lact', 'AF', 'AFY', 'AM'}; % demographic name

m=2; % here we only use the 2nd one

fig=figure(4); clf; orient(fig,'portrait');

eval(['xy=cdf_StarveTime_',dname{m},';']) % data from the demographics model of Molnar et al
x=xy(1,:);  % this is the Fasting Duration
plot(x,xy(2,:)*100,'.','markersize',20)
hold;plot(x,yhat,'r-'); hold
hold; plot(x,MeanInterval,'r:'); hold
set(gca,'TickDir','out');
set(gca,'fontsize',20);
ylim([0,105]);

xlabel('Fasting Duration (days)')
ylabel('Recruitment Failure (%)')

title(longtypename{m})

all=axis; 
ht=text(all(1)+0.05*(all(2)-all(1)),all(4)-0.07*(all(4)-all(3)),'a','FontWeight','bold','fontsize',22);

filename='figures/Fig2Sa';
print(filename,'-dpng','-r300')
print(filename,'-depsc')


