function [post_mean, min_interval] = posterior_moments(x2)
% computes mean and minimum interval from posterior draws generated by metropolis.m
  global options_
  
  n = size(x2,1);
  np = size(x2,2);
  
  post_mean = mean(x2(1:end,:))';
  
  n1 = round((1-options_.mh_conf_sig)*n);
  k = zeros(n1,1);
  for i = 1:np
    x3 = sort(x2(1:end,i));
  
    j2 = n-n1;
    for j1 = 1:n1
      k(j1) = x3(j2)-x3(j1);
      j2 = j2 + 1;
    end
    
    [kmin,k1] = min(k);
    
    min_interval(i,:) = [x3(k1) x3(k1)+kmin];
  end
  