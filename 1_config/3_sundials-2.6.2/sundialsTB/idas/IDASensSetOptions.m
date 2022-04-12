function options = IDASensSetOptions(varargin)
%IDASensSetOptions creates an options structure for FSA with IDAS.
%
%   Usage: OPTIONS = IDASensSetOptions('NAME1',VALUE1,'NAME2',VALUE2,...)
%          OPTIONS = IDASensSetOptions(OLDOPTIONS,'NAME1',VALUE1,...)
%
%   OPTIONS = IDASensSetOptions('NAME1',VALUE1,'NAME2',VALUE2,...) creates 
%   a IDAS options structure OPTIONS in which the named properties have 
%   the specified values. Any unspecified properties have default values. 
%   It is sufficient to type only the leading characters that uniquely 
%   identify the property. Case is ignored for property names. 
%   
%   OPTIONS = IDASensSetOptions(OLDOPTIONS,'NAME1',VALUE1,...) alters an 
%   existing options structure OLDOPTIONS.
%   
%   IDASensSetOptions with no input arguments displays all property names 
%   and their possible values.
%   
%IDASensSetOptions properties
%(See also the IDAS User Guide)
%
%method - FSA solution method [ 'Simultaneous' | {'Staggered'} ]
%   Specifies the FSA method for treating the nonlinear system solution for
%   sensitivity variables. In the simultaneous case, the nonlinear systems 
%   for states and all sensitivities are solved simultaneously. In the 
%   Staggered case, the nonlinear system for states is solved first and then
%   the nonlinear systems for all sensitivities are solved at the same time. 
%ParamField - Problem parameters  [ string ]
%   Specifies the name of the field in the user data structure (specified through
%   the 'UserData' field with IDASetOptions) in which the nominal values of the problem 
%   parameters are stored. This property is used only if  IDAS will use difference
%   quotient approximations to the sensitivity residuals (see IDASensResFn).
%ParamList - Parameters with respect to which FSA is performed [ integer vector ]
%   Specifies a list of Ns parameters with respect to which sensitivities are to
%   be computed. This property is used only if IDAS will use difference-quotient
%   approximations to the sensitivity residuals. Its length must be Ns, 
%   consistent with the number of columns of yS0 (see IDASensInit).
%ParamScales - Order of magnitude for problem parameters [ vector ]
%   Provides order of magnitude information for the parameters with respect to
%   which sensitivities are computed. This information is used if IDAS 
%   approximates the sensitivity residuals or if IDAS estimates integration
%   tolerances for the sensitivity variables (see RelTol and AbsTol).
%RelTol - Relative tolerance for sensitivity variables [ positive scalar ]
%   Specifies the scalar relative tolerance for the sensitivity variables. 
%   See also AbsTol.
%AbsTol - Absolute tolerance for sensitivity variables [ row-vector or matrix ]
%   Specifies the absolute tolerance for sensitivity variables. AbsTol must be
%   either a row vector of dimension Ns, in which case each of its components is
%   used as a scalar absolute tolerance for the coresponding sensitivity vector,
%   or a N x Ns matrix, in which case each of its columns is used as a vector
%   of absolute tolerances for the corresponding sensitivity vector.
%   By default, IDAS estimates the integration tolerances for sensitivity 
%   variables, based on those for the states and on the order of magnitude 
%   information for the problem parameters specified through ParamScales.
%ErrControl - Error control strategy for sensitivity variables [ false | {true} ]
%   Specifies whether sensitivity variables are included in the error control test.
%   Note that sensitivity variables are always included in the nonlinear system
%   convergence test.
%DQtype - Type of DQ approx. of the sensi. RHS [{Centered} | Forward ]
%   Specifies whether to use centered (second-order) or forward (first-order)
%   difference quotient approximations of the sensitivity eqation residuals.
%   This property is used only if a user-defined sensitivity residual function 
%   was not provided.
%DQparam - Cut-off parameter for the DQ approx. of the sensi. RES [ scalar | {0.0} ]
%   Specifies the value which controls the selection of the difference-quotient 
%   scheme used in evaluating the sensitivity residuals (switch between 
%   simultaneous or separate evaluations of the two components in the sensitivity 
%   right-hand side). The default value 0.0 indicates the use of simultaenous approximation
%   exclusively (centered or forward, depending on the value of DQtype.
%   For DQparam >= 1, IDAS uses a simultaneous approximation if the estimated
%   DQ perturbations for states and parameters are within a factor of DQparam, 
%   and separate approximations otherwise. Note that a value DQparam < 1
%   will inhibit switching! This property is used only if a user-defined sensitivity 
%   residual function was not provided. 
%
%   See also
%        IDASensInit, IDASensReInit

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
% $Revision: 4075 $Date: 2007/05/11 21:42:52 $

% If called without input and output arguments, print out the possible keywords

if (nargin == 0) & (nargout == 0)
  fprintf('          method: [ Simultaneous | {Staggered} ]\n');
  fprintf('      ParamField: [ string ]\n');
  fprintf('       ParamList: [ integer vector ]\n');
  fprintf('     ParamScales: [ vector ]\n');
  fprintf('          RelTol: [ positive scalar ]\n');
  fprintf('          AbsTol: [ row-vector or matrix ]\n');
  fprintf('      ErrControl: [ false | {true} ]\n');
  fprintf('          DQtype: [ {Centered} | {Forward} ]\n');
  fprintf('         DQparam: [ scalar | {0.0} ]\n');
  fprintf('\n');
  return;
end

KeyNames = {
    'method'
    'ParamField'
    'ParamList'
    'ParamScales'
    'RelTol'
    'AbsTol'
    'ErrControl'
    'DQtype'
    'DQparam'
        };

options = idm_options(KeyNames,varargin{:});

