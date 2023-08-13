function [a,b]=regco2(x,y);

% Compute the mean of your data
yhat = mean(y); y=y(:);
xhat = mean(x); x=x(:);
% Compute regression coefficients in the least-square sense
b = (x' - xhat)*(y - yhat)/sum((x - xhat).^2); % Regression coefficient
a = yhat - b*xhat;                             % Y-intercept
