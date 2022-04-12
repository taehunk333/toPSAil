%KINPrecSetupFn - type for user provided preconditioner setup function.
%
%   The user-supplied preconditioner setup subroutine should compute 
%   the right-preconditioner matrix P used to form the scaled preconditioned 
%   linear system:
%
%   (Df*J(y)*(P^-1)*(Dy^-1)) * (Dy*P*x) = Df*(-F(y))
%
%   where Dy and Df denote the diagonal scaling matrices whose diagonal elements 
%   are stored in the vectors YSCALE and FSCALE, respectively.
%
%   The preconditioner setup routine (referenced by iterative linear
%   solver modules via pset (type KINSpilsPrecSetupFn)) will not be
%   called prior to every call made to the psolve function, but will
%   instead be called only as often as necessary to achieve convergence
%   of the Newton iteration.
%
%   NOTE: If the PRECSOLVE function requires no preparation, then a
%   preconditioner setup function need not be given.
%
%   The function PSETFUN must be defined as 
%        FUNCTION FLAG = PSETFUN(Y, YSCALE, FY, FSCALE)
%   The input argument FY contains the current value of f(y), while YSCALE
%   and FSCALE are the scaling vectors for solution and system function,
%   respectively (as passed to KINSol)
%
%   If a user data structure DATA was specified in KINInit, then
%   PSETFUN must be defined as
%        FUNCTION [FLAG, NEW_DATA] = PSETFUN(Y, YSCALE, FY, FSCALE, DATA)
%   If the local modifications to the user data structure are needed in
%   other user-provided functions then, besides setting the flag FLAG,
%   the PSETFUN function must also set NEW_DATA. Otherwise, it should 
%   set NEW_DATA=[] (do not set NEW_DATA = DATA as it would lead
%   to unnecessary copying).
%
%   If successful, PSETFUN must return FLAG=0. For a recoverable error (in    
%   which case the setup will be retried) it must set FLAG to a positive
%   integer value. If an unrecoverable error occurs, it must set FLAG
%   to a negative value, in which case the solver will halt.
%
%   See also KINPrecSolveFn, KINSetOptions, KINSol
%
%   NOTE: PSETFUN is specified through the property PrecSetupFn to KINSetOptions 
%   and is used only if the property LinearSolver was set to 'GMRES' or 'BiCGStab'.

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
