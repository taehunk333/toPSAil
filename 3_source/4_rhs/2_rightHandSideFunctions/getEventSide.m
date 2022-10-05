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
%Code created on       : 2022/10/4/Tuesday
%Code last modified on : 2022/10/4/Tuesday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getEventSide.m
%Source     : common
%Description: a function that sets up the optin structure for the ode 
%             solver.
%Inputs     : params       - a struct containing simulation parameters.
%             nS           - the current step in a given PSA cycle
%Outputs    : eveSide      - the scalar value of -1 or 1. -1 denotes that
%                            the event function value starts from a 
%                            negative number and heads towards zero. 1
%                            denotes that the event function value starts
%                            from a positive number and heads towards zero.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function eveSide = getEventSide(params,nS)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    funcId = 'getEventSide.m';    
    
    %Unpack params              
    eveLoc = params.eveLoc;
    %---------------------------------------------------------------------%                            
   
    
    
    %---------------------------------------------------------------------%
    %Depending on the event location and type, 
    
    
    
    
    
    
    
    
    
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %TBD
    
    
    
    
    
    
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %TBD
    
    
    
    
    
    %---------------------------------------------------------------------%
    
    
                
    %---------------------------------------------------------------------%    
    %TBD
    
    
    
    
    
    
    
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %TBD
    
    
    
    
    
    
    
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %TBD
    
    
    
    
    
    
    
    
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%