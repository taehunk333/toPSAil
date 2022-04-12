%CVSensRhsFn - type for user provided sensitivity RHS function.
%
%   The function ODESFUN must be defined as 
%        FUNCTION [YSD, FLAG] = ODESFUN(T,Y,YD,YS)
%   and must return a matrix YSD corresponding to fS(t,y,yS).
%   If a user data structure DATA was specified in CVodeInit, then
%   ODESFUN must be defined as
%        FUNCTION [YSD, FLAG, NEW_DATA] = ODESFUN(T,Y,YD,YS,DATA)
%   If the local modifications to the user data structure are needed in
%   other user-provided functions then, besides setting the matrix YSD,
%   the ODESFUN function must also set NEW_DATA. Otherwise, it should
%   set NEW_DATA=[] (do not set NEW_DATA = DATA as it would lead to 
%   unnecessary copying).
%
%   The function ODESFUN must set FLAG=0 if successful, FLAG<0 if an
%   unrecoverable failure occurred, or FLAG>0 if a recoverable error
%   occurred.
%
%   See also CVodeSetFSAOptions
%
%   NOTE: ODESFUN is specified through the property FSARhsFn to 
%         CVodeSetFSAOptions. 

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
% $Revision: 4075 $Date: 2007/05/11 18:51:33 $
