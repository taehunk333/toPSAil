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
%Code created on       : 2022/12/22/Thursday
%Code last modified on : 2022/12/22/Thursday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getRaTaEventPressureAccMult.m
%Source     : common
%Description: This is an event function that triggers when the pressure
%             inside the n_c th CSTR inside the raffinate tank reaches the
%             raffinate tank nominal pressure level, or the other
%             user-specified event triggers, whichever one comes first. In
%             the case of high pressure feed, we can have a breakthrough
%             thershold specified, in addition to raffinate product tank
%             pressure threshold. Therefore, we need to employ multiple
%             event criteria.
%Inputs     : params       - a struct containing simulation parameters.
%             t            - a current time point.
%             states       - a current state vector at the current time 
%                            point t.
%Outputs    : event        - a vector that defines the events to happen 
%                            when the event function values become zeros
%             isTerminal   - a boolean determining if we need to stop the 
%                            integration once the event happens
%             direction    - a boolean for stating direction(s) to approach
%                            a zero event function value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [event,isterminal,direction] ...
    = getRaTaEventPressureAccMult(params,t,states)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Define function ID
    %funcId = 'getRaTaEventPressureAccMult.m';
    
    %Unpack params
    pRatRa         = params.pRatRa       ;
    nComs          = params.nComs        ;
    gasConsNormEq  = params.gasConsNormEq;
    inShRaTa       = params.inShRaTa     ;
    nS             = params.nS           ;
    funcEve        = params.funcEve{nS}  ;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Initialize solution arrays
    
    %Initialize the event vector 
    event      = zeros(2,1); 
    isterminal = zeros(2,1);
    direction  = zeros(2,1);
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
    %Evaluate the first event

    %Check the pressure threshold, i.e., the first event
    event(1) = currTankPressure ...
             - pRatRa ;             
    %---------------------------------------------------------------------%    
    

      
    %---------------------------------------------------------------------%
    %Specify the event criteria
    
    %Shall we stop the integration after an event triggers?
    isterminal(1) = 1; % Halt integration (1 = true, 0 = false)
    
    %From which side should we approach zero?
    direction(1) = 0; % The zero can be approached from either direction    
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Evaluate the second event
    
    %Check the breakthrough threshold, i.e., the second event
    [event(2),isterminal(2),direction(2)] = funcEve(params,t,states);
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%