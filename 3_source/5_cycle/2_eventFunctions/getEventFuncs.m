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
%Code last modified on : 2022/3/3/Thursday
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
    nSteps     = params.nSteps    ;     
    sStepCol   = params.sStepCol  ;      
    eveStep    = params.eveStep   ;
    eveColNo   = params.eveColNo  ;
    flowDirCol = params.flowDirCol;
    %---------------------------------------------------------------------%                                  
    
    
    
    %---------------------------------------------------------------------%                     
    %Initialize solution arrays
    
    %Initialize a cell array containing the event functions
    funcEve = cell(nSteps,1);    
    %---------------------------------------------------------------------%                                                                                                           
    
    
    
    %%%%%%%%%%THIS FUNCTION SHOULD BE UPDATED ONCE DEBUGGING FOR THE%%%%%%%
    %%%%%%%%%%NONISOTHEMRAL CASE IS FINISHED                        %%%%%%%
    
    
    
    %---------------------------------------------------------------------%                     
    %Specification of the event functions for the event driven mode
    
    %For all steps in a given PSA cycle, for each step,
    %for all the steps in a given PSA cycle
    for i = 1 : nSteps

        %-----------------------------------------------------------------%
        %Determine quantities to be used for the current iteration in
        %the for-loop

        %Define the current column number on which the event would
        %trigger            
        eveColNoCurr = eveColNo(i);     
        
        %Get the event flow direction
        
        %When there is no event
        if eveStep(i) == 0
            
            %No need to define the flow direction in the column undergoing
            %the event
            
        %When there is an event
        else
            
            %Define the flow direction in the column undergoing the event
            eveFlowDir = flowDirCol(eveColNoCurr,i);
            
        end
        %-----------------------------------------------------------------%



        %-----------------------------------------------------------------%
        %Precondition the event status

        %Check to see if we have an event for the ith step
        if eveColNoCurr == 0

            %If we do not have an event, no event function is assigned   
            funcEve{i} = [];
        %-----------------------------------------------------------------%



        %-----------------------------------------------------------------%
        %If the step is a re-pressurization step            
        elseif sStepCol{eveColNoCurr,i} == "RP"
            
            %If not a event driven mode,
            if eveStep(i) == 0

                %No event function is assigned   
                funcEve{i} = [];

            %If the first event mode,                 
            elseif eveStep(i) == 1
                
                %If we have a counter-current flow
                if eveFlowDir == 1
                    
                    
                    
                %If we have a co-current flow
                elseif eveFlowDir == 0
                    
                    
                    
                    
                end

                %Event function is assigned
                funcEve{i} = @(params,t,states,nS,nCy) ...
                             getRpEvent1(params,t,states,nS,nCy);

            %If the second event mode,    
            elseif eveStep(i) == 2    

                %Event function under development
                msg = 'The event function is under development.';
                msg = append(funcId,': ',msg);
                error(msg);  

                %Event function is assigned
                funcEve{i} = @(params,t,states,nS,nCy) ...
                             getRpEvent2(params,t,states,nS,nCy);

            %If the third event mode,    
            elseif eveStep(i) == 3  

                %Event function under development
                msg = 'The event function isunder development.';
                msg = append(funcId,': ',msg);
                error(msg); 

                %Event function is assigned
                funcEve{i} = @(params,t,states,nS,nCy) ...
                             getRpEvent3(params,t,states,nS,nCy);    

            end                                    
        %-----------------------------------------------------------------%                             



        %-----------------------------------------------------------------%            
        %If the step is a high pressure feed step
        elseif sStepCol{eveColNoCurr,i} == "HP" 

            %If not a event driven mode,
            if eveStep(i) == 0

                %No event function is assigned  
                funcEve{i} = [];

            %If the first event mode,    
            elseif eveStep(i) == 1
                
                %If we have a counter-current flow
                if eveFlowDir == 1
                    
                    
                    
                %If we have a co-current flow
                elseif eveFlowDir == 0
                    
                    
                    
                    
                end
                
                %Event function is assigned
                funcEve{i} = @(params,t,states,nS,nCy) ...
                             getHpEvent1(params,t,states,nS,nCy);

            %If the second event mode,    
            elseif eveStep(i) == 2    
                
                %If we have a counter-current flow
                if eveFlowDir == 1
                    
                    
                    
                %If we have a co-current flow
                elseif eveFlowDir == 0
                    
                    
                    
                    
                end

                %Event function is assigned
                funcEve{i} = @(params,t,states,nS,nCy) ...
                             getHpEvent2(params,t,states,nS,nCy);

            %If the third event mode,    
            elseif eveStep(i) == 3    
                
                %If we have a counter-current flow
                if eveFlowDir == 1
                    
                    
                    
                %If we have a co-current flow
                elseif eveFlowDir == 0
                    
                    
                    
                    
                end

                %Event function is assigned
                funcEve{i} = @(params,t,states,nS,nCy) ...
                             getHpEvent3(params,t,states,nS,nCy); 

            end                            
        %-----------------------------------------------------------------%                             



        %-----------------------------------------------------------------%
        %If the step is a depressurization step
        elseif sStepCol{eveColNoCurr,i} == "DP" 
            
            %If not a event driven mode,
            if eveStep(i) == 0

                %No event function is assigned  
                funcEve{i} = [];

            %If the first event mode,    
            elseif eveStep(i) == 1
                
                %If we have a counter-current flow
                if eveFlowDir == 1
                    
                    
                    
                %If we have a co-current flow
                elseif eveFlowDir == 0
                    
                    
                    
                    
                end

                %Event function is assigned
                funcEve{i} = @(params,t,states,nS,nCy) ...
                             getDpEvent1(params,t,states,nS,nCy);

            %If the second event mode,    
            elseif eveStep(i) == 2    

                %Event function under development
                msg = 'The event function isunder development.';
                msg = append(funcId,': ',msg);
                error(msg); 

                %Event function is assigned
                funcEve{i} = @(params,t,states,nS,nCy) ...
                             getDpEvent2(params,t,states,nS,nCy);

            %If the third event mode,    
            elseif eveStep(i) == 3   

                %Event function under development
                msg = 'The event function isunder development.';
                msg = append(funcId,': ',msg);
                error(msg); 

                %Event function is assigned
                funcEve{i} = @(params,t,states,nS,nCy) ...
                             getDpEvent3(params,t,states,nS,nCy); 

            end   
        %-----------------------------------------------------------------%                             



        %-----------------------------------------------------------------%
        %If the step is a low pressure purge step
        elseif sStepCol{eveColNoCurr,i} == "LP" 
            
            %If not a event driven mode,
            if eveStep(i) == 0

                %No event function is assigned  
                funcEve{i} = [];

            %If the first event mode,    
            elseif eveStep(i) == 1
                
                %If we have a counter-current flow
                if eveFlowDir == 1
                    
                    
                    
                %If we have a co-current flow
                elseif eveFlowDir == 0
                    
                    
                    
                    
                end
                
                %Event function is assigned
                funcEve{i} = @(params,t,states,nS,nCy) ...
                             getLpEvent1(params,t,states,nS,nCy);

            %If the second event mode,    
            elseif eveStep(i) == 2    
                
                %If we have a counter-current flow
                if eveFlowDir == 1
                    
                    
                    
                %If we have a co-current flow
                elseif eveFlowDir == 0
                    
                    
                    
                    
                end
                
                %Event function is assigned
                funcEve{i} = @(params,t,states,nS,nCy) ...
                             getLpEvent2(params,t,states,nS,nCy);

            %If the third event mode,    
            elseif eveStep(i) == 3 

                %Event function under development
                msg = 'The event function isunder development.';
                msg = append(funcId,': ',msg);
                error(msg); 

                %Event function is assigned
                funcEve{i} = @(params,t,states,nS,nCy) ...
                             getLpEvent3(params,t,states,nS,nCy); 

            end   
        %-----------------------------------------------------------------%                             



        %-----------------------------------------------------------------%
        %If the step is a pressure equalization step
        elseif sStepCol{eveColNoCurr,i} == "EQ"
            
            %If not a event driven mode,
            if eveStep(i) == 0

                %No event function is assigned   
                funcEve{i} = [];

            %If the first event mode,    
            elseif eveStep(i) == 1            
                
                %If we have a counter-current flow
                if eveFlowDir == 1
                    
                    
                    
                %If we have a co-current flow
                elseif eveFlowDir == 0
                    
                    
                    
                    
                end
                
                %Event function is assigned
                funcEve{i} = @(params,t,states,nS,nCy) ...
                             getEqEvent1(params,t,states,nS,nCy);

            %If the second event mode,    
            elseif eveStep(i) == 2    

                %Event function under development
                msg = 'The event function isunder development.';
                msg = append(funcId,': ',msg);
                error(msg); 

                %Event function is assigned
                funcEve{i} = @(params,t,states,nS,nCy) ...
                             getEqEvent2(params,t,states,nS,nCy);

            %If the third event mode,    
            elseif eveStep(i) == 3    

                %Event function under development
                msg = 'The event function isunder development.';
                msg = append(funcId,': ',msg);
                error(msg); 

                %Event function is assigned
                funcEve{i} = @(params,t,states,nS,nCy) ...
                             getEqEvent3(params,t,states,nS,nCy); 

            end   
        %-----------------------------------------------------------------%                             



        %-----------------------------------------------------------------%
        %If the step is a rest step
        elseif sStepCol{eveColNoCurr,i} == "RT" 

            %If not a event driven mode,
            if eveStep(i) == 0

                %No event function is assigned  
                funcEve{i} = [];

            %If the first event mode,    
            elseif eveStep(i) == 1

                %Event function under development
                msg = 'The event function isunder development.';
                msg = append(funcId,': ',msg);
                error(msg); 

                %Event function is assigned
                funcEve{i} = @(params,t,states,nS,nCy) ...
                             getRtEvent1(params,t,states,nS,nCy);

            %If the second event mode,    
            elseif eveStep(i) == 2    

                %Event function under development
                msg = 'The event function isunder development.';
                msg = append(funcId,': ',msg);
                error(msg); 

                %Event function is assigned
                funcEve{i} = @(params,t,states,nS,nCy) ...
                             getRtEvent2(params,t,states,nS,nCy);

            %If the third event mode,    
            elseif eveStep(i) == 3 

                %Event function under development
                msg = 'The event function isunder development.';
                msg = append(funcId,': ',msg);
                error(msg); 

                %Event function is assigned
                funcEve{i} = @(params,t,states,nS,nCy) ...
                             getRtEvent3(params,t,states,nS,nCy); 

            end   
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %If the step is a rinse step
        elseif sStepCol{eveColNoCurr,i} == "RN" 

            %If not a event driven mode,
            if eveStep(i) == 0

                %No event function is assigned  
                funcEve{i} = [];

            %If the first event mode,    
            elseif eveStep(i) == 1

                %Event function under development
                msg = 'The event function isunder development.';
                msg = append(funcId,': ',msg);
                error(msg); 

                %Event function is assigned
                funcEve{i} = @(params,t,states,nS,nCy) ...
                             getRnEvent1(params,t,states,nS,nCy);

            %If the second event mode,    
            elseif eveStep(i) == 2    

                %Event function under development
                msg = 'The event function isunder development.';
                msg = append(funcId,': ',msg);
                error(msg); 

                %Event function is assigned
                funcEve{i} = @(params,t,states,nS,nCy) ...
                             getRnEvent2(params,t,states,nS,nCy);

            %If the third event mode,    
            elseif eveStep(i) == 3 

                %Event function under development
                msg = 'The event function isunder development.';
                msg = append(funcId,': ',msg);
                error(msg); 

                %Event function is assigned
                funcEve{i} = @(params,t,states,nS,nCy) ...
                             getRnEvent3(params,t,states,nS,nCy); 

            end   
        %-----------------------------------------------------------------%

      
        
        %-----------------------------------------------------------------%    
        %If no other situations, then something must be wrong about the
        %step event specification        
        else
            
            %Event function specification went wrong!
            msg = 'The event function specification went wrong!';
            msg = append(funcId,': ',msg);
            error(msg); 
            
        end
        %-----------------------------------------------------------------%                         
        
    end                  
    %---------------------------------------------------------------------%                     
     
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%