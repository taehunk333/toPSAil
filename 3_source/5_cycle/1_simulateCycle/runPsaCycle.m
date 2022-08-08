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
%Code last modified on : 2022/8/8/Monday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : runPsaCycle.m
%Source     : common
%Description: Given all the information in params, this function simulates
%             a given PSA process by obtainining the solution of the
%             dynamic PSA process model through the usage of a
%             state-of-the-art ODE solver. The solution technique
%             implemented here is called the method of lines.
%Inputs     : params       - a struct containing simulation parameters.
%Outputs    : sol          - a struct containing all the properties of the
%                            columns and tanks for all the steps for a
%                            given PSA cycle being simulated.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sol = runPsaCycle(params)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Define function ID
    %funcId = 'runPsaCycle.m';
    
    %Unpack params
    iStates    = params.initStates;
    nCycles    = params.nCycles   ;
    nSteps     = params.nSteps    ;
    nTiPts     = params.nTiPts    ;    
    sStepCol   = params.sStepCol  ;
    nStatesT   = params.nStatesT  ;
    numZero    = params.numZero   ;
    timeSpan   = params.timeSpan  ;
    nCols      = params.nCols     ;
    nColStT    = params.nColStT   ;
    nComs      = params.nComs     ;
    inShFeTa   = params.inShFeTa  ;
    inShRaTa   = params.inShRaTa  ;
    inShExTa   = params.inShExTa  ;
    nFeTaStT   = params.nFeTaStT  ;
    nRaTaStT   = params.nRaTaStT  ;
    nExTaStT   = params.nExTaStT  ;
    inShComp   = params.inShComp  ;
    inShVac    = params.inShVac   ;
    maxNoBC    = params.maxNoBC   ;
    funcVol    = params.funcVol   ;   
    funcCss    = params.funcCss   ;
    eveColNo   = params.eveColNo  ;
    tiScaleFac = params.tiScaleFac;
    
    %Calculate needed quantities
    stepTimes = timeSpan*tiScaleFac;
    %---------------------------------------------------------------------%
    
    
        
    %---------------------------------------------------------------------%
    %Initialize solution arrays
    
    %Initialize the current step counter
    currStep = 1;    
    
    %Initialize the initial time
    initTime = 0;
    
    %Initialize the css numerical array inside a solution struct
    sol.css    = zeros(nCycles+1,1);   
    
    %Initialize the vector checking for a triggered event
    sol.flags.event = zeros(nCycles*nSteps,1);
    
    %Initialize the struct for performance metrics
    sol.perMet.productMolesRaff = zeros(nCycles,nComs)  ;
    sol.perMet.productMolesExtr = zeros(nCycles,nComs)  ;
    sol.perMet.wasteMolesRaff   = zeros(nCycles,nComs)  ;
    sol.perMet.wasteMolesExtr   = zeros(nCycles,nComs)  ;
    sol.perMet.productPurity    = zeros(nCycles,nComs)  ; 
    sol.perMet.productRecovery  = zeros(nCycles,nComs)  ;
    sol.perMet.productivity     = zeros(nCycles,maxNoBC);
    sol.perMet.energyEfficiency = zeros(nCycles,maxNoBC);
    
    %Initialize the initial condition row vector for the previous cycle and
    %for the current cycle
    iCondPrev = zeros(1,nStatesT);
    %---------------------------------------------------------------------%
    
    
            
    %---------------------------------------------------------------------%
    %Simulate all the steps in a scheduled PSA cycle
    
    %for all cycles
    for nCy = 1 : nCycles
                                        
        %-----------------------------------------------------------------%
        %Compute a cyclic steady state (CSS) convergence
                        
        %Save the current initial condition
        iCondCurr = iStates;

        %Get the cyclic steady state convergence using L2-Norm
        sol.css(nCy) = funcCss(params,iCondCurr,iCondPrev);    

        %Update the previous initial condition using the current initial
        %condition
        iCondPrev = iCondCurr;            
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Simulate steps in a given cycle only when we need to
                
        %When the CSS convergence is not attained or we are at the first
        %cycle,
        if sol.css(nCy) >= numZero
            
            %-------------------------------------------------------------%
            %for each step in a PSA cycle
            for nS = 1 : nSteps
                
                %---------------------------------------------------------%
                %Determine the step information

                %Compute the current step number (jth step) in ith cycle
                currStepNum = rem(currStep,nSteps);

                %Make sure that the last step is counted as a non-zero 
                %value
                if nS == nSteps
                    
                    %Update the last step to be 
                    currStepNum = nSteps;  
                    
                end
                %---------------------------------------------------------%
                
  
                                
                %---------------------------------------------------------%
                %Define the time span                
                    
                %Define the time span based on the user supplied or
                %equilbrium calculated values
                tDom = [0,timeSpan(nS)];                                
                %---------------------------------------------------------%
                
                
                
                %---------------------------------------------------------%
                %Simulate the step
                
                %Set the number of time points within the right hand side
                %function
                params.nRows = 1;
                
                %Run runPsaCycleStep.m
                [stTimePts,stStates,flags] ...
                    = runPsaCycleStep(params,iStates,tDom,nS,nCy);
%                 [stTimePts,stStates,flags] ...
%                     = runPsaCycleStepSTB(params,iStates,tDom,nS,nCy);             
                %---------------------------------------------------------%



                %---------------------------------------------------------%
                %Unpack the states solutions
                
                %Grab the number of time points
                params.nRows = length(stTimePts);

                %Create an object for the columns
                units.col = makeColumns(params,stStates);

                %Create an object for the feed tank
                units.feTa = makeFeedTank(params,stStates);

                %Create an object for the raffinate product tank
                units.raTa = makeRaffTank(params,stStates);
                
                %Create an object for the extract roduct tank
                units.exTa = makeExtrTank(params,stStates);
                
                %Make the columns to interact
                units = makeCol2Interact(params,units,nS);
                %---------------------------------------------------------%



                %---------------------------------------------------------%
                %Calculate associated volumetric flow rates for the 
                %currently interacting units in the flow sheet

                %Based on the volumetric flow function handle, obtain the 
                %corresponding volumetric flow rates                
                units = funcVol(params,units,nS);  
                
                %Unpack units
                col  = units.col ;
                feTa = units.feTa;
                raTa = units.raTa;
                exTa = units.exTa;
                raWa = units.raWa;
                exWa = units.exWa;
                %---------------------------------------------------------%              
                
                
                
                %---------------------------------------------------------%              
                %Grab moles associated with the boundary flows
                                
                %Add cumulative moles entering or leaving column boundaries
                
                %For each column
                for i = 1 :nCols
                    
                    %Add cumulative moles at the feed-end
                    col.(append('n',int2str(i))).cumMol.feed ...
                        = stStates(:,nColStT*i-2*nComs+1:nColStT*i-nComs);
                   
                    %Add cumulative moles at the product-end
                    col.(append('n',int2str(i))).cumMol.prod ...
                        = stStates(:,nColStT*i-nComs+1:nColStT*i);
                               
                end
                
                %Add cumulative moles entering or leaving the feed tank
                %boundaries
                
                %Add cumulative moles at the feed-end
                feTa.n1.cumMol.feed ...
                    = stStates(:, ...
                               inShFeTa+nFeTaStT-nComs+1: ...
                               inShFeTa+nFeTaStT);                                       
                                
                %Add cumulative moles entering or leaving the raffinate 
                %product tank boundaries                    
                raTa.n1.cumMol.prod ...
                    = stStates(:, ...
                               inShRaTa+nRaTaStT-2*nComs+1: ...
                               inShRaTa+nRaTaStT-nComs); 
                           
                %Add cumulative moles entering or leaving the extract 
                %product tank boundaries                    
                exTa.n1.cumMol.prod ...
                    = stStates(:, ...
                               inShExTa+nExTaStT-2*nComs+1: ...
                               inShExTa+nExTaStT-nComs); 
                           
                %Add cumulative moles exiting the system through the
                %raffinate waste stream
                raWa.n1.cumMol.waste ...
                    = stStates(:, ...
                               inShRaTa+nRaTaStT-nComs+1: ...
                               inShRaTa+nRaTaStT); 
                           
                %Add cumulative moles exiting the system through the
                %extract waste stream
                exWa.n1.cumMol.waste ...
                    = stStates(:, ...
                               inShExTa+nExTaStT-nComs+1: ...
                               inShExTa+nExTaStT); 
                %---------------------------------------------------------%              

                

                %---------------------------------------------------------%
                %Save the simulation results 

                %Save the numerical values for the time points for the 
                %current step. We start from the terminal time point of the
                %previous step.
                timePts = stTimePts+initTime;

                %Save the flag (as a string stored inside cell array) in a
                %given PSA cycle
                timeFlags = cell(nTiPts,nCols);
                
                %For each column
                for i = 1 : nCols  
                    
                    %Update the time flag
                    timeFlags(:,i) = {sStepCol{i,currStepNum}}; 
                    
                end
                %---------------------------------------------------------%



                %---------------------------------------------------------%
                %Update the solution structure

                %Add time points for the step as a solution to a struct
                sol.(append('Step',int2str(currStep))).timePts ...
                    = timePts';

                %Add time flags for the step as a solution to a struct
                sol.(append('Step',int2str(currStep))).timeFlags ...
                    = timeFlags;

                %Add column properties
                sol.(append('Step',int2str(currStep))).col ...
                    = col;

                %Add the feed tank properties
                sol.(append('Step',int2str(currStep))).feTa ...
                    = feTa;

                %Add the raffinate product tank properties
                sol.(append('Step',int2str(currStep))).raTa ...
                    = raTa;
                
                %Add the extract product tank properties
                sol.(append('Step',int2str(currStep))).exTa ...
                    = exTa;
                
                %Add the raffinate waste stream properties
                sol.(append('Step',int2str(currStep))).raWa ...
                    = raWa;
                
                %Add the extract waste stream properties
                sol.(append('Step',int2str(currStep))).exWa ...
                    = exWa;
                
                %For the compressor 
                
                %Add energy expenditure from the compression of the feed
                sol.(append('Step',int2str(currStep))).comp.n1.ener ...
                    = stStates(:,inShComp+1);
                
                %Add energy expenditure from the compression of extract 
                %product
                sol.(append('Step',int2str(currStep))).comp.n2.ener ...
                    = stStates(:,inShComp+2);
                
                %For the vacuum pump
                
                %Add energy expenditure from the pump of the column
                sol.(append('Step',int2str(currStep))).pump.n1.ener ...
                    = stStates(:,inShVac+1);
                
                %Assign flags for an event for the current step, if any
                sol.flags.event(currStep) ...
                    = flags.event;           
                %---------------------------------------------------------%


                
                %---------------------------------------------------------%
                %Save the performance metrics at the end of a given cycle
                
                %If we just finished simulating the last step in a given 
                %PSA cycle
                if currStepNum == nSteps
                
                    %Calcualte the performance metrics and save the results
                    sol = getPerformanceMetrics(params,sol,nS,nCy);                
                    
                end
                %---------------------------------------------------------%
                
                
                
                %---------------------------------------------------------%
                %Save an information for the next step
                                
                %If we are at the last step,
                if currStep == nSteps*nCycles
                    
                    %Get the initial state of the (nCycles+1)th PSA cycle
                    iCondCurr = convert2TermStates(params,stStates);
                    
                    %Save the information about the last step
                    sol.lastStep = currStep;
                
                %If we are not at the last step,
                else
                    
                    %Get the initial condition for the next step
                    iStates = convert2TermStates(params,stStates);

                    %Get the initial time for the next step
                    initTime = timePts(end);                                        
                    
                    %Update the step counter
                    currStep = currStep+1;
                    
                end                                
                %---------------------------------------------------------%
                

                
                %---------------------------------------------------------%
                %Print a step information

                %Print the simulation information                
                fprintf("\n*******************************************\n"); 
                fprintf("Cycle No.%d, Step No.%d is finished. \n",nCy,nS) ;
                fprintf("*Adsorber Steps : ")                            ;
                
                %For each adsorption column,
                for i = 1 : nCols
                    
                    %Print a step name associated with ith column
                    fprintf("%s ",sStepCol(i,nS));
                    
                end                        
                                                
                %Print if an event happened?
                
                %Find the event column number
                eCol = eveColNo(currStepNum);
                
                %Calculate actual step duration
                eTi = round(stTimePts(end)*tiScaleFac); %round to a 
                                                        %nearest integer
                
                %Get the requested step duration
                eTi0 = round(stepTimes(currStepNum));
                
                %Event did not happen for the current step
                if flags.event == 0 && eCol ~= 0
                     
                    %Print the information
                    fprintf("\n*Step duration  : %d(%d) seconds",eTi,eTi0);
                    fprintf("\n*No event happened for the step")          ;          
                
                %No Event was requested
                elseif flags.event == 0 && eCol == 0
                    
                    %Print the information
                    fprintf("\n*Step duration  : %d(%d) seconds",eTi,eTi0);
                    fprintf("\n*The step was a time driven step")         ;           
                    
                %Event did happen
                elseif flags.event == 1                                        
                    
                    %Print the information
                    fprintf("\n*Step duration  : %d(%d) seconds",eTi,eTi0);
                    fprintf("\n*An event happened in column No.%d",eCol)  ;
                    
                end                
                
                %Print the line divider
                fprintf("\n*******************************************\n");
                %---------------------------------------------------------%                                

            end
            %-------------------------------------------------------------%
        
        %When cyclic steady state is attained
        elseif sol.css(nCy) < numZero            
            
            %Print the simulation information
            fprintf("\n*******************************************\n")   ;
            fprintf("CSS convergence at %dth PSA Cycle. \n",sol.css(nCy));    
            fprintf("*******************************************\n")     ;
            
            %Save the information about the last step
            sol.lastStep = currStep-1;
            
            %Return to the invoking function
            return
            
        end        
        %-----------------------------------------------------------------%
        
    end   
    %---------------------------------------------------------------------%                
    
    
    
    %---------------------------------------------------------------------%                
    %Print out the exiting message for the function
    
    %Print out the message saying that the desired number of cycles have
    %been simulated without attaining the cyclic steady state
    
    %Print the simulation information
    fprintf("\n*******************************************\n");
    fprintf("Simulated %d PSA cycles. \n",nCy)                ;
    fprintf("*******************************************\n")  ;
    %---------------------------------------------------------------------%                
    
    
    
    %---------------------------------------------------------------------%                
    %Compute a cyclic steady state (CSS) convergence for the (nCycle+1)th
    %PSA cycle    

    %Get the cyclic steady state convergence using L2-Norm
    sol.css(nCy+1) = funcCss(params,iCondCurr,iCondPrev);   
    %---------------------------------------------------------------------%                
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%