function [pc,d,u,v,perc] = funpsy_princomp(ts);

% extract 1st principal component using matlab's SVD
% returns also the percentage of variance explained by each component

[m n]   = size(ts);
if m > n
    [v s v] = svd(ts'*ts);
    s = diag(s);
    v = v(:,1);
    u = ts*v/sqrt(s(1));
else
    [u s u] = svd(ts*ts');
    s       = diag(s);
    u       = u(:,1);
    v       = ts'*u/sqrt(s(1));
end
d  = sign(sum(v));
u  = u*d;
v  = v*d;
pc = u*sqrt(s(1)/n);
perc=cumsum(s)/sum(s);


