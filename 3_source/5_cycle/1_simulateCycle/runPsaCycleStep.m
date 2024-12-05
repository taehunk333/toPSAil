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
%Function   : runPsaCycleStep.m
%Source     : common
%Description: Given all the information in params, this function simulates
%             a given PSA process by obtainining the solution of the
%             dynamic PSA process model through the usage of
%             state-of-the-art ODE solver(s). The solution technique
%             implemented here is called the method of lines.
%Inputs     : params       - a struct containing simulation parameters.
%             iStates      - an initial state solution row vector
%                            containing the initial condition to the 
%                            simulation.
%             tDom         - a 1 by 2 numerical vector that contains the
%                            initial and terminal time points for the
%                            numerical integration.
%             nCy          - the current PSA cycle
%             nS           - the current step in a given PSA cycle
%Outputs    : stTime       - a column vector containing state time points
%             stStates     - a solution matrix containing the time
%                            evolution of the state solutions for all the
%                            state variables coming from the numerical
%                            integration of the system of ODEs
%             flags        - a struct containing any numerical flags
%                            resulting from error messages.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [stTime,stStates,flags] ...
    = runPsaCycleStep(params,iStates,tDom,nS,nCy)

    %---------------------------------------------------------------------%
    %Define known quantities
    
    %Define function ID
    funcId = 'runPsaCycleStep.m';
    
    %Unpack params
    nTiPts     = params.nTiPts     ;
    numIntSolv = params.numIntSolv ;
    funcEve    = params.funcEve{nS};
    bool       = params.bool       ;
    numZero    = params.numZero    ; 
    
    %Initialize the original integration; it must be done, to begin with
    orgInt = 1;
    %---------------------------------------------------------------------%
    
    
        
    %---------------------------------------------------------------------%
    %Update the initial condition vector
            
    %If we are doing a flow driven simulation, and no event is specified
    if bool(3) == 0
        
        %-----------------------------------------------------------------%
        %Do the pre-integration, if needed
        
        %Let the pressure build up inside the raffinate product tank and/or
        %the extract product tank, if needed
        [sol0,tDom0,preInt] = solvOdes0(params,tDom,iStates,nS);
        %-----------------------------------------------------------------%
        
        
        
        %-----------------------------------------------------------------%
        %Update the information for the original numerical integration
                        
        %If pre-integration was needed and done,
        if preInt == 1
                 
            %-------------------------------------------------------------%                        
            %Check for the event status
            
            %Check to see if the user-specified event has triggered: 
            %eveTrig = 2. First, see if the field is not empty or not
            if ~isempty(sol0.ie)
            
                %When the field ie is not empty, we save it as an integer
                eveTrig = sol0.ie;
                
            else
                
                %When the field ie is empty, we save it as a zero
                eveTrig = 0;
                
            end
            %-------------------------------------------------------------%                        
            
            
            
            %-------------------------------------------------------------%                        
            %Get the terminal time points
            tf  = tDom(2) ;
            tf0 = tDom0(2);                

            %Consider the duration of the pre-integration. If we are pretty
            %much done with the numerical integration for the step, within 
            %the numerical tolerance, or the second event triggered first,
            %then
            if abs(tf-tf0) < numZero || eveTrig == 2
                
%                 %Update the solution data structure
%                 sol = sol0;
                
                %We've effectively finished simulating the step, so no need 
                %to do the original integration
                orgInt = 0;
              
            %Otherwise, reset for the next (original) numerical integration
            else
                                
                %Reset the solution structure for the next event-driven
                %simulation for the original numerical integration.
                sol0.ie = [];
                
            end
            %-------------------------------------------------------------%
                                            
        %If the pre-integation was not needed
        elseif preInt == 0
            
            %-------------------------------------------------------------%        
            %Update the flag for the pre-integration
            preInt = 0;                                    
            %-------------------------------------------------------------%
            
        end                        
        %-----------------------------------------------------------------%
        
    %If we are doing a pressure driven simulation   
    else
        
        %-----------------------------------------------------------------%    
        %Update the flag for the pre-integration
        preInt = 0;
        %-----------------------------------------------------------------%
        
    end
    %---------------------------------------------------------------------%
    
    
    
    %---------------------------------------------------------------------%
    %If we still need to do the original integration, then do the 
    %followings
    
    %If we still need to do the original numerical integration,
    if orgInt == 1
    
        %-----------------------------------------------------------------%
        %Define the right-hand side function to be integrated, along with
        %options for the ODE solver to solver the system of ODEs        
        
        %Update the data structure with integration specific information 
        %for the given step
        params = grabParams4Step(params,nS);                     

        %Define the right hand side function
        funcRhs = @(t,x) defineRhsFunc(t,x,params);                        
        %-----------------------------------------------------------------%



        %-----------------------------------------------------------------%
        %Simulate the step in a scheduled PSA cycle        

        %If we were to extend the solution
        if preInt == 1
            
            %Get the second initial state
            initState2nd = sol0.y(:,end)';
            
            %Get the ode solver option from setOdeSolverOpts.m
            options = setOdeSolverOpts(params,initState2nd,nS,nCy);
            
            %Perform the numerical integration for the step
            sol = odextend(sol0,funcRhs,tDom(2),[],options);            
            
        %If we are doing the original numerical integration
        else
            
            %Get the ode solver option from setOdeSolverOpts.m
            options = setOdeSolverOpts(params,iStates,nS,nCy);
            
            %Perform the numerical integration for the step
            sol = solvOdes(funcRhs,tDom,iStates,options,numIntSolv);
        
        end
        %-----------------------------------------------------------------%



        %-----------------------------------------------------------------%
        %Print numerical integration summary
        
        %Print out the numerical integration results
        noteNumIntStats(sol,numIntSolv);        
        %-----------------------------------------------------------------% 
    
    %If we do not need to do the original integration
    else
        
        %-----------------------------------------------------------------%
        %Update the solution structure
        
        %Set the pre-integration to the original integration
        sol = sol0;
        %-----------------------------------------------------------------%
        
    end
    %---------------------------------------------------------------------%
      
    
    
    %---------------------------------------------------------------------%
    %Obtain the solutions based on the integration results and the type of
    %the mode of integration (i.e., event vs time).
    
    %If we have the results from event driven numerical integration,
    if isempty(funcEve) ~= 1     
               
        %-----------------------------------------------------------------%
        %Test to see if the event function is what caused the integration 
        %to stop
        if isempty(sol.xe) == 1
            
            %-------------------------------------------------------------%
            %Flag the event
            
            %Flag to indicate that an event did not happen
            flags.event = 0;
            %-------------------------------------------------------------%
            
            
            
            %-------------------------------------------------------------%                
            %Interpolate to obtain a desired number of solutions within a 
            %newly defined subdomain of the dimensionless time
            
            %Get the number of time points
            numTiPtsStep = length(sol.x);
            
            %Get the indices for the assorted time steps
            timeIndices = round(linspace(1,numTiPtsStep,nTiPts));
            
            %Determine the range of the solution time points as a subset of
            %the domain of the time points used for the numerical 
            %integration. Since no event is used, an upperbound would be 
            %the final time. Also, we want nTimePts number of time points 
            %from the solution.
%             stTime = linspace(0,tDom(2),nTiPts);
            stTime = sol.x(timeIndices);

            %Use deval to evaluate the solution of a differential equation 
            %problem.
%             stStates = transpose(deval(sol,stTime));       
            stStates = transpose(sol.y(:,timeIndices));
            %-------------------------------------------------------------%
            
        else
            
            %-------------------------------------------------------------%                
            %Flag the event
            
            %Flag to indicate that an event did happen
            flags.event = 1;
            %-------------------------------------------------------------%
                        
            
            
            %-------------------------------------------------------------%                
            %Interpolate to obtain a desired number of solutions within a 
            %newly defined subdomain of the dimensionless time

            %Get the number of time points
            numTiPtsStep = length(sol.x);
            
            %Get the indices for the assorted time steps
            timeIndices = round(linspace(1,numTiPtsStep,nTiPts));
            
            %Determine the range of the solution time points as a subset of
            %the domain of the time points used for the numerical 
            %integration. Since the event is used, an upperbound would be 
            %the event time. Also, we want nTimePts number of time points 
            %from the solution.
%             stTime = linspace(0,sol.xe(end),nTiPts);
            stTime = sol.x(timeIndices);

            %Use deval to evaluate the solution of a differential equation 
            %problem.
%             stStates = transpose(deval(sol,stTime));     
            stStates = transpose(sol.y(:,timeIndices));
            %-------------------------------------------------------------%
            
        end
        %-----------------------------------------------------------------%                                
                
    %If we have the results from time driven numerical integration,    
    elseif isempty(funcEve) == 1
        
        %-----------------------------------------------------------------%                
        %Update the flag
        
        %Flag to indicate that an event did not happen
        flags.event = 0;
        %-----------------------------------------------------------------%                
        
        
        
        %-----------------------------------------------------------------%                
        %Interpolate to obtain a desired number of solutions within a newly
        %defined subdomain of the dimensionless time
        
        %Get the number of time points
        numTiPtsStep = length(sol.x);

        %Get the indices for the assorted time steps
        timeIndices = round(linspace(1,numTiPtsStep,nTiPts));
        
        %Determine the range of the solution time points as a subset of the
        %domain of the time points used for the numerical integration.
        %Since no event is used, an upperbound would be the final time.
        %Also, we want nTimePts number of time points from the solution.
%         stTime = linspace(0,tDom(2),nTiPts);
        stTime = sol.x(timeIndices);
        
        %Use deval to evaluate the solution of a differential equation 
        %problem.
%         stStates = transpose(deval(sol,stTime));    
        stStates = transpose(sol.y(:,timeIndices));
        %-----------------------------------------------------------------% 
        
    end        
    %---------------------------------------------------------------------%            
    

    
    %---------------------------------------------------------------------%            
    %Check the solution output
    
    %Throw out a warning if the solution is not of the right length
    if length(stTime) < nTiPts
        
        %Print out the error message
        msg = 'Did not obtain enough number of time points as a solution';
        msg = append(funcId,': ',msg);
        error(msg); 
        
    end        
    %---------------------------------------------------------------------%     
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%