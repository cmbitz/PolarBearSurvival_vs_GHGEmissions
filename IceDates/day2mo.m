function am= day2mo(a);
% DAY2MO finds the monthly mean values for
% a daily time series length of year is 365
%
% a may be a matrix too provided the time dimension is first
% i.e., a(time,space)
% written by Bitz a long time ago

[n m]=size(a);

n=floor(n/365);
a=a(1:(n*365),:);

a=reshape(a,365,n,m);

last_day=[31,59,90,120,151,181,212,243,273,304,334,365];
first_day=[1 (last_day(1:11)+1)];

am=zeros(12,n,m);
for i=1:12
  am(i,:,:)=mean(a(first_day(i):last_day(i),:,:));
end

am=reshape(am,12*n,m);

