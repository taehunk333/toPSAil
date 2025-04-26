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
%Code created on       : 2022/10/22/Saturday
%Code last modified on : 2023/01/16/Monday
%Code last modified by : Taehun Kim
%Model Release Number  : 3rd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function   : solvOdes0.m
%Source     : common
%Description: a .m function that solves the ODEs before the numerical
%             integration of the original system of ODEs for the step. The
%             two possibilities where each requires a presolve are (1) high
%             pressure feed producting raffinate product that gets sent to
%             the raffinate product tank, and (2) depressurization at the
%             feed end, where the product gets sent to the extract product
%             tank.
%Inputs     : params       - a data structure containing the simulation
%                            inputs
%             tDom         - the time span for the numerical integration of
%                            the ODEs
%             iStates      - an initial condition vector for the state
%                            variables in the system of ODEs
%             nS           - the current step number nS
%Outputs    : sol0         - a data structure containing the solution
%                            outputs
%             tDom0        - the new time span for the numerical 
%                            integration of the original set of ODEs
%             preInt       - a boolean variable that returns 1, if the 
%                            pre-numerical integration had happened
%             eveTrigUser  - a boolean that tells us if a user-supplied
%                            event has triggered or not.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [sol0,tDom0,preInt,eveTrigUser] ...
    = solvOdes0(params,tDom,iStates,nS)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Define function ID
    %funcId = 'solvOdes0.m';
    
    %Unpack params
    sStepCol      = params.sStepCol(:,nS);  
    pRatRa        = params.pRatRa        ; 
    pRatEx        = params.pRatEx        ;
    inShRaTa      = params.inShRaTa      ;  
    inShExTa      = params.inShExTa      ;
    gasConsNormEq = params.gasConsNormEq ;
    nComs         = params.nComs         ;
    bool          = params.bool          ;
    numIntSolv    = params.numIntSolv    ;
    eveLoc        = params.eveLoc{nS}    ;
    numZero       = params.numZero       ;
    %---------------------------------------------------------------------%
    
    
        
    %---------------------------------------------------------------------%
    %Check to see if we need to do pre-integration with a separate event. 
    %There are two cases: (1) raffinate product tank pressure needs to 
    %increase to a threshold, and (2) extract product tank pressure needs
    %to increase to a threshold.

    %Check to see if any of the current adsorber has a high pressure
    %feed step where the product-end effluent is heading towards the
    %raffinate product tank.
    raffTrue = sum(strcmp(sStepCol,"HP-FEE-RAF"));

    %Check to see if any of the current adsorber has a depressurization
    %step from the feed end where the effluent stream is heading towards
    %the extract product tank.
    extrTrueDp = sum(strcmp(sStepCol,"DP-EXT-XXX"));

    %Check to see if any of the current adsorber has a low-pressure purge
    %step from the feed end where the effluent stream is heading towards
    %the extract product tank.
    extrTrueLp = sum(strcmp(sStepCol,"LP-EXT-RAF"));
    
    %Obtain the raffinate tank states
    raTaGasConTot = sum(iStates(inShRaTa+1:inShRaTa+nComs));
    raTaCstrTemp  = iStates(inShRaTa+nComs+1)              ;
    
    %Obtain the extract tank states
    exTaGasConTot = sum(iStates(inShExTa+1:inShExTa+nComs));
    exTaCstrTemp  = iStates(inShExTa+nComs+1)              ;
    
    %Calculate the raffinate tank pressure
    raTaPres = raTaGasConTot.*raTaCstrTemp*gasConsNormEq;
    
    %Calculate the extract tank pressure
    exTaPres = exTaGasConTot.*exTaCstrTemp*gasConsNormEq;
    
    %Check the sign for the current pressure in the raffinate tank. If the
    %sign is negative, then we need to pressurize the tank.
    raTaSign = raTaPres-pRatRa;
    
    %When the sign is numerically zero,
    if abs(raTaSign) < numZero
        
        %Let the pre-integration to happen
        raTaSign = 0;
        
    %When the sign is numerically nonzero,        
    else
        
        %Let the sign be determined, based on the numerical value of the
        %pressure difference
        raTaSign = sign(raTaSign);
        
    end
    
    %Check the sign for the current pressure in the extract tank. If the
    %sign is negative, then we need to pressurize the tank.
    exTaSign = exTaPres-pRatEx;
    
    %When the sign is numerically zero,
    if abs(exTaSign) < numZero
        
        %Let the pre-integration to happen
        exTaSign = 0;
        
    %When the sign is numerically nonzero,        
    else
        
        %Let the sign be determined, based on the numerical value of the
        %pressure difference
        exTaSign = sign(exTaSign);
        
    end
    
    %Check the energy balance equation
    enerBalTrue = bool(5);
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %Get the information about events

    %Check to see if an additional event is required for the entire step
    secEveTrue = ~contains(eveLoc,'None');

    %No used-defined event has triggered (yet).
    eveTrigUser = 0;
    %---------------------------------------------------------------------%



    %---------------------------------------------------------------------%
    %Based on the conditions, decide if we need to do the pre-integration
        
    %If the raffinate product is flowing into the raffinate tank, but the
    %extract product is not flowing into the extract tank,
    if raffTrue == 1 && (extrTrueLp == 0 && extrTrueDp == 0)
        
        %-----------------------------------------------------------------%
        %If the pressure needs to build up
        if raTaSign < 0
            
            %-------------------------------------------------------------%
            %Update the data structure
            
            %Update the data structure with integration specific 
            %information for the given step
            params = grabParams4Step(params,nS);
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%
            %Update relevant information and define a new function handle
            %for the right-hand side
            
            %If we have another event, i.e., we have an event-driven mode, 
            if secEveTrue == 1
            
                %Set the option for the event function
                options ...
                    = odeset('Events', ...
                             @(t,states) ...
                             getRaTaEventPressureAccMult(params,t,states));
                                            
            %If it is a time-driven mode,
            else
                
                %Set the option for the event function
                options ...
                    = odeset('Events', ...
                             @(t,states) ...
                             getRaTaEventPressureAcc(params,t,states));
                
            end
            
            %When noisothermal,
            if enerBalTrue == 1
                
                %Redefine the submodel for the volumetric flow rate
                %calculations for the raffinate tank
                params.funcVolUnits ...
                    = @(params,units,nS) ...
                      calcVolFlows4UnitsFlowCtrlDT1AccRaTa(params, ...
                                                           units,nS);
                
            %When isothermal,
            elseif enerBalTrue == 0
                
                %Redefine the submodel for the volumetric flow rate
                %calculations for the raffinate tank
                params.funcVolUnits ...
                    = @(params,units,nS) ...
                      calcVolFlows4UnitsFlowCtrlDT0AccRaTa(params, ...
                                                           units,nS);
                
            end                              
            
            %Define the right-hand side function
            funcRhs = @(t,x) defineRhsFunc(t,x,params);  
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%
            %Numerically integrate the ODEs

            %Perform the numerical integration for the step
            sol0 = solvOdes(funcRhs,tDom,iStates,options,numIntSolv);
            
            %Print out the numerical integration stats
            noteNumIntStats(sol0,numIntSolv);
            
            %Check to see if an event triggered
            eventTrue = isfield(sol0,'xe') && ~isempty(sol0.xe);
            
            %When an event triggered, 
            if eventTrue
            
                %Figure out which event triggered
                eveTrig = sol0.ie;
                
                %Update the time domain
                tDom0 = [0,sol0.xe];
               
            %If no event has triggered,
            else
                
                %Let us note that no event has triggered
                eveTrig = 0;
                
                %Set the time domain equal to the original time span
                tDom0 = tDom;
                
            end
            
            %Depending on the event, print out helpful messages
            
            %When no event has triggered
            if eveTrig == 0
                
                %Print additional helpful message
                fprintf("\n*******************************************\n"); 
                fprintf("The raff. tank pressure has not reached.")       ; 
                fprintf("\n*******************************************\n");
            
            %When the raffinate tank pressure reached a threshold,
            elseif eveTrig == 1
            
                %Print additional helpful message
                fprintf("\n*******************************************\n"); 
                fprintf("The raff. tank pressure has reached.")           ; 
                fprintf("\n*******************************************\n"); 
                
            %When the user-supplied event triggered,
            elseif eveTrig == 2
                
                %Print additional helpful message
                fprintf("\n*******************************************\n"); 
                fprintf("The user-supplied event triggered first.")       ; 
                fprintf("\n*******************************************\n");

                eveTrigUser = true;
                
            end
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%
            %Update the solution information
            
            %We've done the pre-integration, regardless of an event
            %triggering or not
            preInt = 1;
            %-------------------------------------------------------------%
            
        %Otherwise,
        else
        
            %-------------------------------------------------------------%
            %Set the solution structure as an empty vector
            sol0 = [];

            %No need for us to do the pre-integration
            preInt = 0;

            %Set the new time domain
            tDom0 = tDom;
            %-------------------------------------------------------------%
        
        end
        %-----------------------------------------------------------------%
        
    %If the raffinate product is not flowing into the raffinate tank, but
    %the extract product is flowing into the extract tank, either from a
    %depressurization or from a low-pressure purge step.
    elseif raffTrue == 0 && xor(extrTrueLp == 1, extrTrueDp == 1)
        
        %-----------------------------------------------------------------%
        %If the pressure needs to build up
        if exTaSign < 0
              
            %-------------------------------------------------------------%
            %Update the data structure
            
            %Update the data structure with integration specific 
            %information for the given step
            params = grabParams4Step(params,nS);
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%
            %Update relevant information and define a new function handle
            %for the right-hand side
            
            %If we have another event, i.e., we have an event-driven mode, 
            if secEveTrue == 1
            
                %Set the option for the event function
                options ...
                    = odeset('Events', ...
                             @(t,states) ...
                             getExTaEventPressureAccMult(params,t,states));
                                            
            %If it is a time-driven mode,
            else
                
                %Set the option for the event function
                options ...
                    = odeset('Events', ...
                             @(t,states) ...
                             getExTaEventPressureAcc(params,t,states));
                
            end                                    
            
            %When noisothermal,
            if enerBalTrue == 1
                
                %Redefine the submodel for the volumetric flow rate
                %calculations for the extract tank
                params.funcVolUnits ...
                    = @(params,units,nS) ...
                      calcVolFlows4UnitsFlowCtrlDT1AccExTa(params, ...
                                                               units,nS);
                
            %When isothermal,
            elseif enerBalTrue == 0
               
                %Redefine the submodel for the volumetric flow rate
                %calculations for the extract tank
                params.funcVolUnits ...
                    = @(params,units,nS) ...
                      calcVolFlows4UnitsFlowCtrlDT0AccExTa(params, ...
                                                           units,nS);
                
            end
                  
            %Define the right-hand side function
            funcRhs = @(t,x) defineRhsFunc(t,x,params);  
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%
            %Numerically integrate the ODEs
            
            %Perform the numerical integration for the step
            sol0 = solvOdes(funcRhs,tDom,iStates,options,numIntSolv);
            
            %Print out the numerical integration stats
            noteNumIntStats(sol0,numIntSolv);
            
            %Check to see if an event triggered
            eventTrue = isfield(sol0, 'xe') && ~isempty(sol0.xe);
            
            %When an event triggered, 
            if eventTrue
            
                %Figure out which event triggered
                eveTrig = sol0.ie;
                
                %Update the time domain
                tDom0 = [0,sol0.xe];               
               
            %If no event has triggered,
            else
                
                %Let us note that no event has triggered
                eveTrig = 0;
                
                %Set the time domain equal to the original time span
                tDom0 = tDom;
                
            end
            
            %Depending on the event, print out helpful messages
                        
            %When no event has triggered
            if eveTrig == 0
                
                %Print additional helpful message
                fprintf("\n*******************************************\n"); 
                fprintf("The extr. tank pressure has not reached.")       ; 
                fprintf("\n*******************************************\n");
            
            %When the extract tank pressure reached a threshold,
            elseif eveTrig == 1
            
                %Print additional helpful message
                fprintf("\n*******************************************\n"); 
                fprintf("The extr. tank pressure has reached.")           ; 
                fprintf("\n*******************************************\n"); 
                
            %When the user-supplied event triggered,
            elseif eveTrig == 2
                
                %Print additional helpful message
                fprintf("\n*******************************************\n"); 
                fprintf("The user-supplied event triggered first.")       ; 
                fprintf("\n*******************************************\n");

                eveTrigUser = true;
                
            end 
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%
            %Update the solution information
            
            %We've done the pre-integration
            preInt = 1;                        
            %-------------------------------------------------------------%
            
        %Otherwise,
        else
        
            %-------------------------------------------------------------%
            %Set the solution structure as an empty vector
            sol0 = [];

            %No need for us to do the pre-integration
            preInt = 0;

            %Set the new time domain
            tDom0 = tDom;
            %-------------------------------------------------------------%
        
        end
        %-----------------------------------------------------------------%      

    %If the raffinate product is flowing into the raffinate tank, and
    %the extract product is flowing into the extract tank, either from a
    %low-pressure purge step or from a depressurization step.
    elseif raffTrue == 1 && xor(extrTrueLp == 1, extrTrueDp == 1)

        %-----------------------------------------------------------------%
        %Get more information about the interactions between columns
        %and tanks

        %Total number of events (raffinate tank and extract tank each has 
        %one interaction at the most, given two adsorbers)
        totalNumEvents = 2;
        %-----------------------------------------------------------------%


        
        %-----------------------------------------------------------------%
        %If the pressure needs to build up
        if exTaSign < 0 || raTaSign < 0
              
            %-------------------------------------------------------------%
            %Update the data structure
            
            %Update the data structure with integration specific 
            %information for the given step
            params = grabParams4Step(params,nS);
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%
            %Initialize the boolean event status 

            %Given that exTaSign < 0 || raTaSign < 0, we are still not at 
            %the desired pressure.
            exTaGood = false;
            raTaGood = false;
            %-------------------------------------------------------------%



            %-------------------------------------------------------------%
            i = 1;

            tEndPrev = 0;

            while i <= totalNumEvents

                %---------------------------------------------------------%
                %Update relevant information and define a new function 
                %handle for the right-hand side

                %Both tank pressures still unreached
                if raTaGood == 0 && exTaGood == 0

                    %If we have another event, i.e., we have an 
                    %event-driven mode, 
                    if secEveTrue == 1
                    
                        %Set the option for the event function
                        options ...
                            = odeset('Events', ...
                                 @(t,states) ...
                                 getBoTaEventPressureAccMult(params, ...
                                                            t,states));
                                                    
                    %If it is a time-driven mode,
                    else
                        
                        %Set the option for the event function
                        options ...
                            = odeset('Events', ...
                                 @(t,states) ...
                                 getBoTaEventPressureAcc(params, ...
                                                        t,states));
                    
                    end                                    
                    
                    %When noisothermal,
                    if enerBalTrue == 1
                        
                        %Redefine the submodel for the volumetric flow rate
                        %calculations for the extract and raffinate tanks
                        params.funcVolUnits ...
                        = @(params,units,nS) ...
                          calcVolFlows4UnitsFlowCtrlDT1AccBoTa(params, ...
                                                               units,nS);
                        
                    %When isothermal,
                    elseif enerBalTrue == 0
                       
                        %Redefine the submodel for the volumetric flow rate
                        %calculations for the extract and raffinate tanks
                        params.funcVolUnits ...
                        = @(params,units,nS) ...
                          calcVolFlows4UnitsFlowCtrlDT0AccBoTa(params, ...
                                                               units,nS);
                        
                    end

                %Extract tank pressure still unreached
                elseif raTaGood == 1 && exTaGood == 0

                    %If we have another event, i.e., we have an 
                    %event-driven mode, 
                    if secEveTrue == 1
                    
                        %Set the option for the event function
                        options ...
                            = odeset('Events', ...
                                 @(t,states) ...
                                 getExTaEventPressureAccMult(params, ...
                                                            t,states));
                                                    
                    %If it is a time-driven mode,
                    else
                        
                        %Set the option for the event function
                        options ...
                            = odeset('Events', ...
                                 @(t,states) ...
                                 getExTaEventPressureAcc(params, ...
                                                        t,states));
                    
                    end                                    
                    
                    %When noisothermal,
                    if enerBalTrue == 1
                        
                        %Redefine the submodel for the volumetric flow rate
                        %calculations for the extract tank
                        params.funcVolUnits ...
                        = @(params,units,nS) ...
                          calcVolFlows4UnitsFlowCtrlDT1AccExTa(params, ...
                                                               units,nS);
                        
                    %When isothermal,
                    elseif enerBalTrue == 0
                       
                        %Redefine the submodel for the volumetric flow rate
                        %calculations for the extract tank
                        params.funcVolUnits ...
                        = @(params,units,nS) ...
                          calcVolFlows4UnitsFlowCtrlDT0AccExTa(params, ...
                                                               units,nS);
                        
                    end

                %Raffiante tank pressure still unreached.
                elseif raTaGood == 0 && exTaGood == 1

                    %If we have another event, i.e., we have an 
                    %event-driven mode, 
                    if secEveTrue == 1
                    
                        %Set the option for the event function
                        options ...
                            = odeset('Events', ...
                                 @(t,states) ...
                                 getRaTaEventPressureAccMult(params, ...
                                                            t,states));
                                                    
                    %If it is a time-driven mode,
                    else
                        
                        %Set the option for the event function
                        options ...
                            = odeset('Events', ...
                                 @(t,states) ...
                                 getRaTaEventPressureAcc(params, ...
                                                            t,states));
                        
                    end
                    
                    %When noisothermal,
                    if enerBalTrue == 1
                        
                        %Redefine the submodel for the volumetric flow rate
                        %calculations for the raffinate tank
                        params.funcVolUnits ...
                        = @(params,units,nS) ...
                          calcVolFlows4UnitsFlowCtrlDT1AccRaTa(params, ...
                                                               units,nS);
                        
                    %When isothermal,
                    elseif enerBalTrue == 0
                        
                        %Redefine the submodel for the volumetric flow rate
                        %calculations for the raffinate tank
                        params.funcVolUnits ...
                        = @(params,units,nS) ...
                          calcVolFlows4UnitsFlowCtrlDT0AccRaTa(params, ...
                                                               units,nS);
                        
                    end 

                %Pressure for both tanks are reached.
                else

                    break

                end
                
                %Define the right-hand side function
                funcRhs = @(t,x) defineRhsFunc(t,x,params);  
                %---------------------------------------------------------%
                
                
                
                %---------------------------------------------------------%
                %Numerically integrate the ODEs
                
                if i == 1
                    %Perform the numerical integration for the step
                    sol0 = solvOdes(funcRhs,tDom,iStates,options,numIntSolv);
                    
                else
                
                    sol0 = odextend(sol0, funcRhs, tDom(end), [], options);

                end

                %Print out the numerical integration stats
                noteNumIntStats(sol0,numIntSolv);
                
                %Check to see if an event triggered
                eventTrue = isfield(sol0, 'xe') && ~isempty(sol0.xe);
                
                %When an event triggered, 
                if eventTrue
                
                    %Figure out which event triggered
                    eveTrig = sol0.ie;
                    
                    if i > 1

                        %Update the time domain
                        tDom0 = [0, sol0.xe] ;

                    end

                    sol0.xe = [];
                    sol0.ye = [];
                    sol0.ie = [];

                %If no event has triggered,
                else
                    
                    %Let us note that no event has triggered
                    eveTrig = 0;
                    
                    %Set the time domain equal to the original time span
                    tDom0 = tDom;
                    
                end
                
                %Depending on the event, print out helpful messages
                            
                %When no event has triggered
                if eveTrig == 0
                    
                    %Print additional helpful message
                    fprintf("\n**********************" + ...
                            "*********************\n");   
                    fprintf("Either the raffinate tank pressure " + ...
                            "or the extract tank pressure has not " + ...
                            "reached."); 
                    fprintf("\n**********************" + ...
                            "*********************\n"); 

                    break
                
                %When the raffinate tank pressure reached a threshold,
                elseif eveTrig == 1

                    if i == 1
                
                        %Print additional helpful message
                        fprintf("\n**********************" + ...
                                "*********************\n"); 
                        fprintf("The raff. tank pressure has reached."); 
                        fprintf("\n**********************" + ...
                                "*********************\n");  

                        raTaGood = true;

                    else

                        %Print additional helpful message
                        fprintf("\n**********************" + ...
                                "*********************\n"); 
                        fprintf("The other tank pressure has reached."); 
                        fprintf("\n**********************" + ...
                                "*********************\n");  

                        exTaGood = true;

                    end
                    
                %When the extract tank pressure reached a threshold,
                elseif eveTrig == 2
                
                    if i == 1

                        %Print additional helpful message
                        fprintf("\n**********************" + ...
                                "*********************\n"); 
                        fprintf("The extr. tank pressure has reached."); 
                        fprintf("\n**********************" + ...
                                "*********************\n");  

                        exTaGood = true;

                    else

                        %Print additional helpful message
                        fprintf("\n**********************" + ...
                                "*********************\n"); 
                        fprintf("The other tank pressure has reached."); 
                        fprintf("\n**********************" + ...
                                "*********************\n");  

                        raTaGood = true;

                    end

                %When the user-supplied event triggered,
                elseif eveTrig == 3
                    
                    if i == 1

                        %Print additional helpful message
                        fprintf("\n**********************" + ...
                                "*********************\n"); 
                        fprintf("The user-supplied event triggered first."); 
                        fprintf("\n**********************" + ...
                                "*********************\n");

                    end

                    eveTrigUser = true;

                    break
                    
                end 
                %---------------------------------------------------------%



                %---------------------------------------------------------%
                %Update the loop-related information

                %Increment the event counter by 1
                i = i + 1;
                %---------------------------------------------------------%
            
            end
            %-------------------------------------------------------------%


            
            %-------------------------------------------------------------%
            %Update the solution information
            
            %We've done the pre-integration
            preInt = 1;                        
            %-------------------------------------------------------------%
            
        %Otherwise,
        else
        
            %-------------------------------------------------------------%
            %Set the solution structure as an empty vector
            sol0 = [];

            %No need for us to do the pre-integration
            preInt = 0;

            %Set the new time domain
            tDom0 = tDom;

            %No user-defined event has triggered
            eveTrigUser = 0;
            %-------------------------------------------------------------%
        
        end
        %-----------------------------------------------------------------%  

    %If no pre-integrationwas done, 
    else
        
        %-----------------------------------------------------------------%
        %Set the solution structure as an empty vector
        sol0 = [];

        %No need for us to do the pre-integration
        preInt = 0;

        %Set the new time domain
        tDom0 = tDom;

        %No used-defined event has triggered
        eveTrigUser = 0;
        %-----------------------------------------------------------------%
        
    end
    %---------------------------------------------------------------------%
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%