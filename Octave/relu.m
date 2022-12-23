%==========================================================================
%
%   Author: Klaus Niederberger
%   Version: 31.10.2021
%
%==========================================================================
%
% ReLU  Compute ReLU function.
%   J = ReLU(z) computes the ReLU of z.
%  

function g = relu(z)
g = max(0,z);
end
