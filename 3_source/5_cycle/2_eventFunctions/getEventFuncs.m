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
%Code last modified on : 2022/10/5/Wednesday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : getEventFuncs.m
%Source     : common
%Description: given cycle information contained inside params, put together
%             a cell array containing any applicable event functions for a
%             given PSA step in a PSA cycle simulation
%Inputs     : params       - a struct containing simulation parameters.
%Outputs    : funcEve      - a cell array that contains event functions
%                            that are associated with different events in a
%                            given PSA cycle.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function funcEve = getEventFuncs(params)    
    
    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    funcId = 'getEventFuncs.m';
    
    %Unpack params
    nSteps  = params.nSteps ;         
    eveLoc  = params.eveLoc ;
    eveUnit = params.eveUnit;    
    %---------------------------------------------------------------------%                                  
    
    
    
    %---------------------------------------------------------------------%                     
    %Initialize solution arrays
    
    %Initialize a cell array containing the event functions
    funcEve = cell(nSteps,1);    
    %---------------------------------------------------------------------%                                                                                                           
        
    
    
    %---------------------------------------------------------------------%                     
    %Specification of the event functions for the event driven mode
    
    %For all steps in a given PSA cycle, for each step,
    %for all the steps in a given PSA cycle
    for i = 1 : nSteps

        %-----------------------------------------------------------------%
        %Determine the current event location and verify if the step is an
        %event driven step
        
        %Get the ith step event location       
        eveLocStep = eveLoc{i};
        
        %Compare the string to see if we are dealing with an event driven
        %step
        eveTrue = ~strcmp(eveLocStep,'None');
        
        %Get the ith event unit
        eveUnitStep = eveUnit{i};
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %If there is an event for the ith step, assign the correct event 
        %function for the step
        
        %The step is not an event driven step
        if eveTrue == 0
        
            %No event function is assigned   
            funcEve{i} = [];
        
        %The step is an event driven step
        else
            
            %-------------------------------------------------------------%
            %Determine where the event is happening
            
            %Adsorption column no.1
            eveInAds1FeEnd = strcmp(eveLocStep,'Adsorber_1_Feed_End');
            eveInAds1PrEnd = strcmp(eveLocStep,'Adsorber_1_Prod_End');
            
            %Adsorption column no.2
            eveInAds2FeEnd = strcmp(eveLocStep,'Adsorber_2_Feed_End');
            eveInAds2PrEnd = strcmp(eveLocStep,'Adsorber_2_Prod_End');
            
            %The feed tank
            eveInFeTa = strcmp(eveLocStep,'Feed_Tank');
            
            %The feed stream
            eveInFeSt = strcmp(eveLocStep,'Feed_Stream');
            
            %The raffinate tank
            eveInRaTa = strcmp(eveLocStep,'Raffinate_Tank');
            
            %The raffinate stream
            eveInRaSt = strcmp(eveLocStep,'Raffinate_Stream');
            
            %The extract tank
            eveInExTa = strcmp(eveLocStep,'Extract_Tank');
            
            %The extract stream
            eveInExSt = strcmp(eveLocStep,'Extract_Stream');
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%
            %Determine the type of the event for the current step
            
            %Threshold on the sum of the mole fractions of the light keys
            eveTypeMolFrac ...
                = strcmp(eveUnitStep,'Sum_LK_Mol_Frac_[-]');
            
            %Threshold on the cumulative sum of the mole fractions of the 
            %light keys
            eveTypeMolFracCum ...
                = strcmp(eveUnitStep,'Cum_Sum_LK_Mol_Frac_[-]');
            
            %Pressure threshold
            eveTypePres ...
                = strcmp(eveUnitStep,'Pressure_[bar]');
            
            %Temperature threshold
            eveTypeTemp ...
                = strcmp(eveUnitStep,'Temperature_[K]');
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%
            %Assign the event function for the step, based on the location
            %and type of the event
            
            %If we have an event at the feed-end of the the first adsorber
            if eveInAds1FeEnd == 1
                
                %---------------------------------------------------------%
                %Depending on the event type, assign the corresponding
                %event function for the step
                
                %If we have the sum of the light key mole fractions
                if eveTypeMolFrac == 1
                
                    %Assign the event function
                    funcEve{i} ...
                        = @(params,t,states) ...
                          getAds1FeEndEventMoleFrac(params,t,states);
                      
                %If we have the cumulative sum of the light key mole
                %fractions
                elseif eveTypeMolFracCum == 1
                    
                    %Assign the event function
                    funcEve{i} ...
                        = @(params,t,states) ...
                          getAds1FeEndEventMoleFracCum(params,t,states);
                
                %If we have the pressure in the unit
                elseif eveTypePres == 1
                    
                    %Assign the event function
                    funcEve{i} ...
                        = @(params,t,states) ...
                          getAds1FeEndEventPressure(params,t,states);
                    
                %If we have the temperature in the unit
                elseif eveTypeTemp == 1
                    
                    %Assign the event function
                    funcEve{i} ...
                        = @(params,t,states) ...
                          getAds1FeEndEventTemperature(params,t,states);
                
                end
                %---------------------------------------------------------%
                
            %If we have an event at the product-end of the the first 
            %adsorber
            elseif eveInAds1PrEnd == 1
            
                %---------------------------------------------------------%
                %Depending on the event type, assign the corresponding
                %event function for the step
                
                %If we have the sum of the light key mole fraction
                if eveTypeMolFrac == 1
                
                    %Assign the event function
                    funcEve{i} ...
                        = @(params,t,states) ...
                          getAds1PrEndEventMoleFrac(params,t,states);
                      
                %If we have the cumulative sum of the light key mole
                %fractions
                elseif eveTypeMolFracCum == 1
                    
                    %Assign the event function
                    funcEve{i} ...
                        = @(params,t,states) ...
                          getAds1PrEndEventMoleFracCum(params,t,states);
                    
                %If we have the pressure in the unit
                elseif eveTypePres == 1
                    
                    %Assign the event function
                    funcEve{i} ...
                        = @(params,t,states) ...
                          getAds1PrEndEventPressure(params,t,states);
                    
                %If we have the temperature in the unit
                elseif eveTypeTemp == 1
                    
                    %Assign the event function
                    funcEve{i} ...
                        = @(params,t,states) ...
                          getAds1PrEndEventTemperature(params,t,states);
                
                end
                %---------------------------------------------------------%            
            
            %If we have an event at the feed-end of the the second 
            %adsorber
            elseif eveInAds2FeEnd == 1
                
                %---------------------------------------------------------%
                %Depending on the event type, assign the corresponding
                %event function for the step
                
                %If we have the sum of the light key mole fractions
                if eveTypeMolFrac == 1
                
                    %Assign the event function
                    funcEve{i} ...
                        = @(params,t,states) ...
                          getAds2FeEndEventMoleFrac(params,t,states);
                      
                %If we have the cumulative sum of the light key mole
                %fractions
                elseif eveTypeMolFracCum == 1
                    
                    %Assign the event function
                    funcEve{i} ...
                        = @(params,t,states) ...
                          getAds2FeEndEventMoleFracCum(params,t,states);
                    
                %If we have the pressure in the unit
                elseif eveTypePres == 1
                    
                    %Assign the event function
                    funcEve{i} ...
                        = @(params,t,states) ...
                          getAds2FeEndEventPressure(params,t,states);
                    
                %If we have the temperature in the unit
                elseif eveTypeTemp == 1
                    
                    %Assign the event function
                    funcEve{i} ...
                        = @(params,t,states) ...
                          getAds2FeEndEventTemperature(params,t,states);
                
                end
                %---------------------------------------------------------%
                
            %If we have an event at the product-end of the the second 
            %adsorber
            elseif eveInAds2PrEnd == 1
                
                %---------------------------------------------------------%
                %Depending on the event type, assign the corresponding
                %event function for the step
                
                %If we have the sum of the light key mole fractions
                if eveTypeMolFrac == 1
                
                    %Assign the event function
                    funcEve{i} ...
                        = @(params,t,states) ...
                          getAds2PrEndEventMoleFrac(params,t,states);
                      
                %If we have the cumulative sum of the light key mole
                %fractions
                elseif eveTypeMolFracCum == 1
                    
                    %Assign the event function
                    funcEve{i} ...
                        = @(params,t,states) ...
                          getAds2PrEndEventMoleFracCum(params,t,states);                    
                    
                %If we have the pressure in the unit
                elseif eveTypePres == 1
                    
                    %Assign the event function
                    funcEve{i} ...
                        = @(params,t,states) ...
                          getAds2PrEndEventPressure(params,t,states);
                    
                %If we have the temperature in the unit
                elseif eveTypeTemp == 1
                    
                    %Assign the event function
                    funcEve{i} ...
                        = @(params,t,states) ...
                          getAds2PrEndEventTemperature(params,t,states);
                
                end
                %---------------------------------------------------------%
            
            %If we have an event at the feed tank
            elseif eveInFeTa == 1
            
                %---------------------------------------------------------%
                %Depending on the event type, assign the corresponding
                %event function for the step
                
                %If we have the sum of the light key mole fractions
                if eveTypeMolFrac == 1
                
                    %Assign the event function
                    funcEve{i} ...
                        = @(params,t,states) ...
                          getFeTaEventMoleFrac(params,t,states);
                      
                %If we have the cumulative sum of the light key mole
                %fractions
                elseif eveTypeMolFracCum == 1
                    
                    %Notify the user that the event is not supported
                    noteEventNotReady(funcId);
                    
                %If we have the pressure in the unit
                elseif eveTypePres == 1
                    
                    %Assign the event function
                    funcEve{i} ...
                        = @(params,t,states) ...
                         getFeTaEventPressure(params,t,states);
                    
                %If we have the temperature in the unit
                elseif eveTypeTemp == 1
                    
                    %Assign the event function
                    funcEve{i} ...
                        = @(params,t,states) ...
                         getFeTaEventTemperature(params,t,states);
                
                end
                %---------------------------------------------------------%            
            
            %If we have an event at the feed stream
            elseif eveInFeSt == 1
                
                %---------------------------------------------------------%            
                %Depending on the event type, assign the corresponding
                %event function for the step
                
                %If we have the sum of the light key mole fractions
                if eveTypeMolFrac == 1
                
                    %Notify the user that the event is not supported
                    noteEventNotReady(funcId);
                      
                %If we have the cumulative sum of the light key mole
                %fractions
                elseif eveTypeMolFracCum == 1
                    
                    %Assign the event function
                    funcEve{i} ...
                        = @(params,t,states) ...
                          getFeStEventMoleFracCum(params,t,states);                    
                    
                %If we have the pressure in the unit
                elseif eveTypePres == 1
                    
                    %Notify the user that the event is not supported
                    noteEventNotReady(funcId);
                    
                %If we have the temperature in the unit
                elseif eveTypeTemp == 1
                    
                    %Notify the user that the event is not supported
                    noteEventNotReady(funcId);  
                    
                end
                %---------------------------------------------------------%            
                
            %If we have an event at the raffinate tank
            elseif eveInRaTa == 1
                
                %---------------------------------------------------------%
                %Depending on the event type, assign the corresponding
                %event function for the step
                
                %If we have the sum of the light key mole fractions
                if eveTypeMolFrac == 1
                
                    %Assign the event function
                    funcEve{i} ...
                        = @(params,t,states) ...
                          getRaTaEventMoleFrac(params,t,states);
                      
                %If we have the cumulative sum of the light key mole
                %fractions
                elseif eveTypeMolFracCum == 1
                    
                    %Assign the event function
                    funcEve{i} ...
                        = @(params,t,states) ...
                          getRaTaEventMoleFracCum(params,t,states);
                    
                %If we have the pressure in the unit
                elseif eveTypePres == 1
                    
                    %Assign the event function
                    funcEve{i} ...
                        = @(params,t,states) ...
                          getRaTaEventPressure(params,t,states);
                    
                %If we have the temperature in the unit
                elseif eveTypeTemp == 1
                    
                    %Assign the event function
                    funcEve{i} ...
                        = @(params,t,states) ...
                          getRaTaEventTemperature(params,t,states);
                
                end
                %---------------------------------------------------------%
                         
            %If we have an event at the raffinate stream
            elseif eveInRaSt == 1
                
                %---------------------------------------------------------%            
                %Depending on the event type, assign the corresponding
                %event function for the step
                
                %If we have the sum of the light key mole fractions
                if eveTypeMolFrac == 1
                
                    %Notify the user that the event is not supported
                    noteEventNotReady(funcId);
                      
                %If we have the cumulative sum of the light key mole
                %fractions
                elseif eveTypeMolFracCum == 1
                    
                    %Assign the event function
                    funcEve{i} ...
                        = @(params,t,states) ...
                          getRaStEventMoleFracCum(params,t,states);                    
                    
                %If we have the pressure in the unit
                elseif eveTypePres == 1
                    
                    %Notify the user that the event is not supported
                    noteEventNotReady(funcId);
                    
                %If we have the temperature in the unit
                elseif eveTypeTemp == 1
                    
                    %Notify the user that the event is not supported
                    noteEventNotReady(funcId);
                
                end
                %---------------------------------------------------------%                      
                
            %If we have an event at the extract tank
            elseif eveInExTa == 1
                
                %---------------------------------------------------------%
                %Depending on the event type, assign the corresponding
                %event function for the step
                
                %If we have the sum of the light key mole fractions
                if eveTypeMolFrac == 1
                
                    %Assign the event function
                    funcEve{i} ...
                        = @(params,t,states) ...
                          getExTaEventMoleFrac(params,t,states);
                      
                %If we have the cumulative sum of the light key mole
                %fractions
                elseif eveTypeMolFracCum == 1
                    
                    %Notify the user that the event is not supported
                    noteEventNotReady(funcId);
                    
                %If we have the pressure in the unit
                elseif eveTypePres == 1
                    
                    %Assign the event function
                    funcEve{i} ...
                        = @(params,t,states) ...
                          getExTaEventPressure(params,t,states);
                    
                %If we have the temperature in the unit
                elseif eveTypeTemp == 1
                    
                    %Assign the event function
                    funcEve{i} ...
                        = @(params,t,states) ...
                          getExTaEventTemperature(params,t,states);
                
                end
                %---------------------------------------------------------%
                
            %If we have an event at the extract stream
            elseif eveInExSt == 1
                
                %---------------------------------------------------------%            
                %Depending on the event type, assign the corresponding
                %event function for the step
                
                %If we have the sum of the light key mole fractions
                if eveTypeMolFrac == 1
                
                    %Notify the user that the event is not supported
                    noteEventNotReady(funcId);
                      
                %If we have the cumulative sum of the light key mole
                %fractions
                elseif eveTypeMolFracCum == 1
                    
                    %Assign the event function
                    funcEve{i} ...
                        = @(params,t,states) ...
                          getExStEventMoleFracCum(params,t,states);                    
                    
                %If we have the pressure in the unit
                elseif eveTypePres == 1
                    
                    %Notify the user that the event is not supported
                    noteEventNotReady(funcId);
                    
                %If we have the temperature in the unit
                elseif eveTypeTemp == 1
                    
                    %Notify the user that the event is not supported
                    noteEventNotReady(funcId);
                
                end
                %---------------------------------------------------------% 
                                            
            end
            %-------------------------------------------------------------%
            
        end
        %-----------------------------------------------------------------%
        
    end                  
    %---------------------------------------------------------------------%                     
     
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%