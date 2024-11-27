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
%Code created on       : 2021/1/7/Thursday
%Code last modified on : 2021/2/19/Friday
%Code last modified by : Taehun Kim
%Model Release Number  : 2nd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : convert2FeTaStates.m
%Source     : common
%Description: given an overall state vector or matrix, convert to a
%             state vector or matrix storing state variables for a single
%             feed tank. 
%             Components   - $i \in \left\{ 1, ..., params.nComs \right\}$
%             CSTRs        - $n \in \left\{ 1, ..., params.nVols \right\}$
%             time points  - $t \in \left\{ 1, ..., nTimePts \right\}$ 
%Inputs     : params       - a struct containing simulation parameters 
%                            (scalars, vectors, functions, strings, etc.) 
%                            as its fields.
%             states       - a dimensionless state solution vector or
%                            matrix containing all the state variables
%             feTaNum      - an integer value denoting the number of the
%                            column that we would like to obtain states
%                            for. 
%Outputs    : feTaStates   - a state vector or matrix containing states
%                            associated with a column given by colNum. The
%                            states variables includes the CSTR states for
%                            all CSTRs and the cumulative flows at the
%                            boundaries.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function feTaStates = convert2FeTaStates(params,states,feTaNum)
  
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'convert2FeTaStates.m';
    
    %Unpack params         
    inShFeTa = params.inShFeTa;
    nFeTaStT = params.nFeTaStT;
    %---------------------------------------------------------------------%           
    
    
    
    %---------------------------------------------------------------------%
    %Determine the states associated with the feed tank represented
    %by the given tank number
                    
    %Calculate the begining index
    initInd = inShFeTa ...
            + nFeTaStT ...
            * (feTaNum-1);

    %Get teh corresponding feed tank states
    feTaStates = states(:,initInd+1:initInd+nFeTaStT);                    
    %---------------------------------------------------------------------%     
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%