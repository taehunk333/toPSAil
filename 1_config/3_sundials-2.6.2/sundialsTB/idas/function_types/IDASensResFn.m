%IDASensRhsFn - type for user provided sensitivity RHS function.
%
%   The function DAESFUN must be defined as 
%        FUNCTION [RS, FLAG] = DAESFUN(T,YY,YP,YYS,YPS)
%   and must return a matrix RS corresponding to fS(t,yy,yp,yyS,ypS).
%   If a user data structure DATA was specified in IDAInit, then
%   DAESFUN must be defined as
%        FUNCTION [RS, FLAG, NEW_DATA] = DAESFUN(T,YY,YP,YYS,YPS,DATA)
%   If the local modifications to the user data structure are needed in
%   other user-provided functions then, besides setting the matrix YSD,
%   the ODESFUN function must also set NEW_DATA. Otherwise, it should
%   set NEW_DATA=[] (do not set NEW_DATA = DATA as it would lead to 
%   unnecessary copying).
%
%   The function DAESFUN must set FLAG=0 if successful, FLAG<0 if an
%   unrecoverable failure occurred, or FLAG>0 if a recoverable error
%   occurred.
%
%   See also IDASetFSAOptions
%
%   NOTE: DAESFUN is specified through the property FSAResFn to 
%         IDASetFSAOptions.

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
% $Revision: 4075 $Date: 2007/05/11 18:48:45 $
