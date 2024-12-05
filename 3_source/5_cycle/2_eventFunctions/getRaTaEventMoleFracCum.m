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
%Function   : getRaTaEventMoleFracCum.m
%Source     : common
%Description: This is an event function that triggers when the cumulative
%             mole fraction flown out to the product reservoir from the 
%             raffinate tank when it reaches a prespecified threshold 
%             value.
%Inputs     : params       - a struct containing simulation parameters.
%             t            - a current time point.
%             states       - a current state vector at the current time 
%                            point t.
%Outputs    : event        - a value that defines an event to happen when
%                            the function value becomes zero
%             isTerminal   - a boolean determining if we need to stop the 
%                            integration once the event happens
%             direction    - a boolean for stating direction(s) to approach
%                            a zero event function value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [event,isterminal,direction] ...
    = getRaTaEventMoleFracCum(params,~,states)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Define function ID
    %funcId = 'getRaTaEventMoleFracCum.m';
    
    %Unpack params
    eveLkMolFrac = params.eveLkMolFrac;    
    nComs        = params.nComs       ;    
    inShRaTa     = params.inShRaTa    ;
    nLKs         = params.nLKs        ;
    nTemp        = params.nTemp       ;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Compute the event criteria 

    %Shift the index to be that of the raffinate tank
    indSh = inShRaTa+(nComs+nTemp);

    %Get the indices for the light key
    indLk    = indSh+1   ;
    indLkEnd = indSh+nLKs;

    %Get the index for the last component
    indEnd = indSh+nComs;

    %Get the dimensionless light key concentration in the gas phase
    gasConsLk = sum(states(indLk:indLkEnd));

    %Get the total gas concentration in the gas phase
    gasConsTot = sum(states(indLk:indEnd));

    %Compute the current light key mole fraction inside the raffinate tank
    currLkMolFrac = gasConsLk ...
                  / gasConsTot;
              
    %If we have a NaN (at t = 0, we divide by zero)
    if isnan(currLkMolFrac)
        
        %make sure that we are on the right side of the event function
        currLkMolFrac = 1;
        
    end
    %---------------------------------------------------------------------%



    %---------------------------------------------------------------------%
    %Evaluate the event

    %Check the mole fraction threshold
    event = currLkMolFrac ...
          - eveLkMolFrac ;
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