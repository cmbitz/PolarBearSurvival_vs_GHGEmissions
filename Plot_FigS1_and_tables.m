% Script to make Supplemental plots of FD vs Cumulative eCO2
% and save parameters for tables

% chose one of generateit 1-4 
generateit=1; % plot individual panels (used for Fig S2b)
generateit=2; % plot 11-panel Fig S1 
generateit=3; % send bootstrap slopes and CIs to cvs file, etc
generateit=4; % send median fits to cvs file, etc

clear
generateit=2;

load matfiles/IFDvsCumCO2_Fit_CombinedUnc.mat   MeanInterval CumCO2 OBSIFD Nyrs yhat
load InputMatfiles/SubpopulationNames.mat

if generateit==1

x = CumCO2;
N=[3:8 14 17:20]; 
N=[4 18];
for n=N

fig=figure(2); clf; 
orient(fig,'portrait');

if (n>16 | n==14)  
 offset=-24;  % FD = IFD+offset
else
 offset=0;
end
plot(x,OBSIFD(n,:)+offset,'.','markersize',20);
hold; plot(x,yhat(n,:)+offset,'r-'); hold
hold; plot(x,squeeze(MeanInterval(n,:,:))+offset,'r:'); hold

set(gca,'TickDir','out');
set(gca,'fontsize',20);
xlim([-20 1800]);

ylims=ylim; ylims(1)=-0.05*ylims(2); ylim(ylims);

xlabel('Cumulative Emissions since 1979 (Gt)');
ylabel('Fasting Duration (days)');
title(econame(n));

all=axis; 
text(all(1)+0.05*(all(2)-all(1)),all(4)-0.07*(all(4)-all(3)),'b','FontWeight','bold','fontsize',22)

filename=['figures/',char(shortname(n)),'_fit_FDvsCumCO2'];
print(filename,'-depsc') 
print(filename,'-dpng','-r300')

end

elseif generateit==2

fig=figure(3); clf; 
orient(fig,'landscape');

x = CumCO2;
i=1
N = [5 6 7 8 10 11 12 13:17 20] % For Supplemental
for n=N
gca=subplot(3,5,i);

if (n>16 | n==14)  
 offset=-24;  % FD = IFD+offset
else
 offset=0;
end
plot(x,OBSIFD(n,:)+offset,'.','markersize',12);
if (n==10 | n==12)
  % no fit for these since too few points
else
   hold; plot(x,yhat(n,:)+offset,'r-'); hold
   hold; plot(x,squeeze(MeanInterval(n,:,:))+offset,'r:'); hold
end
set(gca,'TickDir','out');
set(gca,'fontsize',10);
xlim([-20 1800]);

ylims=ylim; ylims(1)=-0.05*ylims(2);ylim(ylims);

if i==13, hnd=xlabel('Cumulative Emissions since 1979 (Gt)','fontsize',12); end
if i==6, ylabel('Fasting Duration (days)','fontsize',12); end
hnd=title(abbrev_econame{n});
set(hnd,'fontweight','normal','fontsize',12);

if i==10,
 i=i+2;
else
 i=i+1;
end

end

print('figures/Fig1_Supplemental','-dpng','-r300')
print('figures/Fig1_Supplemental','-depsc')


elseif generateit==3

load matfiles/Fit_CumCO2_vs_IFD_v5.mat

% area weights
load InputMatfiles/totalarea.mat
% use 1981-2010 to compute a mean and then get the march mean of total area. This includes the masking out of deep water in Souther Beaufort
clim=totalarea(:,366:(365*31));
clim=squeeze(mean(reshape(clim,20,365,30),3));
march=mean(clim(:,60:90),2);
march

fid=fopen('RegionsinMsqkm.csv','wt')
N=1:20
for n=N, fprintf(fid,'%s, %12.0f \n', econame{n}, march(n)*1e2); end
fclose(fid)

area=march*1e2;

fid=fopen('IFD_vs_CumCO2_slopes_withCIs_table_v5.csv','wt')
for n=1:20, 
  b = bs(n,:)';
  invb = 1./b;
  quants=quantile(invb,[0.025,0.5,0.975]);
  invlow=quants(1); invcent=quants(2); invhigh=quants(3);
  fprintf(fid,'%s, %6d, %4.1f, (%4.1f %4.1f), ',econame{n}, area(n), invcent, invlow, invhigh );
  quants=quantile(b,[0.025,0.5,0.975]);
  low=quants(1); cent=quants(2); high=quants(3);
  fprintf(fid,'%5.4f, (%5.4f %5.4f), ', cent, low, high );
  fprintf(fid,'%6.2f, (%6.2f %6.2f), ', round(area(n)*invcent*1e-6,3,'significant'),...
  round(area(n)*invlow*1e-6,3,'significant'),round(area(n)*invhigh*1e-6,3,'significant'))
  fprintf(fid,'%6.0f, (%6.0f %6.0f) \n', round(area(n)*cent,3,'significant'), ...
  round(area(n)*low,3,'significant'),round(area(n)*high,3,'significant'))
end
fclose(fid)

display('Global Stats')
N = [3 4 5 6 7 8 11 13:20];
tmp=area(N)'*bs(N,:)/sum(area(N));
display([median(tmp) quantile(tmp,0.025) quantile(tmp,0.975)])
display([1/median(tmp) 1/quantile(tmp,0.025) 1/quantile(tmp,0.975)])

display('AK Stats')
N=3:4;
tmp=area(N)'*bs(N,:)/sum(area(N));
display([median(tmp) quantile(tmp,0.025) quantile(tmp,0.975)])
display([1/median(tmp) 1/quantile(tmp,0.025) 1/quantile(tmp,0.975)])


else

yrs=1979:2020;
N=[3:8 11 13:20];

fid=fopen('FD_CumCO2_fits_table_v5.csv','wt')

fprintf(fid,' Year, C, ');
for n=N 
  fprintf(fid,'%s, ', abbrev_econame{n});
end
fprintf(fid,' \n');


i=1;
for yr=yrs
 fprintf(fid,'%s, %4d, ',num2str(yr), round(CumCO2(i)));
for n=N 
if (n>16 | n==14)
 offset=-24;
else
 offset=0
end
  fprintf(fid,'%4.1f, ', yhat(n,i)+offset);
end
fprintf(fid,' \n');
i=i+1
end
fclose(fid)


N=[3:8 10 11 12 13:20];

fid=fopen('IFD_CumCO2_raw_table.csv','wt')

fprintf(fid,' Year, C, ');
for n=N 
  fprintf(fid,'%s, ', abbrev_econame{n});
end
fprintf(fid,' \n');

i=1;
for yr=yrs
 fprintf(fid,'%s, %4d, ',num2str(yr), round(CumCO2(i)));
for n=N 
  fprintf(fid,'%4.1f, ', OBSIFD(n,i));
end
fprintf(fid,' \n');
i=i+1
end
fclose(fid)



end




