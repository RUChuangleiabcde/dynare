% Copyright (C) 2001 Michel Juillard
%
% Fast hpfiltering:
%
% [c,t]=hpfast(y,lambda)
%
% Inputs:
%
% y: 			vector (nx1) containing the series you wish to filter
% lambda:	smoothing parameter (default: quarterly 1600)
%
% Outputs:
% 
% c:			Cyclical component (deviations from trend)
%	t:			Trend component
%
function [d,t]=hpfast(y,s)
if nargin<2;
  s = 1600;
end;
iopt 	= 0;
y			= y(:);
n 		= length(y);
d1		= zeros(n,1);
t			= zeros(n,1);

v = zeros(3*n,6);
if iopt ~= 1,
  ss=s;
  nn=n;
  v11=1;
  v22=1;
  v12=0;
  for i=3:n;
    x=v11;
    z=v12;
    v11=1/s + 4*(x-z) + v22;
    v12=2*x - z;
    v22=x;
    det1=v11*v22-v12*v12;
    v(i,1)=v22/det1;
    v(i,3)=v11/det1;
    v(i,2)=-v12/det1;
    x=v11+1;
    z=v11;
    v11=v11-v11*v11/x;
    v22=v22-v12*v12/x;
    v12=v12-z*v12/x;
  end;
end;
%
%  Forward pass 
%
m1=y(2);
m2=y(1);
for i=3:n;
  x=m1;
  m1=2*m1-m2;
  m2=x;
  t(i-1,1)= v(i,1)*m1 + v(i,2)*m2;
  d1(i-1,1)=v(i,2)*m1+v(i,3)*m2;
  det1=v(i,1)*v(i,3)-v(i,2)*v(i,2);
  v11=v(i,3)/det1;
  v12=-v(i,2)/det1;
  z=(y(i)-m1)/(v11+1);
  m1=m1+v11*z;
  m2=m2+v12*z;
end
t(n,1)=m1;
t(n-1,1)=m2;
%
% Backward pass
%
m1=y(n-1);
m2=y(n);
for i=n-2:-1:1;
  i1=i+1;
  ib=n-i+1;
  x=m1;
  m1=2*m1 - m2;
  m2=x;
%
% Combine info for y(.lt.i) with info for y(.ge.i)
%
  if i > 2;
    e1=v(ib,3)*m2+v(ib,2)*m1+t(i,1);
    e2=v(ib,2)*m2+v(ib,1)*m1+d1(i,1);
    b11=v(ib,3)+v(i1,1);
    b12=v(ib,2)+v(i1,2);
    b22=v(ib,1)+v(i1,3);
    det1=b11*b22-b12*b12;
    t(i,1)=(-b12*e1+b11*e2)/det1;
  end
%
% End of combining
%
	det1=v(ib,1)*v(ib,3)-v(ib,2)*v(ib,2);
	v11=v(ib,3)/det1;
  v12=-v(ib,2)/det1;
  z=(y(i)-m1)/(v11+1);
  m1=m1+v11*z;
  m2=m2+v12*z;
end
t(1,1)=m1;
t(2,1)=m2;
d=y-t;
