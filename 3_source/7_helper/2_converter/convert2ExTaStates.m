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
%Code created on       : 2022/1/25/Tuesday
%Code last modified on : 2022/1/25/Tuesday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : convert2ExTaStates.m
%Source     : common
%Description: given an overall state vector or matrix, convert to a
%             state vector or matrix storing state variables for a single
%             product tank.
%             Components   - $i \in \left\{ 1, ..., params.nComs \right\}$
%             CSTRs        - $n \in \left\{ 1, ..., params.nVols \right\}$
%             time points  - $t \in \left\{ 1, ..., nTimePts \right\}$ 
%Inputs     : params       - a struct containing simulation parameters 
%                            (scalars, vectors, functions, strings, etc.) 
%                            as its fields.
%             states       - a dimensionless state solution vector or
%                            matrix containing all the state variables
%             exTaNum      - an integer value denoting the number of the
%                            tank that we would like to obtain states for. 
%Outputs    : exTaStates   - a state vector or matrix containing states
%                            associated with a column given by colNum. The
%                            states variables includes the CSTR states for
%                            all CSTRs and the cumulative flows at the
%                            boundaries.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function exTaStates = convert2ExTaStates(params,states,exTaNum)
  
    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'convert2ExTaStates.m';
    
    %Unpack params         
    inShExTa = params.inShExTa;
    nExTaStT = params.nExTaStT;
    %---------------------------------------------------------------------%           
    
    
    
    %---------------------------------------------------------------------%
    %Determine the states associated with the product tank represented
    %by the given tank number
        
    %Calculate the begining index
    initInd = inShExTa+nExTaStT*(exTaNum-1);

    %Get teh corresponding feed tank states
    exTaStates = states(:,initInd+1:initInd+nExTaStT);   
    %---------------------------------------------------------------------%     
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%