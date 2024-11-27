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
%Code created on       : 2021/7/20/Wednesday
%Code last modified on : 2022/7/20/Wednesday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : defineJacobMat.m
%Source     : common
%Description: this function evaluates and returns the analytical expression
%             for the Jacobian matrix at (t,x).
%Inputs     : t            - a scalar value of a current time point 
%             x            - a state solution row vector containing all
%                            the state variables associated with the
%                            current step inside a given PSA cycle.
%             params       - a struct containing simulation parameters.
%Outputs    : dfdx         - the analytical expression for the Jacobian
%                            matrix, evaluated at (t,x).
%             dfdxp        - (for ode15i only) the analytical expression
%                            for the 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [dfdx,dfdxp]  = defineJacobMat(t,x,params)

    %---------------------------------------------------------------------%    
    %Define known quantities
        
    %Name the function ID
    %funcId = 'defineRhsFunc.m';    
    
    %Unpack params              
    funcVol = params.funcVol;
    nS      = params.nS     ;
    %---------------------------------------------------------------------%   
    
    
    
    %---------------------------------------------------------------------%                            
    %Check function inputs
      
    %Convert the states to a row vector
    x = x(:).';
    %---------------------------------------------------------------------%                            
    

    
    %---------------------------------------------------------------------%
    %Given a state vector, convert it to respective state variables
    %associated with each columns and tanks    
    
    %Create an object for the columns
    units.col = makeColumns(params,x);
    
    %Create an object for the feed tanks
    units.feTa = makeFeedTank(params,x);
    
    %Create an object for the raffinate product tanks
    units.raTa = makeRaffTank(params,x);  
    
    %Create an object for the extract product tanks
    units.exTa = makeExtrTank(params,x); 
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Define the inter-unit interactions in a given process flow diagram    
    
    %Update adsorption column structures to contain interactions between 
    %units down or upstream
    units = makeCol2Interact(params,units,nS);
    
    %Based on the volumetric flow function handle, obtain the corresponding
    %volumetric flow rates associated with the adsorption columns
    units = funcVol(params,units,nS);
    %---------------------------------------------------------------------%  
    
    
    
    %---------------------------------------------------------------------%
    %
    
    
    
    
    
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Return the function outputs
    
    %Save dfdx
    dfdx = [];
    
    %Save dfdxp. For now, 
    dfdxp = [];
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Test and compare against the finite difference code
    
    %Obtain the jacobian matrix using the finite difference method.
    [dfdxFD,~] = calcJacMatFiniteDiff(t,x,params);    
    
    %Compare the elements of the two matricex
    isequal(dfdx,dfdxFD)
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%