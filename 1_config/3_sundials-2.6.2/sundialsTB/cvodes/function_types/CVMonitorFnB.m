%CVMonitorFnB - type of user provided monitoring function for backward problems.
%
%   The function MONFUNB must be defined as
%       FUNCTION [] = MONFUNB(CALL, IDXB, T, Y, YQ)
%   It is called after every internal CVodeB step and can be used to
%   monitor the progress of the solver. MONFUNB is called with CALL=0
%   from CVodeInitB at which time it should initialize itself and it
%   is called with CALL=2 from CVodeFree. Otherwise, CALL=1.
%
%   It receives as arguments the index of the backward problem (as
%   returned by CVodeInitB), the current time T, solution vector Y,
%   and, if it was computed, the quadrature vector YQ. If quadratures
%   were not computed for this backward problem, YQ is empty here.
%
%   If additional data is needed inside MONFUNB, it must be defined
%   as
%      FUNCTION NEW_MONDATA = MONFUNB(CALL, IDXB, T, Y, YQ, MONDATA)
%   If the local modifications to the user data structure need to be 
%   saved (e.g. for future calls to MONFUNB), then MONFUNB must set
%   NEW_MONDATA. Otherwise, it should set NEW_MONDATA=[] 
%   (do not set NEW_MONDATA = DATA as it would lead to unnecessary copying).
%
%   A sample monitoring function, CVodeMonitorB, is provided with CVODES.
%
%   See also CVodeSetOptions, CVodeMonitorB
%
%   NOTES: 
%   
%   MONFUNB is specified through the MonitorFn property in CVodeSetOptions. 
%   If this property is not set, or if it is empty, MONFUNB is not used.
%   MONDATA is specified through the MonitorData property in CVodeSetOptions.
%
%   See CVodeMonitorB for an implementation example.

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
% $Revision: 4075 $Date: 2006/03/07 01:19:50 $
