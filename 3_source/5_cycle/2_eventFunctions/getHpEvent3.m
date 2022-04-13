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
%Code created on       : 2021/1/18/Monday
%Code last modified on : 2021/2/16/Tuesday
%Code last modified by : Taehun Kim
%Model Release Number  : 2nd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getHpEvent3.m
%Source     : common
%Description: This is the third type of an event function for high pressure
%             feed. The event criteria is a termination with product tank 
%             purity.
%             column.
%Inputs     : params       - a struct containing simulation parameters.
%             t            - a column vector containing state time points
%             states       - a state solution vector/matrix at a given time
%                            point
%             nCy          - ith PSA cycle
%             nS           - jth step in a given PSA cycle
%Outputs    : event        - a value that defines an event to happen when
%                            the function value becomes zero
%             isTerminal   - a boolean determining if we need to stop the 
%                            integration once the event happens
%             direction    - a boolean for stating direction(s) to approach
%                            a zero event function value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [event,isterminal,direction] = getHpEvent3(params,~,states,~,~)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Define function ID
    %funcId = 'getHpEvent3.m';
    
    %Unpack params
    nComs       = params.nComs      ;           
    inShRaTa    = params.inShRaTa   ;
    evePrdMolFr = params.evePrdMolFr;
    
    %Convert the states into a row vector
    states = states(:).';
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Unpack states and obtain necessary quantities
 
    %Compute the product gas mole fraction inside a product tank
    gasMoleFrPrTa = states(:,inShRaTa+1)/ ...
                                  sum(states(:,inShRaTa+1:inShRaTa+nComs));      
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Compute the event criteria 
    
    %Purity of the product above a threshold
    event = gasMoleFrPrTa-evePrdMolFr;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Specify the event criteria
    
    %Shall we stop the integration after an event triggers?
    isterminal = 1; % Halt integration (1 = true, 0 = false)
    
    %From which side should we approach zero?
    direction = 0; % The zero can be approached from either direction    
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%