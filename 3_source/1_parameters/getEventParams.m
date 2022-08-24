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
%Code created on       : 2021/2/1/Monday
%Code last modified on : 2022/8/16/Tuesday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getEventParams.m
%Source     : common
%Description: obtain event parameters for the event functions to be used
%             during numerical integration of ODEs.
%Inputs     : params       - a struct containing simulation parameters.
%Outputs    : params       - a struct containing simulation parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function params = getEventParams(params)    
    
    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'getEventParams.m';
    
    %Unpack params
    eveVal   = params.eveVal  ;
    eveUnit  = params.eveUnit ;
    eveLoc   = params.eveLoc  ;
    nSteps   = params.nSteps  ;
    presBeHi = params.presBeHi;    
    tempAmbi = params.tempAmbi;
    %---------------------------------------------------------------------% 
    
                     
    
    %---------------------------------------------------------------------%    
    %Obtain event values
    
    %For each step
    for i = 1 : nSteps
        
        %-----------------------------------------------------------------%    
        %Get the ith step event information
        
        %Get the current event location
        eveLocStep = eveLoc{i};     
        
        %Get the current event value
        eveUnitStep = eveUnit{i};
        
        %Get the current event unit
        eveValStep = eveVal(i);        
        %-----------------------------------------------------------------%    
        
        
        
        %-----------------------------------------------------------------%    
        %Check the logic for the events for the current step

        %Is the step an event driven step? i.e., is there a location for
        %the event?
        noEvent = strcmp(eveLocStep,'None');

        %For a given event location, is there no unit assigned?
        noEventUnit = strcmp(eveUnitStep,'None');

        %For a given event location, is the unit 'Light_Key_[mol_frac]'?
        eventUnitLkMoleFrac = strcmp(eveUnit,'Light_Key_[mol_frac]');
        
        %For a given event location, is the unit 'Pressure_[bar]'?
        eventUnitPressure = strcmp(eveUnit,'Pressure_[bar]');
        
        %For a given event location, is the unit 'Temperature_[K]'?
        eventUnitTemperature = strcmp(eveUnit,'Temperature_[K]');
        %-----------------------------------------------------------------%  
        
        
        
        %-----------------------------------------------------------------%    
        %Assign the event threshold values to proper variables to be used
        %in the respective event functions.
        
        %If no event is assigned for the step
        if noEvent
            
            %No need to assign any variables to store the event function
            %threshold value
            
        %Otherwise, we are given an event for the step    
        else
            
            %-------------------------------------------------------------%    
            %If we are given no unit,
            if noEventUnit

                %No event is going to happen; ask the user to specify a
                %proper unit for the event
                msg1 = 'Please provide a correct unit '; 
                msg2 = 'for the selected event';
                msg = append(funcId,': ', msg1,msg2);
                error(msg);                
            %-------------------------------------------------------------%



            %-------------------------------------------------------------%
            %If we are given a mole fraction on the product stream purity,
            elseif eventUnitLkMoleFrac

                %Define the breakthrough mole fraction
                params.eveLkMolFrac = eveValStep;
            %-------------------------------------------------------------%



            %-------------------------------------------------------------%            
            %If we are given a threshold on the final pressure,
            elseif eventUnitPressure

                %Assign the pressure at which the event will occur
                params.eveTotPresNorm = eveValStep/presBeHi;                
            %-------------------------------------------------------------%



            %-------------------------------------------------------------%
            %If we are given a threshold on the final amount
            elseif eventUnitTemperature

                %Assign the temperature at which the event will occur
                params.eveTempNorm = eveValStep/tempAmbi;

            end                                   
            %-------------------------------------------------------------%                          
    
        end
                
    end
    %---------------------------------------------------------------------%                                                          
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%