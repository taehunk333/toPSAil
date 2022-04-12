function status = CVodeInit(fct, lmm, nls, t0, y0, options)
%CVodeInit allocates and initializes memory for CVODES.
%
%   Usage: CVodeInit ( ODEFUN, LMM, NLS, T0, Y0 [, OPTIONS ] ) 
%
%   ODEFUN   is a function defining the ODE right-hand side: y' = f(t,y).
%            This function must return a vector containing the current 
%            value of the righ-hand side.
%   LMM      is the Linear Multistep Method ('Adams' or 'BDF')
%   NLS      is the type of nonlinear solver used ('Functional' or 'Newton')
%   T0       is the initial value of t.
%   Y0       is the initial condition vector y(t0).  
%   OPTIONS  is an (optional) set of integration options, created with
%            the CVodeSetOptions function. 
%
%   See also: CVodeSetOptions, CVRhsFn 
% 
%   NOTES:
%    1) The 'Functional' nonlinear solver is best suited for non-stiff
%       problems, in conjunction with the 'Adams' linear multistep method,
%       while 'Newton' is better suited for stiff problems, using the 'BDF'
%       method.
%    2) When using the 'Newton' nonlinear solver, a linear solver is also
%       required. The default one is 'Dense', indicating the use of direct
%       dense linear algebra (LU factorization). A different linear solver
%       can be specified through the option 'LinearSolver' to CVodeSetOptions.

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
% $Revision: 4075 $Date: 2007/08/21 23:09:18 $

mode = 1;

if nargin < 5
  error('Too few input arguments');
end

if nargin < 6
  options = [];
end

status = cvm(mode, fct, lmm, nls, t0, y0, options);
