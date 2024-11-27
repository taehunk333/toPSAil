%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Project Sponsors :
%U.S. Department of Energy 
%American Institute of Chemical Engineers
%Rapid Advancement in Process Intensification Deployment (RAPID) Institute
%Center for Process Modeling (CPM)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Contributor(s) :
%Department of Chemical and Biomolecular Engineering,
%Georgia Institute of Technology,
%311 Ferst Drive NW, Atlanta, GA 30332-0100.
%Scott Research Group
%https://www.jkscottresearchgroup.com/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Project title :
%Dynamic Modeling and Simulation of Pressure Swing Adsroption (PSA)
%Process Systems
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Code by               : Taehun Kim
%Review by             : Taehun Kim
%Code created on       : 2019/2/4/Monday
%Code last modified on : 2021/1/18/Monday
%Code last modified by : Taehun Kim
%Model Release Number  : 2nd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcJacMatFiniteDiff.m
%Source     : common
%Description: Computes the Jacobian matrix at a given state solution by
%             using the finite difference using odenumjac.m.
%Inputs     : params       - a struct containing simulation parameters
%             states       - a dimensionless initial condition state vector
%             func         - a chosen event function to be used in 
%                            evaluating the initial value.
%             side         - a scalar input to determine on which 
%                            side of zero the event function would start. A
%                            positive number will define the positive side 
%                            as the expected side of zero and vice versa 
%                            for a negative number. 
%                            expectedSideOfZero=1 means that you expect the
%                            event function's threshold comparison to yield
%                            a positive result.    
%             nCy          - ith PSA cycle
%             nS           - jth step in a given PSA cycle
%Outputs    : event        - a logic value of true or false. If true, 
%                            the event function will work with the given 
%                            initial condition. If false, the event 
%                            function will not work.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [jacMat,spyPat] = calcJacMatFiniteDiff(t,x,params)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcJacMatFiniteDiff.m';      
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calculate the function outputs: the evaluated Jacobian matrix at
    %a given state solution, i.e., jacMat, and the sparsoty pattern of the 
    %Jacobian matrix, i.e., spyPat.
    
    %Evaluate the right hand side function at the initial condition
    rhsEval = defineRhsFunc(t,x,params);
    
    %Define options for the Jacobian
    jacOpts = struct('diffvar', 2, ...
                      'vectvars', [], ...
                      'thresh', 1e-8, ...
                      'fac', []);
    
    %Get the jacobian matrix at the given state, using the finite
    %difference code given by odenumjac.m
    jacMat = odenumjac(@defineRhsFunc, ...
                       {t x' params}, ...
                       rhsEval, ...
                       jacOpts); 
    
    %Get the sparsity pattern for the Jacobian matrix for the right hand
    %side function
    spyPat = sparse(jacMat~=0.0);
    %---------------------------------------------------------------------%
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%