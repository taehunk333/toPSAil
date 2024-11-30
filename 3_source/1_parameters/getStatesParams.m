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
%Code created on       : 2021/1/3/Sunday
%Code last modified on : 2022/1/21/Friday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getStatesParams.m
%Source     : common
%Description: given an initial set of parameters, calculate parameters that
%             are associated with states variables in the system.
%Inputs     : params       - a struct containing simulation parameters.
%Outputs    : params       - a struct containing simulation parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function params = getStatesParams(params)    
    
    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'getStatesParams.m';
    
    %Unpack params
    nComs   = params.nComs  ;
    nVols   = params.nVols  ;
    nCols   = params.nCols  ;
    nCycles = params.nCycles;
    nSteps  = params.nSteps ;
    nTiPts  = params.nTiPts ;   
    nFeTas  = params.nFeTas ;
    
    %Set the number of auxiliary units/streams in the process flow sheet
    nPumps = 1;
    nComps = 2;
    % nFeTas = 1;
    nRaTas = 1;
    nExTas = 1;
    %---------------------------------------------------------------------% 
    
    
    
    %---------------------------------------------------------------------%    
    %Identify system information for adsorption columns, feed tanks,
    %product tanks, a compressor, and a vacuum pump
        
    %Determine a number of state variables per a single CSTR: 
    %# of phases      : 2     (Adsorbed and Gas Phases)
    %# of components  : nComs (1, ..., n components) 
    %# of temperatures: 2     (CSTR and CSTR wall)
    params.nStates = 2*(nComs)+2;                                          
            
    %Determine a cell of strings containing names of temperature variables
    params.sTemp = {'cstr','wall'}';
    
    %Determine the number of temperature variables per CSTR
    params.nTemp = length(params.sTemp);      
    
    %Define the number of state variables for the feed tank
    %[gas concentrations for species, temperature variables, cumulative
    %species molar flow rates in the tank "inlet"]
    params.nFeTaStT = 2*nComs+params.nTemp;
    
    %Define the number of state variables for the raffinate product tank
    %[gas concentrations for species, temperature variables, cumulative
    %species molar flow rates in the tank "outlet", cumulative species 
    %molar flow rates in the "waste"]
    params.nRaTaStT = 3*nComs+params.nTemp;
                
    %Define the number of state variables for the extract product tank
    %[gas concentrations for species, temperature variables, cumulative
    %species molar flow rates in the tank "outlet", "cumulative species 
    %molar flow rates in the "waste"]
    params.nExTaStT = 3*nComs+params.nTemp;
    
    %Define the number of state variables per adsorber excluding the
    %boundary flows
    params.nColSt = params.nStates*nVols;
    
    %Determine the number of total state variables per adsorber:
    %(# of CSTRs)*(# of states per CSTR)+(# of components for feed end 
    %flow)+(# of components for product end flow)
    params.nColStT = params.nColSt+2*nComs;    
               
    %Determine the number of total state variables per compressor:
    params.nCompStT = 1;
    
    %Determine the number of total state variables per pump:
    params.nPumpStT = 1;
    %---------------------------------------------------------------------%                   
    
    
    
    %---------------------------------------------------------------------%                   
    %Determine overall state information
    
    %Define the total number of states
    %= (total number of states in all adsorption columns) 
    %+ (total number of states in the feed tank)
    %+ (total number of states in the raffinate product tank)
    %+ (total number of states in the extract product tank)
    %+ (total number of states in the first compressor: 1, the work rate)
    %+ (total number of states in the second compressor: 1, the work rate)
    %+ (total number of states for the vaccum pump: 1, the work rate)
    params.nStatesT = params.nColStT*nCols ...
                    + params.nRaTaStT*nRaTas ...
                    + params.nExTaStT*nExTas ...
                    + params.nFeTaStT*nFeTas ...
                    + params.nCompStT*nComps ...
                    + params.nPumpStT*nPumps;
    %---------------------------------------------------------------------%                   
    
    
    
    %---------------------------------------------------------------------%                   
    %Determine solution output properties
    
    %The number of time points
    params.nTiPtsT = (nCycles*nSteps)*nTiPts;
    %---------------------------------------------------------------------%                   
    
    
    
    %---------------------------------------------------------------------%                   
    %Define indices for the tanks so that it does not get recalculated
    %everytime
    
    %For the feed tank,
    params.inShFeTa = nCols*params.nColStT;
    
    %For the raffinate product tank,
    params.inShRaTa = params.inShFeTa ...
                    + nFeTas*params.nFeTaStT;   
                
    %For the extract product tank,
    params.inShExTa = params.inShRaTa ...
                    + nRaTas*params.nRaTaStT;
    
    %For the compressor, 
    params.inShComp = params.inShExTa ...
                    + nExTas*params.nExTaStT;
    
    %For the vacuum pump,
    params.inShVac = params.inShComp ...
                   + nComps*params.nCompStT;
    %---------------------------------------------------------------------%                   
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%