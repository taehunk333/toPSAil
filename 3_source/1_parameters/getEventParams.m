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
%Code last modified on : 2022/1/24/Monday
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
    sStep    = params.sStep   ;
    eveCol   = params.eveColNo;
    eveStep  = params.eveStep ;
    nSteps   = params.nSteps  ;
    presBeHi = params.presBeHi;    
    %---------------------------------------------------------------------% 
    
                  
        
    %---------------------------------------------------------------------%    
    %Obtain event values
    
    %For each step
    for i = 1 : nSteps
        
        %-----------------------------------------------------------------%    
        %Get the ith step event information
        
        %Get the current event column
        eveColNoCurr = eveCol(i);                        
        %-----------------------------------------------------------------%    
        
        
        
        %-----------------------------------------------------------------%    
        %Obtain threshold values for the event functions

        %If the event is happening for re-pressurization step,
        if eveColNoCurr ~=0 && sStep{eveColNoCurr,i} == "RP"
                
            %-------------------------------------------------------------%    
            %For the first event criteria
            if eveStep(i) == 1
                                                                                
                %Event pressure for the re-pressurization
                params.eveTotPresRp = eveVal(i)/presBeHi;
            
            %For the second event criteria
            elseif eveStep(i) == 2
                
                %TBD
                
            %For the third event criteria
            elseif eveStep(i) == 3
                
                %TBD

            end
            %-------------------------------------------------------------%    
        
        %-----------------------------------------------------------------%
        
        
            
        %-----------------------------------------------------------------%    
        %If the event is happening for high pressure feed step,
        elseif eveColNoCurr ~=0 && sStep{eveColNoCurr,i} == "HP" 
            
            %-------------------------------------------------------------%    
            %For the first event criteria
            if eveStep(i) == 1
            
                %Define the breakthrough mole fraction
                params.evePrdMolFr = eveVal(i);
            
            %For the second event criteria
            elseif eveStep(i) == 2
                
                %Define the breakthrough mole fraction
                params.evePrdMolFr = eveVal(i);
                
            %For the third event criteria
            elseif eveStep(i) == 3
                
                %Define the breakthrough mole fraction
                params.evePrdMolFr = eveVal(i);

            end
            %-------------------------------------------------------------%             
        
        %-----------------------------------------------------------------%
        
        
            
        %-----------------------------------------------------------------%    
        %If the event is happening for depressurization step,
        elseif eveColNoCurr ~=0 && sStep{eveColNoCurr,i} == "DP" 
            
            %-------------------------------------------------------------%    
            %For the first event criteria
            if eveStep(i) == 1
            
                %Event pressure for the re-pressurization
                params.eveTotPresDp = eveVal(i)/presBeHi;
            
            %For the second event criteria
            elseif eveStep(i) == 2
                
                %TBD
                
            %For the third event criteria
            elseif eveStep(i) == 3
                
                %TBD

            end
            %-------------------------------------------------------------%
            
        %-----------------------------------------------------------------%
        
        
            
        %-----------------------------------------------------------------%
        %If the event is happening for low pressure purge step,
        elseif eveColNoCurr ~=0 && sStep{eveColNoCurr,i} == "LP"
            
            %-------------------------------------------------------------%    
            %For the first event criteria
            if eveStep(i) == 1
            
                %A threshold on the fraction of the product in the product
                %tank used to purge: 0 <= fraction <= 1
                params.evePrTaConTot = eveVal(i);
            
            %For the second event criteria
            elseif eveStep(i) == 2
                
                %A threshold om the heavy key efficieny factor (HKEF) at
                %the end of the low pressure purge
                params.eveHkef = eveVal(i);
                
            %For the third event criteria
            elseif eveStep(i) == 3
                
                %TBD

            end
            %-------------------------------------------------------------%
        
        %-----------------------------------------------------------------%
        
        
            
        %-----------------------------------------------------------------%                            
        %If the event is happening for equalization step,
        elseif eveColNoCurr ~=0 && sStep{eveColNoCurr,i} == "EQ"
            
            %-------------------------------------------------------------%    
            %For the first event criteria
            if eveStep(i) == 1
            
                %A threshold on the pressure swing (i.e. presBeHi-presBeLo)
                params.eveEqThr = eveVal(i);
            
            %For the second event criteria
            elseif eveStep(i) == 2
                
                %TBD
                
            %For the third event criteria
            elseif eveStep(i) == 3
                
                %TBD

            end
            %-------------------------------------------------------------%
         
        %-----------------------------------------------------------------%
            
            
            
        %-----------------------------------------------------------------%                
        %If the event is happening for rest step,
        elseif eveColNoCurr ~=0 && sStep{eveColNoCurr,i} == "RT"
            
            %-------------------------------------------------------------%    
            %For the first event criteria
            if eveStep(i) == 1
            
                %TBD
            
            %For the second event criteria
            elseif eveStep(i) == 2
                
                %TBD
                
            %For the third event criteria
            elseif eveStep(i) == 3
                
                %TBD

            end
            %-------------------------------------------------------------%    
            
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%                
        %If the event is happening for rinse step,
        elseif eveColNoCurr ~=0 && sStep{eveColNoCurr,i} == "RN"
            
            %-------------------------------------------------------------%    
            %For the first event criteria
            if eveStep(i) == 1
            
                %TBD
            
            %For the second event criteria
            elseif eveStep(i) == 2
                
                %TBD
                
            %For the third event criteria
            elseif eveStep(i) == 3
                
                %TBD

            end
            %-------------------------------------------------------------%    
            
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Otherwise, we do not have any event for the step
        else
            
            %Do not assign anything
            
        end
        %-----------------------------------------------------------------%    
    
    end
    %---------------------------------------------------------------------%                                                          
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%