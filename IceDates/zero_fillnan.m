function x = zero_fillnan ( x ) ;
% function x = zero_fillnan ( x ) ;
%
%  function to replace all NaNs in a vector by ZEROS.
% 
%  See also: SUM2

ix = find(isnan(x)); x(ix) = zeros(size(ix));
