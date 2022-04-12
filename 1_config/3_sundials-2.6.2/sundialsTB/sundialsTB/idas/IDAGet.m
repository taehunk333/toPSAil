function [output, status] = IDAGet(key, varargin)
%IDAGet extracts data from the IDAS solver memory.
%
%   Usage: RET = IDAGet ( KEY [, P1 [, P2] ... ]) 
%
%   IDAGet returns internal IDAS information based on KEY. For some values
%   of KEY, additional arguments may be required and/or more than one output is
%   returned.
%
%   KEY is a string and should be one of:
%    o DerivSolution - Returns a vector containing the K-th order derivative
%       of the solution at time T. The time T and order K must be passed through 
%       the input arguments P1 and P2, respectively:
%       DKY = IDAGet('DerivSolution', T, K)
%    o ErrorWeights - Returns a vector containing the current error weights.
%       EWT = IDAGet('ErrorWeights')
%    o CheckPointsInfo - Returns an array of structures with check point information.
%       CK = IDAGet('CheckPointInfo)

% Radu Serban <radu@llnl.gov>
% LLNS Copyright Start
% Copyright (c) 2014, Lawrence Livermore National Security
% This work was performed under the auspices of the U.S. Department 
% of Energy by Lawrence Livermore National Laboratory in part under 
% Contract W-7405-Eng-48 and in part under Contract DE-AC52-07NA27344.
% Produced at the Lawrence Livermore National Laboratory.
% All rights reserved.
% For details, see the LICENSE file.
% LLNS Copyright End
% $Revision: 4075 $Date: 2007/08/21 17:38:42 $

mode = 32;

if strcmp(key, 'DerivSolution')
  t = varargin{1};
  k = varargin{2};
  [output, status] = idm(mode,1,t,k);
elseif strcmp(key, 'ErrorWeights')
  [output, status] = idm(mode,2);
elseif strcmp(key, 'CheckPointsInfo')
  [output, status] = idm(mode,4);
else
  error('IDAGet:: Unrecognized key');
end