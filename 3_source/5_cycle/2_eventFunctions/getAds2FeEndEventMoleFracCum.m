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
%Function   : getAds2FeEndEventMoleFracCum.m
%Source     : common
%Description: This is an event function that triggers when the cumulative
%             mole fraction inside the 1st CSTR inside the 2nd adsorber
%             reaches a prespecified threshold value.
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
    = getAds2FeEndEventMoleFracCum(params,~,states)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Define function ID
    %funcId = 'getAds2FeEndEventMoleFracCum.m';
    
    %Unpack params
    eveLkMolFrac = params.eveLkMolFrac;
    nComs        = params.nComs       ;
    nColStT      = params.nColStT     ;
    nLKs         = params.nLKs        ;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Compute the event criteria 

    %Shift the index to be that of the last CSTR
    indSh = 2*nColStT;

    %Get the indices for the light key
    indLk    = indSh+1   ;
    indLkEnd = indSh+nLKs;

    %Get the index for the last component
    indEnd   = indSh+nComs;    

    %Get the total cumulative amount of the light keys at the feed end,
    %flown up to time t
    gasMolLk = sum(states(indLk:indLkEnd));

    %Get the total cumulative amount of the all keys at the feed end, flown
    %up to time t
    gasMolTot = sum(states(indLk:indEnd));

    %Compute the current light key mole fraction inside the n_c th CSTR in
    %the 1st adsorber
    currLkMolFrac = gasMolLk ...
                  / gasMolTot;
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