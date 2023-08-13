% NASA Team algorithm for concentration is processed to 
% compute ice present in each pixel for conc > a threshold
% for the 20 subpopulations
% Here computed for a range of thresholds from 10, 20, 30, ... 90
% Also masks out all ocean deeper than 300 m in the S. Beaufort only
%
% Takes up to an hour to run depending on your computer
%
% First must download the NASA Team data. NSIDC has moved it around, changed
% versions and download protocols over the years. Results
% in Amstrup and Bitz (2023) were computed from v1.1
% Those data are no longer available so this script
% uses v2.0, which gave identical results

version = 'v2_0'; % or 'v1_1' though results are identical

% put files from NSIDC for all years in one directory
local_archive = '/home/disk/sipn/nicway/data/obs/NSIDC_0051/native/'

MAXYEAR=2020; % the last year to process that is available in your local archive

readrawdata=0;  % set to 0 if you've run before and just want to make a figure
                % set to 1 if you need to process the raw data

if readrawdata  % read in the sea ice data one year at a time and process it

NX=304; NY=448;  % the grid has 304 columns x 448 rows

% NASA grid cell area, get this from NSIDC (not provided here)
fid=fopen('/home/disk/eos11/bitz/observations/seaice/daily_nt/psn25area_v3.dat','r'); 
tarea=fread(fid,inf,'int32')*1e-5;  % convert to sq m
tarea=reshape(tarea,NX,NY);

load populationmask.mat % contains indexes for 20 subpopulations
                        % on NASA sea ice grid

load IBCAO_ETOPO1_combined_bathy_NASAgrid.mat % ocean bathymetry
              % regridded to the nasa seaice grid
              % in meters lat,lon,znasa<0 on ocn
% change so ocn depth is positive and land is zero
znasa(isnan(znasa))=0;  znasa(znasa>0)=0; znasa=-znasa(:);

deepSBmask=ones(304,448);                      % create a new mask
deepSBmask(find(znasa>300 & popmask(:)==3))=0; % 1 everywhere but deep S Beaufort Sea
save SBdeepmask.mat deepSBmask

last_day=[31,59,90,120,151,181,212,243,273,304,334,365];
first_day=[1 (last_day(1:11)+1)];
daysinmo=last_day-first_day+1;
disp('Warning: ignoring leap days');

for year=1979:MAXYEAR
  a=NaN*ones(365,NX*NY);
  count=1;
  ystr=num2str(year)
  for mo=1:12
    mostr=num2str(mo,'%02d')
    for day=1:daysinmo(mo)
      daystr=num2str(day,'%02d');

      if version == 'v2_0'
         [stat,name]=system(['ls ',local_archive,...
          'NSIDC0051_SEAICE_PS_N25km_',num2str(year),mostr,daystr,'_v2.0.nc']); 
                   % NSIDC0051_SEAICE_PS_N25km_20000906_v2.0.nc  is an example of the filename
      else
        [stat,name]=system(['ls /home/disk/sipn/nicway/data/obs/NSIDC_0051/native',...
              '/nt_',num2str(year),mostr,daystr,'_*_v1.1_n.bin']);
                  % nt_20171119_f18_nrt_n.bin  is an example of the data
      end						  
      if (stat==0),
        filename=name(1:end-1);
        if version == 'v2_0'
          fileinfo=ncinfo(filename);
  	  if length(fileinfo.Variables) > 4     % v2.0 has files even when they contain no data, sigh
     	    varname=fileinfo.Variables(5).Name; % ice conc variable name differs among files, sigh
            tmp=ncread(filename,varname);
            a(count,:)=tmp(:)*100; % a is one years worth of concentration data ranging from 0 to 100%
	  else
            disp(['missing data on ',num2str(year),mostr,daystr])
	  end
	else
          fid=fopen(name(1:end-1),'r','ieee-le');
	  fread(fid,300,'uint8=>char')'; % header
	  a(count,:)=fread(fid,inf,'*uint8')';
	  fclose(fid);
 	  a(count,:)=a(count,:)/2.5;
	end
      else
        disp(['missing data on ',num2str(year),mostr,daystr])
      end
      count=count+1;
    end
  end

if (year==1979) % find the polehole in 1979 and use it for all years for consistency
  ipolepoints=find(a(2,:)>100.2 & a(2,:)<101); 
end

a(a>100)=NaN; % a is the concentration
a(:,ipolepoints)=NaN; % blot out pole hole from 1979

% compute ice present field in e where e10=[0,1] based on conc>10%
for extfrac=10:10:90
  tmp=a;
  tmp(find(a<extfrac))=0;
  tmp(find(a>=extfrac))=1;
  eval(['e',num2str(extfrac),'=tmp;'])
end

plotfig=1; % set to one for sanity check figure
if (plotfig==1)
   bb=1e3*[-3.8375,-5.3375 
            3.7375, 5.8375];
  [YY,XX]=meshgrid([bb(1,2):((bb(2,2)-bb(1,2))/447):bb(2,2)],...
        [bb(1,1):((bb(2,1)-bb(1,1))/303):bb(2,1)]);
  YY=fliplr(YY);
  subplot(221)
  pcolor(XX,YY,reshape(nanmean(a),NX,NY)); shading flat; colorbar
  set(gca,'xtick',[],'ytick',[]);
  subplot(222)
  pcolor(XX,YY,reshape(nanmean(e50),NX,NY)); shading flat; colorbar
  set(gca,'xtick',[],'ytick',[]);
  subplot(223)
  pcolor(XX,YY,reshape(a(2,:),NX,NY)); shading flat; colorbar
  set(gca,'xtick',[],'ytick',[]);
  subplot(224)
  pcolor(XX,YY,reshape(e50(2,:),NX,NY)); shading flat; colorbar
  set(gca,'xtick',[],'ytick',[]);
  pause(2)
end

% get rid of nans and replace with zero
dayswithdata=find(nansum(a')>0);
a(dayswithdata,:)=zero_fillnan(a(dayswithdata,:));
for extfrac=10:10:90
  thrsh=num2str(extfrac);
  eval(['e',thrsh,'(dayswithdata,:)=zero_fillnan(e',thrsh,'(dayswithdata,:));']);
end

% mask the S Beaufort Sea region, area weight (NASA grid cell supposedly 25kmx25km
% are not exactly each the same size), and sum by subpop region
for n=1:20 % loop over subpopulations
 k=find(popmask==n);
 wgts=tarea(k).*deepSBmask(k); % removes deep sea in BS region only
 bathXwgts=tarea(k); % NO BATH WTING 
 concbyregion(n,year-1978,:)=a(:,k)*wgts(:)/100;
 rsfbyregion(n,year-1978,:)=a(:,k)*bathXwgts(:)/100;
 for extfrac=10:10:90  % FINALLY place the year in a single variable for further use
   thrsh=num2str(extfrac);
   eval(['ext',thrsh,'byregion(n,year-1978,:)=e',thrsh,'(:,k)*wgts(:);']);
 end
end

end % loop over years


% the early years had missing data every other day
% that must be filled in with fixgaps
for extfrac=10:10:90
  thrsh=num2str(extfrac);
  eval(['tmp=ext',thrsh,'byregion;']);
  tmp=permute(tmp,[3 2 1]);  n=size(tmp);
  tmp=reshape(tmp,n(1)*n(2),n(3))';
  total=tmp;
  for n=1:20
    total(n,:)=fixgaps(tmp(n,:));
  end
  total(n,1)= total(n,2); % fix first point
  eval(['totalext',thrsh,'area=total;'])
end

tmp=permute(concbyregion,[3 2 1]); n=size(tmp);
tmp=reshape(tmp,n(1)*n(2),n(3))';
totalarea=tmp;
for n=1:20
 totalarea(n,:)=fixgaps(tmp(n,:));
end
totalarea(n,1)= totalarea(n,2); % fix first point

tmp=permute(rsfbyregion,[3 2 1]); n=size(tmp);
tmp=reshape(tmp,n(1)*n(2),n(3))';
totalrsfarea=tmp;
for n=1:20
 totalrsfarea(n,:)=fixgaps(tmp(n,:));
end
totalrsfarea(n,1)= totalrsfarea(n,2); % fix first point
plot(totalrsfarea')

yrs=1979:MAXYEAR
eval(['save populationregions300mSBFtimeseries1979to',num2str(MAXYEAR),'_nt_',version,' totalarea totalrsfarea totalext* *byregion yrs'])

else   % option below skips processing and visualizes the data, good for further sanity check

% just plot the data and have a look at some regions
% not used for production figures

eval(['load populationregions300mSBFtimeseries1979to',num2str(MAXYEAR),'_nt_',version,'.mat']);
load SubpopulationNames.mat
Nyrs=length(yrs);
last_day=[31,59,90,120,151,181,212,243,273,304,334,365];
first_day=[1 (last_day(1:11)+1)];
months; monthL={'Jan';'';'';'';'';'Jun';'';'';'';'';'';'Dec'};
scaleit=1e-3; plotthis = totalext30area;
count=1; clf; clrs=jet;
for n=[2 4:8 14 18 20]
  subplot(3,3,count) ; count=count+1;
  if n==2
    tmp=squeeze(reshape(plotthis(n,:)+plotthis(n+1,:),365,Nyrs)')*scaleit;
  elseif n==18
    tmp=squeeze(reshape(plotthis(n,:)+plotthis(n+1,:),365,Nyrs)')*scaleit;
  else
    tmp=squeeze(reshape(plotthis(n,:),365,Nyrs)')*scaleit;
  end
  hold on
  for theyr=1:length(yrs)
    plot(tmp(theyr,:),'color',clrs(theyr,:)); 
  end
  set(gca,'xtick',first_day,'xticklabel',monthL); xlim([0 365])  
  ylo=min(tmp(:)); yhi=ylo+(max(tmp(:))-ylo)*1.05;
  ylim([ylo yhi])
  if n==2, title('Beaufort Sea'); elseif n==18, title('Hudson Bay');
  else, title(econame(n)); end
  box on
end

orient landscape


end

