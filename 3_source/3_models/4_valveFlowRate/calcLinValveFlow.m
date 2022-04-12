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
%Code created on       : 2021/1/2/Saturday
%Code last modified on : 2022/3/3/Thursday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : calcLinValveFlow.m
%Source     : common
%Description: Based on a given value of valve constants, the pressure
%             values around the valve, compute a volumetric flow rate after
%             the valve at the outlet pressure. The expression is written
%             in the co-current (i.e., positive) direction. For the counter
%             current flow direction, swap tCon1 and tCon2, evaluate this
%             function, and negate the function output, i.e., -volFlow.
%Inputs     : valCoeff     - a dimensionless valve coefficient value for a 
%                            given valve with the unit of [-].
%             c1           - a total gas concentration; can be constant or
%                            time varying. [-]
%             c2           - a total gas concentration; can be constant or
%                            time varying. [-]
%             T1           - a CSTR temperature; can be constant or
%                            time varying. [-]
%             T2           - a CSTR temperature; can be constant or
%                            time varying. [-]
%Outputs    : volFlow      - a volumetric flow rate after the valve [-].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function volFlow = calcLinValveFlow(valCoeff,c1,c2,T1,T2)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Name the function ID
    %funcId = 'calcLinValveFlow';        
    %---------------------------------------------------------------------%
            
    
    
    %---------------------------------------------------------------------%
    %Calculate the dimensionless volumetric flow rate after the valve
    
    %Calculate the volumetric flow rate after the valve for the co-current
    %flow
    volFlow = valCoeff ...
            * (T2.*c2-T1.*c1) ...
           ./ c1;
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%