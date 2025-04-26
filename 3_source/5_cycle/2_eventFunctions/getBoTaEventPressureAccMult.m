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
%Code last modified on : 2025/04/25/Friday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getBoTaEventPressureAccMult.m
%Source     : common
%Description: This is an event function that triggers when the pressure
%             inside the n_c th CSTR inside the raffinate tank reaches the
%             raffinate tank nominal pressure level, or the pressure inside
%             the extract tank resches the extract tank nominal pressure
%             level, or the other user-specified event triggers, whichever 
%             one comes first. In the case of high pressure feed, we can 
%             have a breakthrough thershold specified, in addition to 
%             raffinate product tank pressure threshold. Therefore, we need
%             to employ multiple event criteria.
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
    = getBoTaEventPressureAccMult(params,t,states)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Define function ID
    %funcId = 'getBoTaEventPressureAccMult.m';
    
    %Unpack params
    nS             = params.nS           ;
    funcEve        = params.funcEve{nS}  ;
    %---------------------------------------------------------------------%
    
    
  
    %---------------------------------------------------------------------%
    %Initialize solution arrays
    
    %Initialize the event vector 
    event      = zeros(3,1); 
    isterminal = zeros(3,1);
    direction  = zeros(3,1);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Evaluate the first event

    %Check the pressure threshold, i.e., the first event
    [event(1),~,~] = getRaTaEventPressureAcc(params,0,states);      
    %---------------------------------------------------------------------%    
    


    %---------------------------------------------------------------------%
    %Evaluate the first event

    %Check the pressure threshold, i.e., the first event
    [event(2),~,~] = getExTaEventPressureAcc(params,0,states);      
    %---------------------------------------------------------------------%  
    

      
    %---------------------------------------------------------------------%
    %Specify the event criteria
    
    %Shall we stop the integration after an event triggers?
    isterminal(1) = 1; % Halt integration (1 = true, 0 = false)
    isterminal(2) = 1; % Halt integration (1 = true, 0 = false)
    
    %From which side should we approach zero?
    direction(1) = 0; % The zero can be approached from either direction    
    direction(2) = 0; % The zero can be approached from either direction 
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Evaluate the second event
    
    %Check the breakthrough threshold, i.e., the second event
    [event(3),isterminal(3),direction(3)] = funcEve(params,t,states);
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%