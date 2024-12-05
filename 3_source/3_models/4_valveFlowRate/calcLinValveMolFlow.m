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
%Function   : calcLinValveFlow.m
%Source     : common
%Description: Based on a given value of valve constants, the pressure
%             values around the valve, compute the molar flow rate across
%             the valve at the outlet stream pressure. 
%Inputs     : valCoeff     - a dimensionless valve coefficient value for a 
%                            given valve with the unit of [-].
%             cUp          - the total dimensionless gas concentration 
%                            at the upstream (south) of the valve [-]
%             cDown        - the total dimensionless gas concentration at
%                            the downstream (north) of the valve [-]
%             TUp          - the dimensionless CSTR temperature at the
%                            upstream (south) of the valve [-]
%             TDown        - the dimensionless CSTR temperature at the
%                            downstream (north) of the valve [-]
%Outputs    : molFlow      - a molar flow rate across the valve [-]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function molFlow = calcLinValveMolFlow(valCoeff,cUp,cDown,TUp,TDown)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcLinValveMolFlow';        
    %---------------------------------------------------------------------%
            
    
    
    %---------------------------------------------------------------------%
    %Calculate the dimensionless molar flow rate after the valve
    
    %Calculate the molar flow rate after the valve for the co-current flow
    molFlow = valCoeff * (TDown.*cDown - TUp.*cUp);
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%