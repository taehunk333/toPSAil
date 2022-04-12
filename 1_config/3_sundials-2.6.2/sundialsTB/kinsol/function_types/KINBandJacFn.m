%KINBandJacFn - type for user provided banded Jacobian function.
%
%   The function BJACFUN must be defined as 
%        FUNCTION [J, FLAG] = BJACFUN(Y, FY)
%   and must return a matrix J corresponding to the banded Jacobian of f(y).
%   The input argument FY contains the current value of f(y).
%   If a user data structure DATA was specified in KINInit, then
%   BJACFUN must be defined as
%        FUNCTION [J, FLAG, NEW_DATA] = BJACFUN(Y, FY, DATA)
%   If the local modifications to the user data structure are needed in
%   other user-provided functions then, besides setting the matrix J and
%   the flag FLAG, the BJACFUN function must also set NEW_DATA. Otherwise, 
%   it should set NEW_DATA=[] (do not set NEW_DATA = DATA as it would lead
%   to unnecessary copying).
%
%   The function BJACFUN must set FLAG=0 if successful, FLAG<0 if an
%   unrecoverable failure occurred, or FLAG>0 if a recoverable error
%   occurred.
%
%   See also KINSetOptions
%
%   NOTE: BJACFUN is specified through the property JacobianFn to KINSetOptions 
%   and is used only if the property LinearSolver was set to 'Band'.

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
% $Revision: 4075 $Date: 2007/05/11 18:48:46 $
