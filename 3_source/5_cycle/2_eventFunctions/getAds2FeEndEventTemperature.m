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
%Code created on       : 2022/8/24/Wednesday
%Code last modified on : 2022/8/24/Wednesday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getAds2FeEndEventTemperature.m
%Source     : common
%Description: This is an event function that triggers when the temperature
%             inside the 1st CSTR inside the 1st adsorber reaches a 
%             prespecified threshold value.
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
    = getAds2FeEndEventTemperature(params,~,states)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Define function ID
    %funcId = 'getAds2FeEndEventTemperature.m';
    
    %Unpack params
    eveTotTempNorm = params.eveTotTempNorm;
    nComs          = params.nComs         ; 
    nColStT        = params.nColStT       ;
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Compute the event criteria 
    
    %Shift the index to be that of the last CSTR
    indSh = nColStT;

    %Compute the current pressure in the n_c th CSTR
    currCstrTemperature = states(:,indSh+2*nComs+1);
    %---------------------------------------------------------------------%



    %---------------------------------------------------------------------%
    %Evaluate the event

    %Check the temperature threshold
    event = currCstrTemperature ...
          - eveTotTempNorm ;
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