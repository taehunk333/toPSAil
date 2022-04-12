function status = IDASetB(idxB, varargin)
%IDASetB changes optional input values during the integration.
%
%   Usage: IDASetB( IDXB, 'NAME1',VALUE1,'NAME2',VALUE2,... )
%
%   IDASetB can be used to change some of the optional inputs for
%   the backward problem identified by IDXB during the backward
%   integration, i.e., without need for a solver reinitialization.
%   The property names accepted by IDASet are a subset of those valid
%   for IDASetOptions. Any unspecified properties are left unchanged.
%   
%   IDASetB with no input arguments displays all property names.
%
%IDASetB properties
%(See also the IDAS User Guide)
%
%UserData - problem data passed unmodified to all user functions.
%  Set VALUE to be the new user data.  
%RelTol - Relative tolerance
%  Set VALUE to the new relative tolerance
%AbsTol - absolute tolerance
%  Set VALUE to be either the new scalar absolute tolerance or
%  a vector of absolute tolerances, one for each solution component.

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
% $Revision: 4075 $Date: 2007/08/21 17:38:43 $

if (nargin == 0)
  fprintf('        UserData\n');
  fprintf('\n');
  fprintf('          RelTol\n');
  fprintf('          AbsTol\n');
  fprintf('\n');
  return;
end

KeyNames = {
    'UserData'
    'RelTol'
    'AbsTol'
           };

options = idm_options(KeyNames,varargin{:});

mode = 34;

status = idm(mode, idxB, options);
