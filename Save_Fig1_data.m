% Script to make Figure 1 for main text
% all data are processed elsewhere

clear;

load matfiles/IFDvsCumCO2_Fit_SamplingUnc.mat MeanInterval
NarrowInterval =  MeanInterval; 
load matfiles/IFDvsCumCO2_Fit_CombinedUnc.mat   MeanInterval CumCO2 OBSIFD Nyrs yhat
load InputMatfiles/SubpopulationNames.mat

x=CumCO2;
N=[3:4 18:19]; % choose just the 4 key regions for this plot
letters={'a','b','c','d'};
i=1;
for n=N

if (n>16 | n==14)  
 offset=-24;  % FD = IFD+offset
else
 offset=0;
end

filename=['Fig1_tables/Fig1',letters{i},'_data.csv']
fid=fopen(filename,'wt')
fprintf(fid,'%s \n', 'CumCO2 (on x-axis), blue dots, solid red line, upper dotted red line, lower dotted red line, upper edge of grey patch, lower edge of grey patch ' );

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

for k=1:length(CumCO2)
 fprintf(fid,'%6.2f, ', CumCO2(k) );
 fprintf(fid,'%6.0f, ', OBSIFD(n,k)+offset );
 fprintf(fid,'%6.2f, ', yhat(n,k)+offset );
 fprintf(fid,'%6.2f, ', MeanInterval(n,k,1)+offset );
 fprintf(fid,'%6.2f, ', MeanInterval(n,k,2)+offset );
 fprintf(fid,'%6.2f, ', NarrowInterval(n,k,1)+offset );
 fprintf(fid,'%6.2f ', NarrowInterval(n,k,2)+offset );
 fprintf(fid,'\n');
end

fclose(fid)
i=i+1;
end


load matfiles/DemographicsvsCumCO2_Fit_Unc.mat yhat MeanInterval x

typename={'AFC','AFC Lactating', 'AF', 'AFY', 'AM'};
letters={'e','f','g','h'};
m=2; % for lactating adult females, hence recruitment impacts
i=1;
for n=N

filename=['Fig1_tables/Fig1',letters{i},'_data.csv']
fid=fopen(filename,'wt')
fprintf(fid,'%s \n', 'CumCO2 (on x-axis), solid red line, upper dotted red line, lower dotted red line ');


fig2=figure(1); clf;

   plot(x,squeeze(yhat(n,m,:)),'r-'); 
   hold; plot(x,squeeze(MeanInterval(n,m,:,:)),'r:'); hold
   xlim([-20 1800]);
   hold; plot([-20 1800],[0 0],'k-','linewidth',0.5); hold
   ax2 = fig2.CurrentAxes;
   set(ax2,'fontsize',11)
   set(ax2,'TickDir','out')

for k=1:length(CumCO2)
 fprintf(fid,'%6.2f, ', CumCO2(k) );
 fprintf(fid,'%6.2f, ', yhat(n,m,k) );
 fprintf(fid,'%6.2f, ', MeanInterval(n,m,k,1) );
 fprintf(fid,'%6.2f ', MeanInterval(n,m,k,2) );
 fprintf(fid,'\n');
end

fclose(fid)
i=i+1;
end
