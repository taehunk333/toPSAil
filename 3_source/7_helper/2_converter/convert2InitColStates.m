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
%Code last modified on : 2021/1/5/Tuesday
%Code last modified by : Taehun Kim
%Model Release Number  : 2nd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : convert2InitColStates.m
%Source     : common
%Description: takes a state vector containing state variables for a single
%             volume, x_n = [C_{n,1},...,C_{n,n_s},q_{n,1},...,q_{n,n_s}],
%             and generates a state vector for the entire column by 
%             duplicating the given state over all volumes. The order of
%             the states is irrelevant to the operation of this function. 
%             The vector is just duplicated.
%Inputs     : params       - a struct containig simulation parameters.
%             cstrStates   - a non-dimensional state solution for a single
%                            CSTR that can be replicated for all CSTRs
%Outputs    : states       - a non-dimenaional state solution row vector
%                            with the following dimensions:
%                            number of rows = the number of time points,
%                            number of cols = nStatesT
%                                           =
%                                           (2*nComs+nTemp)*nVols+2*nComs%
%                            (e.g.) a single CSTR contains the following
%                            states:
%                            states_n = [C_{n,1}, ..., C_{n,n_c}, ...
%                                        q_{n,1}, ..., q_{n,n_c}, ...
%                                        T_{n}, T_{n,w}];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function states = convert2InitColStates(params,cstrStates)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    funcId = 'convert2InitColStates.m';
    
    %Unpack Params
    nVols   = params.nVols  ;
    nComs   = params.nComs  ;
    nStates = params.nStates;
    maxNoBC = params.maxNoBC;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Check inputs
    
    %Measure the size of the input dimensionless state array, X
    lengCstrStates = length(cstrStates);
    
    %Check if the input s is indeed a vector
    if ~isvector(cstrStates) || lengCstrStates~=nStates
        
        %Print the error message
        msg = 'Please provide a single CSTR states as a vector';
        msg = append(funcId,': ',msg);
        error(msg);
        
    end    
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Calculate function output(s)
    
    %Create a large matrix x consisting of an nVols-by-1 tiling of copies 
    %of x_n using MATLAB's built in function repmat.m
    states = repmat(cstrStates,1,nVols);
    
    %Add zeros for the initial cumulative moles of components flowing in
    %and out of an adsorption column
    states = [states,zeros(1,maxNoBC*nComs)];    
    %---------------------------------------------------------------------%
   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%