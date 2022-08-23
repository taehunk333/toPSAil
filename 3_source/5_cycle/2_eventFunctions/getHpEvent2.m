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
%Function   : getHpEvent2.m
%Source     : common
%Description: This is the second type of an event function for high 
%             pressure feed. The event criteria is a termination with
%             average product purity of cumulative products that exited
%             the adsorption column so far in the simulation until time
%             t_curr.
%             column.
%Inputs     : params       - a struct containing simulation parameters.
%Outputs    : event        - a value that defines an event to happen when
%                            the function value becomes zero
%             isTerminal   - a boolean determining if we need to stop the 
%                            integration once the event happens
%             direction    - a boolean for stating direction(s) to approach
%                            a zero event function value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [event,isterminal,direction] = getHpEvent2(params,~,states,nS,nCy)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Define function ID
    %funcId = 'getHpEvent2.m';
    
    %Unpack params
    eveColNo     = params.eveColNo(nS);
    nComs        = params.nComs       ;
    nColStT      = params.nColStT     ;    
    eveLkMolFrac = params.eveLkMolFrac;
    
    %Convert the states into a row vector
    states = states(:).';
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Call any other events first
    
    %Did Nth column break through happened?   
    [event1,~,~] = getHpEvent1(params,0,states,nS,nCy);            
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Unpack states and obtain necessary quantities
 
    %Compute the total cumulative mole fraction of the product gas that
    %left the adsorption column from top end
    
    %For the initial time point, we do not have and flow yet
    if event1 < 0
        
        %-----------------------------------------------------------------%
        %Compute the cumulative product concentration
        
        %Assign the current cumulative product concentration as an output
        gasMoleFracCum = states(:,nColStT*eveColNo-nComs+1)/ ...
                  sum(states(:,nColStT*eveColNo-nComs+1:nColStT*eveColNo)); 
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Compute the event criteria 

        %Purity of the product above a threshold
        event = gasMoleFracCum-eveLkMolFrac;
        %-----------------------------------------------------------------%
    
    %If the first event has not triggered,
    else
        
         %No need to test for the second event
         event = event1;
         
    end
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