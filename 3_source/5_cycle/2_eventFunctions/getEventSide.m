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
%Function   : getEventSide.m
%Source     : common
%Description: a function that sets up the optin structure for the ode 
%             solver.
%Inputs     : params       - a struct containing simulation parameters.
%             nS           - the current step in a given PSA cycle
%Outputs    : eveSide      - the scalar value of -1 or 1. -1 denotes that
%                            the event function value starts from a 
%                            negative number and heads towards zero. 1
%                            denotes that the event function value starts
%                            from a positive number and heads towards zero.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function eveSide = getEventSide(params,nS)

    %---------------------------------------------------------------------%    
    %Define known quantities
    
    %Name the function ID
    %funcId = 'getEventSide.m';    
    
    %Unpack params              
    eveLoc   = params.eveLoc  ;
    eveUnit  = params.eveUnit ;
    sStepCol = params.sStepCol;
    %---------------------------------------------------------------------%                            
   
    
    
    %---------------------------------------------------------------------%
    %Get the event information for the current step
    
    %Get the unit of the current event
    eveUnitCurr = eveUnit{nS};
    
    %Get the location of the current event
    eveLocCurr = eveLoc{nS};      
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Check the logics for the event location
    
    %Is the event happening in adsorber 1?
    eveAds1True = contains(eveLocCurr,'Adsorber_1');

    %Is the event happening in adsorber 2?
    eveAds2True = contains(eveLocCurr,'Adsorber_2');
    
    %Is the event happening in the feed tank?
    eveFeTaTrue = contains(eveLocCurr,'Feed_Tank');
    
    %Is the event happening in the feed stream?
    eveFeStTrue = contains(eveLocCurr,'Feed_Stream');
    
    %Is the event happening in the Raffinate tank?
    eveRaTaTrue = contains(eveLocCurr,'Raffinate_Tank');
    
    %Is the event happening in the Raffinate stream?
    eveRaStTrue = contains(eveLocCurr,'Raffinate_Stream');
    
    %Is the event happening in the Extract tank?
    eveExTaTrue = contains(eveLocCurr,'Extract_Tank');
    
    %Is the event happening in the Extract stream?
    eveExStTrue = contains(eveLocCurr,'Extract_Stream');    
    %---------------------------------------------------------------------%
    

    
    %---------------------------------------------------------------------%
    %Check the logics for the event unit
    
    %Event unit the sum of the light key mole fraction
    eveUnitSumLkMolFracTrue ...
        = contains(eveUnitCurr,'Sum_LK_Mol_Frac_[-]');
    
    %Event unit the cumulative sum of the light key mole fraction
    eveUnitCumSumLkMolFracTrue ...
        = contains(eveUnitCurr,'Cum_Sum_LK_Mol_Frac_[-]');
    
    %Event unit the pressure
    eveUnitPresTrue ...
        = contains(eveUnitCurr,'Pressure');
    
    %Event unit the temperature
    eveUnitTempTrue ...
        = contains(eveUnitCurr,'Temperature');
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Decide on which side the event should happen
    
    %When the event happens inside the first adsorber
    if eveAds1True
        
        %-----------------------------------------------------------------%
        %Decide on which side the event should happen at the location
        
        %Get the current step in the first adsorber
        sStepColCurr = sStepCol{1,nS};
        
        %Check to see if the unit is the sum of the light key mole fraction
        if eveUnitSumLkMolFracTrue
                                                
            %The mole fraction threshold should always be approached from
            %the positive side: i.e., (current - threshold) > 0
            eveSide = 1;
        
        %Check to see if the unit is the cumulative sum of the light key 
        %mole fraction
        elseif eveUnitCumSumLkMolFracTrue
            
            %The mole fraction threshold should always be approached from
            %the positive side: i.e., (current - threshold) > 0
            eveSide = 1;
        
        %Check to see if the unit is the pressure
        elseif eveUnitPresTrue
            
            %Check to see if we are repressurizing
            if contains(sStepColCurr,'RP')
                
                %The pressure threshold should be approached from the
                %negative side: i.e., (current - threshold) < 0
                eveSide = -1;
            
            %Check to see if we are depressurizing
            elseif contains(sStepColCurr,'DP')
                
                %The pressure threshold should be approached from the
                %positive side: i.e., (current - threshold) > 0
                eveSide = +1;
            
            %Otherwise, e.g., equalization,
            else
                
                %Let the event happen on the designated side
                eveSide = 0;
            
            end
            
        %Check to see if the unit is the temperature
        elseif eveUnitTempTrue

            %Let the event happen on either side
            eveSide = 0;
        
        %Otherwise, let the event take place from both sides
        else
        
            %Let the event happen on either side
            eveSide = 0;
        
        end
        %-----------------------------------------------------------------%
    
    %When the event happens inside the second adsorber
    elseif eveAds2True
        
        %-----------------------------------------------------------------%
        %Decide on which side the event should happen at the location
        
        %Get the current step in the second adsorber
        sStepColCurr = sStepCol{2,nS};
        
        %Check to see if the unit is the sum of the light key mole fraction
        if eveUnitSumLkMolFracTrue
                                                
            %The mole fraction threshold should always be approached from
            %the positive side: i.e., (current - threshold) > 0
            eveSide = 1;
        
        %Check to see if the unit is the cumulative sum of the light key 
        %mole fraction
        elseif eveUnitCumSumLkMolFracTrue
            
            %The mole fraction threshold should always be approached from
            %the positive side: i.e., (current - threshold) > 0
            eveSide = 1;
        
        %Check to see if the unit is the pressure
        elseif eveUnitPresTrue
            
            %Check to see if we are repressurizing
            if contains(sStepColCurr,'RP')
                
                %The pressure threshold should be approached from the
                %negative side: i.e., (current - threshold) < 0
                eveSide = -1;
            
            %Check to see if we are depressurizing
            elseif contains(sStepColCurr,'DP')
                
                %The pressure threshold should be approached from the
                %positive side: i.e., (current - threshold) > 0
                eveSide = +1;
            
            %Otherwise, e.g., equalization,
            else
                
                %Let the event happen on the designated side
                eveSide = 0;
            
            end
            
        %Check to see if the unit is the temperature
        elseif eveUnitTempTrue

            %Let the event happen on either side
            eveSide = 0;
        
        %Otherwise, let the event take place from both sides
        else
        
            %Let the event happen on either side
            eveSide = 0;
        
        end 
        %-----------------------------------------------------------------%
        
    %When the event happens inside the feed tank
    elseif eveFeTaTrue
        
        %-----------------------------------------------------------------%
        %Decide on which side the event should happen at the location
        
        %Check to see if the unit is the sum of the light key mole fraction
        if eveUnitSumLkMolFracTrue
                                                
            %Let the event happen on either side
            eveSide = 0;
        
        %Check to see if the unit is the cumulative sum of the light key 
        %mole fraction
        elseif eveUnitCumSumLkMolFracTrue
                        
            %Let the event happen on either side
            eveSide = 0;
        
        %Check to see if the unit is the pressure
        elseif eveUnitPresTrue
            
            %Let the event happen on either side
            eveSide = 0;
        
        %Check to see if the unit is the temperature
        elseif eveUnitTempTrue

            %Let the event happen on either side
            eveSide = 0;
        
        %Otherwise, let the event take place from both sides
        else
        
            %Let the event happen on either side
            eveSide = 0;
        
        end                
        %-----------------------------------------------------------------%
    
    %When the event happens inside the feed stream
    elseif eveFeStTrue
        
        %-----------------------------------------------------------------%
        %Decide on which side the event should happen at the location
        
        %Check to see if the unit is the sum of the light key mole fraction
        if eveUnitSumLkMolFracTrue

            %Let the event happen on either side
            eveSide = 0;
        
        %Check to see if the unit is the cumulative sum of the light key 
        %mole fraction
        elseif eveUnitCumSumLkMolFracTrue            
            
            %Let the event happen on either side
            eveSide = 0;
        
        %Check to see if the unit is the pressure
        elseif eveUnitPresTrue

            %Let the event happen on either side
            eveSide = 0;
        
        %Check to see if the unit is the temperature
        elseif eveUnitTempTrue

            %Let the event happen on either side
            eveSide = 0;
        
        %Otherwise, let the event take place from both sides
        else
        
            %Let the event happen on either side
            eveSide = 0;
        
        end
        %-----------------------------------------------------------------%
        
    %When the event happens inside the raffinate tank
    elseif eveRaTaTrue
    
        %-----------------------------------------------------------------%
        %Decide on which side the event should happen at the location
        
        %Check to see if the unit is the sum of the light key mole fraction
        if eveUnitSumLkMolFracTrue

            %The mole fraction threshold should always be approached from
            %the positive side: i.e., (current - threshold) > 0
            eveSide = +1;
        
        %Check to see if the unit is the cumulative sum of the light key 
        %mole fraction
        elseif eveUnitCumSumLkMolFracTrue
                        
            %The cumulative mole fraction threshold should always be 
            %approached from the positive side: 
            %i.e., (current - threshold) > 0
            eveSide = +1;
        
        %Check to see if the unit is the pressure
        elseif eveUnitPresTrue
            
            %Let the event happen on either side
            eveSide = 0;
        
        %Check to see if the unit is the temperature
        elseif eveUnitTempTrue
                                    
            %Let the event happen on either side
            eveSide = 0;
        
        %Otherwise, let the event take place from both sides
        else
        
            %Let the event happen on either side
            eveSide = 0;
        
        end
        %-----------------------------------------------------------------%
        
    %When the event happens inside the raffinate stream
    elseif eveRaStTrue
        
        %-----------------------------------------------------------------%
        %Decide on which side the event should happen at the location
        
        %Check to see if the unit is the sum of the light key mole fraction
        if eveUnitSumLkMolFracTrue
            
            %The mole fraction threshold should always be approached from
            %the positive side: i.e., (current - threshold) > 0
            eveSide = +1;
        
        %Check to see if the unit is the cumulative sum of the light key 
        %mole fraction
        elseif eveUnitCumSumLkMolFracTrue
                        
            %The cumulative mole fraction threshold should always be 
            %approached from the positive side: 
            %i.e., (current - threshold) > 0
            eveSide = +1;
        
        %Check to see if the unit is the pressure
        elseif eveUnitPresTrue
            
            %Let the event happen on either side
            eveSide = 0;
        
        %Check to see if the unit is the temperature
        elseif eveUnitTempTrue
            
            %Let the event happen on either side
            eveSide = 0;
        
        %Otherwise, let the event take place from both sides
        else
        
            %Let the event happen on either side
            eveSide = 0;
        
        end
        %-----------------------------------------------------------------%
        
    %When the event happens inside the extract tank
    elseif eveExTaTrue
        
        %-----------------------------------------------------------------%
        %Decide on which side the event should happen at the location
        
        %Check to see if the unit is the sum of the light key mole fraction
        if eveUnitSumLkMolFracTrue
            
            %The mole fraction threshold should always be approached from
            %the positive side: i.e., (current - threshold) > 0
            eveSide = +1;
        
        %Check to see if the unit is the cumulative sum of the light key 
        %mole fraction
        elseif eveUnitCumSumLkMolFracTrue
            
            %The cumulative mole fraction threshold should always be 
            %approached from the positive side: 
            %i.e., (current - threshold) > 0
            eveSide = +1;
        
        %Check to see if the unit is the pressure
        elseif eveUnitPresTrue
            
            %Let the event happen on either side
            eveSide = 0;
        
        %Check to see if the unit is the temperature
        elseif eveUnitTempTrue
            
            %Let the event happen on either side
            eveSide = 0;
        
        %Otherwise, let the event take place from both sides
        else
        
            %Let the event happen on either side
            eveSide = 0;
        
        end
        %-----------------------------------------------------------------%
        
    %When the event happens inside the extract stream
    elseif eveExStTrue
        
        %-----------------------------------------------------------------%
        %Decide on which side the event should happen at the location
        
        %Check to see if the unit is the sum of the light key mole fraction
        if eveUnitSumLkMolFracTrue
            
            %The mole fraction threshold should always be approached from
            %the positive side: i.e., (current - threshold) > 0
            eveSide = +1;
        
        %Check to see if the unit is the cumulative sum of the light key 
        %mole fraction
        elseif eveUnitCumSumLkMolFracTrue
            
            %The cumulative mole fraction threshold should always be 
            %approached from the positive side: 
            %i.e., (current - threshold) > 0
            eveSide = +1;
        
        %Check to see if the unit is the pressure
        elseif eveUnitPresTrue
            
            %Let the event happen on either side
            eveSide = 0;
        
        %Check to see if the unit is the temperature
        elseif eveUnitTempTrue
            
            %Let the event happen on either side
            eveSide = 0;
        
        %Otherwise, let the event take place from both sides
        else
        
            %Let the event happen on either side
            eveSide = 0;
        
        end        
        %-----------------------------------------------------------------%
        
    %Otherwise, let the event be defined as happening from either side,
    %i.e., + or - side, by default
    else
    
        %-----------------------------------------------------------------%
        %Decide on which side the event should happen at the location
        
        %Let the event happen on either side
        eveSide = 0;
        %-----------------------------------------------------------------%
        
    end
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%