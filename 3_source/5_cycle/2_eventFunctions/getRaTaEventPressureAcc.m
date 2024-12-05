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
%Function   : getRaTaEventPressureAcc.m
%Source     : common
%Description: This is an event function that triggers when the pressure
%             inside the n_c th CSTR inside the raffinate tank reaches the
%             raffinate tank nominal pressure level.
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
    = getRaTaEventPressureAcc(params,~,states)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Define function ID
    %funcId = 'getRaTaEventPressureAcc.m';
    
    %Unpack params
    pRatRa         = params.pRatRa        ;
    nComs          = params.nComs         ;
    gasConsNormEq  = params.gasConsNormEq ;
    inShRaTa       = params.inShRaTa      ;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Compute the event criteria 
    
    %Shift the index to be that of the raffinate tank
    indSh = inShRaTa;

    %Get the index for the first component
    indFirst = indSh+1;

    %Get the index for the last component
    indEnd = indSh+nComs;

    %Get the total gas concentration in the gas phase
    gasConsTot = sum(states(indFirst:indEnd));

    %Get the interior temperature of the raffinate tank
    intTempTank = states(indEnd+1);

    %Compute the current pressure in the raffinate tank
    currTankPressure = gasConsTot.*intTempTank.*gasConsNormEq;
    %---------------------------------------------------------------------%



    %---------------------------------------------------------------------%
    %Evaluate the event

    %Check the pressure threshold
    event = currTankPressure ...
          - pRatRa ;
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